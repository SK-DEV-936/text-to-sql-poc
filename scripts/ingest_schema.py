import argparse
import asyncio
import os
import re
import json
from typing import Any, Dict, List
from pydantic import BaseModel, Field

from boons_text_to_sql_agent.config import load_settings
from langchain_core.prompts import ChatPromptTemplate

# --- Models for Schema Parsing ---
class ColumnDef(BaseModel):
    name: str = Field(description="Name of the column")
    description: str = Field(description="Description of what this column represents")

class TableDef(BaseModel):
    name: str = Field(description="Name of the table")
    description: str = Field(description="Description of what this table represents")
    columns: List[ColumnDef] = Field(description="List of columns in this table")

class RelationshipDef(BaseModel):
    from_col: str = Field(alias="from", description="Format: table.column (foreign key)")
    to_col: str = Field(alias="to", description="Format: table.column (primary key it references)")

class SchemaDoc(BaseModel):
    tables: List[TableDef] = Field(description="List of all tables in the schema")
    relationships: List[RelationshipDef] = Field(description="List of all relationships between tables")

# --- Models for Test Case Generation ---
class TestCaseDef(BaseModel):
    question: str = Field(description="The question a user might ask")
    role: str = Field(description="Role of the user, e.g., 'MERCHANT' or 'INTERNAL'")
    merchant_ids: List[int] = Field(description="List of merchant IDs, e.g., [1] if MERCHANT, [] if INTERNAL")
    expected_to_be_sql: bool = Field(description="True if it requires a SQL query, False if it's general chat")

class TestCasesDoc(BaseModel):
    test_cases: List[TestCaseDef] = Field(description="List of proposed test cases")

# --- Models for Knowledge Base Generation ---
class RagDocumentDef(BaseModel):
    page_content: str = Field(description="The content of the document, explaining a relationship, synonym, rule, or table.")
    category: str = Field(description="Category of the document, e.g., 'schema', 'relationship', 'synonym'")
    table: str = Field(default="", description="Table name if applicable, otherwise empty string")

class KnowledgeBaseDoc(BaseModel):
    documents: List[RagDocumentDef] = Field(description="List of knowledge base documents to be ingested into FAISS")

async def run_ingestion(schema_path: str, prompt_focus: str):
    print(f"Loading schema from {schema_path}...")
    with open(schema_path, "r") as f:
        schema_sql = f.read()
    
    settings = load_settings()
    if settings.is_aws_environment:
        from langchain_aws import ChatBedrock
        llm = ChatBedrock(
            model_id=settings.bedrock_model_id,
            region_name=settings.aws_region,
            temperature=0.0
        )
    else:
        from langchain_openai import ChatOpenAI
        llm = ChatOpenAI(
            model=settings.llm_model,
            api_key=settings.llm_api_key,
            temperature=0.0
        )
    
    print("Parsing SQL schema into dictionary format using LLM...")
    schema_prompt = ChatPromptTemplate.from_messages([
        ("system", "You are an expert DBA. Analyze the provided DDL SQL schema and extract a structured representation. "
                   "For each table, provide a clear description and interpret the columns. "
                   "Identify all primary/foreign key relationships."),
        ("human", "{sql}")
    ])
    schema_chain = schema_prompt | llm.with_structured_output(SchemaDoc)
    
    schema_doc = await schema_chain.ainvoke({"sql": schema_sql})
    
    # Convert SchemaDoc to the nested dictionary format used in StaticSchemaProvider
    schema_dict = {
        "tables": {},
        "relationships": []
    }
    
    for table in schema_doc.tables:
        schema_dict["tables"][table.name] = {
            "description": table.description,
            "columns": {col.name: col.description for col in table.columns}
        }
    
    for rel in schema_doc.relationships:
        # Handle pydantic v1 vs v2 alias resolution differences if needed
        rel_dict = rel.dict(by_alias=True)
        schema_dict["relationships"].append({
            "from": rel_dict.get("from", ""),
            "to": rel_dict.get("to", "")
        })

    # Generate Python code for static_schema_provider.py
    base_schema_str = json.dumps(schema_dict, indent=12)
    # Fix indenting to align with the class method
    indented_schema_lines = []
    for i, line in enumerate(base_schema_str.splitlines()):
        if i == 0:
            indented_schema_lines.append(line)
        else:
            indented_schema_lines.append("        " + line)
    formatted_schema_str = "\n".join(indented_schema_lines)
    
    provider_code = f'''from __future__ import annotations

from typing import Any, Dict, Mapping

from boons_text_to_sql_agent.application.ports import SchemaProviderPort
from boons_text_to_sql_agent.domain import Role, Scope


class StaticSchemaProvider(SchemaProviderPort):
    """Temporary hardcoded schema manifest for the POC."""

    def get_schema_manifest(self, scope: Scope) -> Mapping[str, Any]:
        base_schema: Dict[str, Any] = {formatted_schema_str}

        if scope.role == Role.MERCHANT:
            base_schema["role"] = "merchant"
        else:
            base_schema["role"] = "internal"

        return base_schema
'''
    provider_path = os.path.join(
        "boons_text_to_sql_agent", "infrastructure", "schema", "static_schema_provider.py"
    )
    
    print(f"Updating {provider_path}...")
    with open(provider_path, "w") as f:
        f.write(provider_code)
        
    print(f"Generating Test Cases based on schema and prompt: '{prompt_focus}'...")
    test_case_prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a QA engineer for a Text-to-SQL system. You need to generate diverse Test Cases covering both 'MERCHANT' and 'INTERNAL' roles. "
                   "A 'MERCHANT' usually only has access to their own data (merchant_ids=[1]). An 'INTERNAL' role has access to all data (merchant_ids=[]). "
                   "Include a few questions that are NOT data related (expected_to_be_sql=False). "
                   "Ensure the test cases align with the provided Schema and this specific focus prompt: {prompt_focus}"),
        ("human", "Schema:\n{schema_json}")
    ])
    test_case_chain = test_case_prompt | llm.with_structured_output(TestCasesDoc)
    
    cases_doc = await test_case_chain.ainvoke({
        "prompt_focus": prompt_focus,
        "schema_json": json.dumps(schema_dict, indent=2)
    })
    
    print(f"Updating scripts/test_suite.py with {len(cases_doc.test_cases)} new test cases...")
    test_suite_path = os.path.join("scripts", "test_suite.py")
    with open(test_suite_path, "r") as f:
        test_suite_code = f.read()

    # Generate the TEST_CASES python list code
    tc_lines = []
    for tc in cases_doc.test_cases:
        expected_arg = "" if tc.expected_to_be_sql else ", expected_to_be_sql=False"
        role_enum = f"Role.{tc.role.upper()}" if tc.role.upper() in ["MERCHANT", "INTERNAL"] else "Role.INTERNAL"
        tc_lines.append(f'    TestCase("{tc.question}", {role_enum}, {tc.merchant_ids}{expected_arg}),')
    
    tc_list_str = "[\n" + "\n".join(tc_lines) + "\n]"
    
    # Replace the TEST_CASES variable block in test_suite.py using regex
    test_suite_code = re.sub(
        r'TEST_CASES = \[.*?\](?=\n\nasync def)', 
        f'TEST_CASES = {tc_list_str}', 
        test_suite_code, 
        flags=re.DOTALL
    )
    
    with open(test_suite_path, "w") as f:
        f.write(test_suite_code)
        
    print(f"Generating RAG Knowledge Base documents based on schema and prompt: '{prompt_focus}'...")
    rag_prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a domain expert. Analyze the provided schema and create specific knowledge documents to help an LLM write accurate SQL. "
                   "Provide documents detailing 'schema' elements (what tables mean), 'relationship' rules (how to join), and a rich set of 'synonym' rules "
                   "mapping business language like '{prompt_focus}' into precise SQL column filters or calculations. Create at least 10 robust semantic rules."),
        ("human", "Schema:\n{schema_json}")
    ])
    rag_chain = rag_prompt | llm.with_structured_output(KnowledgeBaseDoc)
    
    rag_doc = await rag_chain.ainvoke({
        "prompt_focus": prompt_focus,
        "schema_json": json.dumps(schema_dict, indent=2)
    })
    
    print(f"Updating scripts/build_knowledge_base.py with {len(rag_doc.documents)} new knowledge documents...")
    build_kb_path = os.path.join("scripts", "build_knowledge_base.py")
    with open(build_kb_path, "r") as f:
        build_kb_code = f.read()
        
    # Generate the KNOWLEDGE_DOCS python list code
    kb_lines = []
    for doc in rag_doc.documents:
        # Properly escape quotes in content
        content_escaped = doc.page_content.replace('"', '\\"')
        meta_dict = f'{{"category": "{doc.category}"'
        if doc.table:
             meta_dict += f', "table": "{doc.table}"'
        meta_dict += '}'
        
        kb_lines.append(f'    Document(\n        page_content="{content_escaped}",\n        metadata={meta_dict}\n    ),')
        
    kb_list_str = "[\n" + "\n".join(kb_lines) + "\n]"
    
    # Replace the KNOWLEDGE_DOCS variable block
    build_kb_code = re.sub(
        r'KNOWLEDGE_DOCS = \[.*?\](?=\n\ndef build_index)', 
        f'KNOWLEDGE_DOCS = {kb_list_str}', 
        build_kb_code, 
        flags=re.DOTALL
    )
    
    with open(build_kb_path, "w") as f:
        f.write(build_kb_code)
        
    print("Rebuilding FAISS local index by executing build_knowledge_base.py...")
    # Import and run the script programmatically to avoid subprocess complexity
    from scripts.build_knowledge_base import build_index
    build_index()

    print("Schema ingestion, test generation, and RAG index rebuild complete!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ingest a SQL schema and generate configuration and test cases.")
    parser.add_argument("--schema", required=True, help="Path to the .sql schema file")
    parser.add_argument("--prompt", required=True, help="Prompt describing what kind of logic or tests to focus on")
    
    args = parser.parse_args()
    asyncio.run(run_ingestion(args.schema, args.prompt))

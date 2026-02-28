import argparse
import asyncio
import os
import re
import json
import ast
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

def update_static_schema(schema_doc: SchemaDoc):
    """Safely append new tables to static_schema_provider.py using regex."""
    provider_path = os.path.join(
        "boons_text_to_sql_agent", "infrastructure", "schema", "static_schema_provider.py"
    )
    
    with open(provider_path, "r") as f:
        code = f.read()

    # 1. ADD TABLES
    # We find the end of the "tables" dictionary. 
    # This is tricky with regex, so we'll look for the "relationships" key which immediately follows it.
    
    new_tables_str = ""
    for table in schema_doc.tables:
        table_dict = {
            "description": table.description,
            "columns": {col.name: col.description for col in table.columns}
        }
        # Format the table dictionary
        formatted_table = json.dumps(table_dict, indent=12)
        # Shift everything over to match the indentation of the tables block
        shifted_table = "\n".join("        " + line if i > 0 else line for i, line in enumerate(formatted_table.splitlines()))
        
        new_tables_str += f',\n                                "{table.name}": {shifted_table}'

    # Insert right before "relationships": [
    # We use a precise replacement on the first occurrence from the bottom up to avoid matching inner string fragments
    code = re.sub(
        r'(,\s*"relationships":\s*\[)', 
        new_tables_str + r'\1', 
        code,
        count=1
    )
    
    # 2. ADD RELATIONSHIPS
    # Find the end of the relationships array.
    new_rels_str = ""
    for rel in schema_doc.relationships:
        rel_dict = rel.dict(by_alias=True)
        from_v = rel_dict.get("from", "")
        to_v = rel_dict.get("to", "")
        formatted_rel = f'{{\n                                            "from": "{from_v}",\n                                            "to": "{to_v}"\n                                }}'
        new_rels_str += f',\n                                {formatted_rel}'

    # Insert right before the closing bracket of relationships array
    # Look for the exact closing sequence of the base_schema dictionary
    code = re.sub(
        r'(\s*\]\n\s*\}\n\n\s*if scope\.role == Role\.MERCHANT:)', 
        new_rels_str + r'\1', 
        code,
        count=1
    )

    with open(provider_path, "w") as f:
        f.write(code)

def append_test_cases(cases_doc: TestCasesDoc):
    """Safely append new test cases to scripts/test_suite.py"""
    test_suite_path = os.path.join("scripts", "test_suite.py")
    with open(test_suite_path, "r") as f:
        code = f.read()

    tc_lines = []
    for tc in cases_doc.test_cases:
        expected_arg = "" if tc.expected_to_be_sql else ", expected_to_be_sql=False"
        role_enum = f"Role.{tc.role.upper()}" if tc.role.upper() in ["MERCHANT", "INTERNAL"] else "Role.INTERNAL"
        tc_lines.append(f'    TestCase("{tc.question}", {role_enum}, {tc.merchant_ids}{expected_arg}),')
    
    # Insert before the closing bracket of TEST_CASES
    # The existing test suite lines end with commas. We just need to prepend a newline.
    # To be extremely safe, we will just format the new cases block normally with a leading newline.
    new_cases_str = "\n" + "\n".join(tc_lines) + "\n"
    code = re.sub(
        r'(?=\n\]\n\nasync def)', 
        new_cases_str, 
        code,
        count=1
    )

    with open(test_suite_path, "w") as f:
        f.write(code)

def append_rag_docs(rag_doc: KnowledgeBaseDoc):
    """Safely append new RAG docs to scripts/build_knowledge_base.py"""
    build_kb_path = os.path.join("scripts", "build_knowledge_base.py")
    with open(build_kb_path, "r") as f:
        code = f.read()

    kb_lines = []
    for doc in rag_doc.documents:
        content_escaped = doc.page_content.replace('"', '\\"')
        meta_dict = f'{{"category": "{doc.category}"'
        if doc.table:
             meta_dict += f', "table": "{doc.table}"'
        meta_dict += '}'
        
        kb_lines.append(f'    Document(\n        page_content="{content_escaped}",\n        metadata={meta_dict}\n    ),')
        
    # Insert before the closing bracket of KNOWLEDGE_DOCS
    # The current list elements end with `,`. So we just prepend a newline.
    # We do NOT want to add an extra comma that would result in `),,`
    new_kb_str = "\n" + "\n".join(kb_lines) + "\n"
    code = re.sub(
        r'(?=\n\]\n\ndef build_index)', 
        new_kb_str, 
        code,
        count=1
    )

    with open(build_kb_path, "w") as f:
        f.write(code)

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
    
    print("\n" + "="*80)
    print("🚦 DATABASE ENGINEER REVIEW REQUIRED 🚦")
    print("="*80)
    
    try:
        with open("docs/db_engineer_guidelines.md", "r") as f:
            print(f.read())
    except FileNotFoundError:
        print("WARNING: docs/db_engineer_guidelines.md not found.")

    print("\n--- AI GENERATED SCHEMA DESCRIPTIONS (REVIEW CAREFULLY) ---")
    for table in schema_doc.tables:
        print(f"\nTable: {table.name}")
        print(f"Description: {table.description}")
        for col in table.columns:
            print(f"  - {col.name}: {col.description}")
            
    print("\nAnalyzing SQL for ambiguous columns...")
    review_prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a senior DB Architect. Review the following SQL schema. Based on best practices for Text-to-SQL AI, print exactly 3 critical, bulleted questions the Database Engineer needs to answer to ensure the AI doesn't hallucinate (e.g., 'Does total_amount include tax?', 'What does status=2 mean?'). Do not write introductory text, just the 3 questions."),
        ("human", "{sql}")
    ])
    try:
        review_chain = review_prompt | llm
        review_msg = await review_chain.ainvoke({"sql": schema_sql})
        print("\n--- CRITICAL QUESTIONS FOR THE DBA TO CONSIDER ---")
        print(review_msg.content)
    except Exception as e:
        print(f"Could not generate DBA review questions: {e}")
        
    print("\n" + "="*80)
    input("Press ENTER to confirm these definitions are perfect and proceed with ingestion, or Ctrl+C to abort and refine your SQL...")
    print("="*80 + "\n")

    print("Safely appending new tables and relationships to static_schema_provider.py...")
    update_static_schema(schema_doc)
        
    print(f"Generating Test Cases based on schema and prompt: '{prompt_focus}'...")
    test_case_prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a QA engineer for a Text-to-SQL system. You need to generate diverse Test Cases for the NEW tables provided below. "
                   "Cover both 'MERCHANT' and 'INTERNAL' roles. "
                   "Include a few questions that are NOT data related (expected_to_be_sql=False). "
                   "Ensure the test cases align with the NEW Schema and this specific focus prompt: {prompt_focus}"),
        ("human", "New Schema Tables:\n{schema_json}")
    ])
    test_case_chain = test_case_prompt | llm.with_structured_output(TestCasesDoc)
    
    schema_dict = {"tables": [{t.name: t.description} for t in schema_doc.tables]}
    cases_doc = await test_case_chain.ainvoke({
        "prompt_focus": prompt_focus,
        "schema_json": json.dumps(schema_dict, indent=2)
    })
    
    print(f"Appending {len(cases_doc.test_cases)} new test cases to scripts/test_suite.py...")
    append_test_cases(cases_doc)
        
    print(f"Generating RAG Knowledge Base documents based on schema and prompt: '{prompt_focus}'...")
    rag_prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a domain expert. Analyze the provided NEW schema tables and create specific knowledge documents to help an LLM write accurate SQL. "
                   "Provide documents detailing 'schema' elements (what tables mean), 'relationship' rules (how to join), and a rich set of 'synonym' rules "
                   "mapping business language like '{prompt_focus}' into precise SQL column filters or calculations. Create at least 5 robust semantic rules."),
        ("human", "New Schema Tables:\n{schema_json}")
    ])
    rag_chain = rag_prompt | llm.with_structured_output(KnowledgeBaseDoc)
    
    rag_doc = await rag_chain.ainvoke({
        "prompt_focus": prompt_focus,
        "schema_json": json.dumps(schema_dict, indent=2)
    })
    
    print(f"Appending {len(rag_doc.documents)} new knowledge documents to scripts/build_knowledge_base.py...")
    append_rag_docs(rag_doc)
        
    import subprocess
    print("Rebuilding FAISS local index by executing build_knowledge_base.py...")
    subprocess.run(["python", "scripts/build_knowledge_base.py"], check=True)

    print("Schema ingestion, test addition, and RAG index rebuild complete!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ingest a SQL schema safely by appending it to existing configurations.")
    parser.add_argument("--schema", required=True, help="Path to the .sql schema file")
    parser.add_argument("--prompt", required=True, help="Prompt describing what kind of logic or tests to focus on")
    
    args = parser.parse_args()
    asyncio.run(run_ingestion(args.schema, args.prompt))

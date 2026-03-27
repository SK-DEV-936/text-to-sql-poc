import sqlglot
from sqlglot.errors import ParseError
from langchain_core.prompts import PromptTemplate
from langchain_openai import ChatOpenAI
from boons_text_to_sql_agent.marketing_module.application.ports import MarketingAiPort

class SecurityValidationError(Exception):
    pass

class LangchainDataSegmenter(MarketingAiPort):
    def __init__(self, llm_model: str = "gpt-4o"):
        self.llm = ChatOpenAI(model=llm_model, temperature=0.0)
        
        self.prompt = PromptTemplate.from_template("""You are a Staff-Level Database Engineer. Your job is to translate a marketing team's abstract audience requirement into flawless, highly-optimized MySQL.

You have been provided with the following database schema representing our tables:
SCHEMA:
{database_schema}

**YOUR TASK:**
Write a MySQL `SELECT` statement that perfectly captures the requested audience:
AUDIENCE REQUIREMENT: {target_segment_logic}

**STRICT SECURITY CONSTRAINTS (FAILURE TO COMPLY RESULTS IN SYSTEM HALT):**
1. **READ ONLY**: You may ONLY generate `SELECT` statements. You are strictly forbidden from generating `UPDATE`, `INSERT`, `DELETE`, `DROP`, or `ALTER`.
2. **COLUMN RESTRICTION**: Your query MUST SELECT only `u.phone`, `u.first_name`, and `u.last_name` from the `users` table as `u`.
3. **MANDATORY MULTI-TENANCY**: You MUST include the exact string `__RLS_MERCHANTS__` in your `WHERE` clause to filter users/orders tied to the current merchant.
4. Only target users where `u.role_id` corresponds to a customer.

**OUTPUT FORMAT:**
Output ONLY the raw SQL string. Do not include markdown formatting.
""")

    async def generate_strategy(self, merchant_data: dict) -> str:
        raise NotImplementedError("Segmenter does not generate strategy.")

    def validate_sql_security(self, sql_query: str) -> str:
        """Parses the SQL with sqlglot. Raises SecurityValidationError if unsafe."""
        try:
            clean_sql = sql_query.replace("```sql", "").replace("```", "").strip()
            
            parsed = sqlglot.parse_one(clean_sql, read="mysql")
            
            if not isinstance(parsed, sqlglot.exp.Select):
                raise SecurityValidationError("Query is not a SELECT statement.")
                
            if "__RLS_MERCHANTS__" not in clean_sql:
                raise SecurityValidationError("Missing mandatory __RLS_MERCHANTS__ multi-tenancy token.")
                
            return clean_sql
        except ParseError as e:
            raise SecurityValidationError(f"Invalid SQL syntax: {e}")

    async def generate_sql_segment(self, target_segment_logic: str, schema_context: str) -> str:
        chain = self.prompt | self.llm
        
        response = await chain.ainvoke({
            "target_segment_logic": target_segment_logic,
            "database_schema": schema_context
        })
        
        return self.validate_sql_security(response.content)

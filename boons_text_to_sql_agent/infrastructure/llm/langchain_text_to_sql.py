from __future__ import annotations

import json
from typing import Any, Mapping

from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import Runnable
from pydantic import BaseModel, Field

from boons_text_to_sql_agent.application.ports import TextToSqlPort
from boons_text_to_sql_agent.config import Settings
from boons_text_to_sql_agent.domain import Question, SqlQuery


class _SqlResponse(BaseModel):
    is_sql: bool = Field(
        description="True if asking a SQL data question. False if saying hello or chatting."
    )
    sql: str | None = Field(
        default=None, 
        description="The generated valid Read-Only SQL query. NULL if is_sql is False."
    )
    message: str | None = Field(
        default=None, 
        description="A conversational reply to the user. NULL if is_sql is True."
    )


class LangChainTextToSqlAdapter(TextToSqlPort):
    """Real LLM adapter using LangChain to generate SQL.
    
    Dynamically switches between OpenAI (local) and AWS Bedrock (aws-*) 
    based on the injected Settings.
    """

    def __init__(self, settings: Settings):
        self._settings = settings
        self._llm = self._init_llm()
        self._chain = self._build_chain()

    def _init_llm(self) -> Any:
        # Initialize either AWS Bedrock or OpenAI based on environment
        if self._settings.is_aws_environment:
            from langchain_aws import ChatBedrock
            return ChatBedrock(
                model_id=self._settings.bedrock_model_id,
                region_name=self._settings.aws_region,
                # boto3 credentials are automatically resolved via IAM 
                # role when running on AWS infra.
            )
        else:
            from langchain_openai import ChatOpenAI
            return ChatOpenAI(
                model=self._settings.llm_model,
                api_key=self._settings.llm_api_key,
                temperature=0.0
            )

    def _build_chain(self) -> Runnable:
        prompt = ChatPromptTemplate.from_messages([
            ("system", "{base_system_prompt}\n\n"
                       "Context/Role Instructions:\n{role_context}\n\n"
                       "Database Schema:\n{schema_json}"),
            ("human", "{question}")
        ])
        
        # We use structured output to ensure we get exactly the SQL string back
        llm_with_tools = self._llm.with_structured_output(_SqlResponse)
        
        return prompt | llm_with_tools

    async def generate_sql(
        self, question: Question, schema_manifest: Mapping[str, Any]
    ) -> SqlQuery | str:
        schema_json = json.dumps(schema_manifest, indent=2)
        
        prompts = self._settings.prompts
        if not prompts:
            raise RuntimeError("Prompts configuration is missing.")
            
        base_prompt = prompts.base_system_prompt
        role_context = prompts.role_contexts.get(question.scope.role.value, "")
        
        # Invoke the chain
        response: _SqlResponse = await self._chain.ainvoke({
            "base_system_prompt": base_prompt,
            "role_context": role_context,
            "schema_json": schema_json,
            "question": question.text
        })
        
        if not response.is_sql and response.message:
            return response.message
            
        sql_text = response.sql or ""
        return SqlQuery(text=sql_text, parameters={})

from __future__ import annotations

import json
from typing import Any, Mapping

from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import Runnable
from pydantic import BaseModel, Field

from boons_text_to_sql_agent.application.ports import TextToSqlPort
from boons_text_to_sql_agent.config import Settings
from boons_text_to_sql_agent.domain import Question, SqlQuery
from boons_text_to_sql_agent.infrastructure.retrieval.vector_store import get_vector_store


class _IntentResponse(BaseModel):
    is_analytics_related: bool = Field(
        description="True if the user is asking about restaurant data, revenue, orders, or business analytics. False if it is general chat, jokes, or non-business topics."
    )
    refusal_message: str | None = Field(
        default=None,
        description="If is_analytics_related is False, provide a professional refusal here. Example: 'I am your dedicated Analytics Assistant...'"
    )


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


class _SqlFixResponse(BaseModel):
    sql: str = Field(description="The fixed valid Read-Only MySQL query.")


class LangChainTextToSqlAdapter(TextToSqlPort):
    """Real LLM adapter using LangChain to generate SQL.
    
    Dynamically switches between OpenAI (local) and AWS Bedrock (aws-*) 
    based on the injected Settings.
    """

    def __init__(self, settings: Settings):
        self._settings = settings
        self._llm = self._init_llm()
        self._vector_store = get_vector_store(settings)
        self._intent_chain = self._build_intent_chain()
        self._chain = self._build_chain()
        self._fix_chain = self._build_fix_chain()

    def _init_llm(self) -> Any:
        # Initialize either AWS Bedrock or OpenAI based on environment
        if self._settings.is_aws_environment:
            from langchain_aws import ChatBedrock
            return ChatBedrock(
                model_id=self._settings.bedrock_model_id,
                region_name=self._settings.aws_region,
                temperature=0.0
            )
        else:
            from langchain_openai import ChatOpenAI
            return ChatOpenAI(
                model=self._settings.llm_model,
                api_key=self._settings.llm_api_key,
                temperature=0.0
            )

    def _build_intent_chain(self) -> Runnable:
        
        gatekeeper_prompt = "You are a gatekeeper for a restaurant analytics AI."
        if self._settings.prompts and self._settings.prompts.intent_gatekeeper_prompt:
            gatekeeper_prompt = self._settings.prompts.intent_gatekeeper_prompt
            
        prompt = ChatPromptTemplate.from_messages([
            ("system", gatekeeper_prompt),
            ("human", "{question}")
        ])
        return prompt | self._llm.with_structured_output(_IntentResponse)

    def _build_chain(self) -> Runnable:
        from langchain_core.prompts import MessagesPlaceholder
        prompt = ChatPromptTemplate.from_messages([
            ("system", "{base_system_prompt}\n\n"
                       "Context/Role Instructions:\n{role_context}\n\n"
                       "Knowledge Base (Schema, Relationships, Synonyms):\n{rag_context}\n\n"
                       "Static Database Schema Payload:\n{schema_json}"),
            MessagesPlaceholder(variable_name="chat_history"),
            ("human", "{question}")
        ])
        
        # We use structured output to ensure we get exactly the SQL string back
        llm_with_tools = self._llm.with_structured_output(_SqlResponse)
        
        return prompt | llm_with_tools

    def _build_fix_chain(self) -> Runnable:
        prompt = ChatPromptTemplate.from_messages([
            ("system", "{fix_sql_prompt}\n\n"
                       "Knowledge Base (Schema, Relationships, Synonyms):\n{rag_context}\n\n"
                       "Database Schema:\n{schema_json}"),
            ("human", "Question: {question}\n"
                      "Failing SQL: {failing_sql}\n"
                      "Error Message: {error_msg}")
        ])
        
        llm_with_tools = self._llm.with_structured_output(_SqlFixResponse)
        
        return prompt | llm_with_tools

    async def generate_sql(
        self, question: Question, schema_manifest: Mapping[str, Any]
    ) -> SqlQuery | str:
        
        # STAGE 0: Cheap Intent Classify (Gatekeeper)
        # This saves cost by avoiding RAG and Schema serialization for junk prompts.
        intent_res: _IntentResponse = await self._intent_chain.ainvoke({"question": question.text})
        if not intent_res.is_analytics_related:
            import logging
            logger = logging.getLogger(__name__)
            logger.info(f"Gatekeeper blocked non-analytics intent: {question.text}")
            return intent_res.refusal_message or "I am only authorized to assist with restaurant analytics data."

        # STAGE 1: Data Gathering (Only for valid intense)
        schema_json = json.dumps(schema_manifest, indent=2)
        
        prompts = self._settings.prompts
        if not prompts:
            raise RuntimeError("Prompts configuration is missing.")
            
        base_prompt = prompts.base_system_prompt
        role_context = prompts.role_contexts.get(question.scope.role.value, "")
        
        # Retrieve relevant context from RAG
        docs = self._vector_store.similarity_search(question.text, k=5)
        rag_context = "\n".join(f"- {doc.page_content}" for doc in docs)
        
        from langchain_core.messages import AIMessage, HumanMessage
        history_msgs = []
        if question.chat_history:
            for msg in question.chat_history:
                if msg.get("role") == "user":
                    history_msgs.append(HumanMessage(content=msg.get("content", "")))
                elif msg.get("role") in ("assistant", "ai"):
                    history_msgs.append(AIMessage(content=msg.get("content", "")))
        
        # STAGE 2: SQL Generation
        response: _SqlResponse = await self._chain.ainvoke({
            "base_system_prompt": base_prompt,
            "role_context": role_context,
            "rag_context": rag_context,
            "schema_json": schema_json,
            "chat_history": history_msgs,
            "question": question.text
        })
        
        if not response.is_sql and response.message:
            return response.message
            
        sql_text = response.sql or ""
        return SqlQuery(text=sql_text, parameters={})

    async def fix_sql(
        self,
        question: Question,
        schema_manifest: Mapping[str, Any],
        failing_sql: SqlQuery,
        error_msg: str,
    ) -> SqlQuery | str:
        schema_json = json.dumps(schema_manifest, indent=2)
        
        prompts = self._settings.prompts
        if not prompts:
            raise RuntimeError("Prompts configuration is missing.")
            
        fix_prompt = prompts.fix_sql_prompt
        
        # Retrieve relevant context from RAG for the fix as well
        docs = self._vector_store.similarity_search(question.text, k=4)
        rag_context = "\n".join(f"- {doc.page_content}" for doc in docs)
        
        response: _SqlFixResponse = await self._fix_chain.ainvoke({
            "fix_sql_prompt": fix_prompt,
            "schema_json": schema_json,
            "rag_context": rag_context,
            "question": question.text,
            "failing_sql": failing_sql.text,
            "error_msg": error_msg
        })
        
        return SqlQuery(text=response.sql, parameters={})

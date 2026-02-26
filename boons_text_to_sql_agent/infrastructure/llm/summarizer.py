import json
from typing import Any, Mapping, Sequence

from langchain_core.prompts import ChatPromptTemplate

from boons_text_to_sql_agent.application.ports import ResultSummarizerPort
from boons_text_to_sql_agent.config import Settings
from boons_text_to_sql_agent.domain import Question


from pydantic import BaseModel, Field

class _SummarizerResponse(BaseModel):
    summary: str = Field(description="The natural language summary of the data.")
    chart_spec: dict | None = Field(
        default=None,
        description="A complete valid Vega-Lite JSON specification object if the data contains trends, rankings, or comparisons that should be charted. Must use 'data': {'name': 'dataset'} as the data source so we can inject the rows natively. If no chart makes sense, return null."
    )

class NoopSummarizer(ResultSummarizerPort):
    """Initial summarizer implementation: returns no summary."""

    async def summarize(self, question: Question, rows: Sequence[Mapping[str, Any]]) -> tuple[str | None, dict | None]:
        return None, None


class LlmSummarizer(ResultSummarizerPort):
    """Real LLM summarizer using LangChain to generate natural language responses."""

    def __init__(self, settings: Settings):
        self._settings = settings
        self._llm = self._init_llm()

    def _init_llm(self) -> Any:
        if self._settings.is_aws_environment:
            from langchain_aws import ChatBedrock
            return ChatBedrock(
                model_id=self._settings.bedrock_model_id,
                region_name=self._settings.aws_region,
            )
        else:
            from langchain_openai import ChatOpenAI
            return ChatOpenAI(
                model=self._settings.llm_model,
                api_key=self._settings.llm_api_key,
                temperature=0.7
            )

    async def summarize(self, question: Question, rows: Sequence[Mapping[str, Any]]) -> tuple[str | None, dict | None]:
        if not rows:
            return "No data found matching your query.", None

        prompt = ChatPromptTemplate.from_messages([
            ("system", "{summarization_prompt}"),
            ("human", "Question: {question}\n\nData Results (JSON):\n{data_json}")
        ])

        chain = prompt | self._llm.with_structured_output(_SummarizerResponse)
        
        summarization_prompt = self._settings.prompts.summarization_prompt if self._settings.prompts else ""
        
        response: _SummarizerResponse = await chain.ainvoke({
            "summarization_prompt": summarization_prompt,
            "user_role": question.scope.role.value,
            "question": question.text,
            "data_json": json.dumps(list(rows)[:20], indent=2, default=str) # Limit context and handle datetimes
        })

        return response.summary, response.chart_spec


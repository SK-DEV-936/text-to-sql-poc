from __future__ import annotations

import logging
from typing import Any, List, Mapping

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from boons_text_to_sql_agent.application import GenerateAndExecuteQueryService
from boons_text_to_sql_agent.domain import Question, Role, Scope

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/text-to-sql", tags=["text-to-sql"])


class QueryRequest(BaseModel):
    role: Role = Field(..., description="User role, e.g. merchant or internal.")
    merchant_ids: List[int] = Field(default_factory=list)
    question: str = Field(..., description="Natural-language analytics question.")
    chat_history: list[dict[str, str]] | None = Field(default=None, description="Previous chat messages for context.")


class QueryResponse(BaseModel):
    final_sql: str | None = None
    rows: List[Mapping[str, Any]] | None = None
    summary: str | None = None
    warnings: List[str] | None = None
    chart_spec: dict | None = None


def create_router(service: GenerateAndExecuteQueryService) -> APIRouter:
    @router.post("/", response_model=QueryResponse)
    async def generate_and_execute(payload: QueryRequest) -> QueryResponse:
        logger.info(f"API Request to /text-to-sql - User Role: {payload.role.value}")
        if payload.role == Role.MERCHANT and not payload.merchant_ids:
            logger.warning("Request rejected: merchant_ids missing for merchant role.")
            raise HTTPException(
                status_code=400, detail="merchant_ids is required for merchant role."
            )

        scope = Scope(
            role=payload.role,
            merchant_ids=payload.merchant_ids,
        )
        question = Question(text=payload.question, scope=scope, chat_history=payload.chat_history)

        try:
            result = await service.handle(question)
        except ValueError as exc:
            logger.error(f"Validation Error during query execution: {exc}")
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        except Exception as exc:
            logger.exception(f"Unexpected error during query execution: {exc}")
            raise HTTPException(status_code=500, detail="Internal server error") from exc

        warnings: List[str] | None = list(result.warnings) if result.warnings else None

        return QueryResponse(
            final_sql=result.sql.text if result.sql else None,
            rows=list(result.rows) if result.rows is not None else None,
            summary=result.summary,
            warnings=warnings,
            chart_spec=result.chart_spec,
        )

    @router.get("/merchants", response_model=List[int])
    async def get_merchants() -> List[int]:
        try:
            return await service.sql_executor.get_active_merchant_ids()
        except Exception as exc:
            logger.exception(f"Unexpected error fetching merchants: {exc}")
            raise HTTPException(status_code=500, detail="Internal server error") from exc

    return router


from __future__ import annotations

from typing import Any, List, Mapping

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from boons_text_to_sql_agent.application import GenerateAndExecuteQueryService
from boons_text_to_sql_agent.domain import Question, Scope, Role


router = APIRouter(prefix="/text-to-sql", tags=["text-to-sql"])


class QueryRequest(BaseModel):
    role: Role = Field(..., description="User role, e.g. merchant or internal.")
    merchant_ids: List[int] = Field(default_factory=list)
    question: str = Field(..., description="Natural-language analytics question.")


class QueryResponse(BaseModel):
    final_sql: str
    rows: List[Mapping[str, Any]]
    summary: str | None = None
    warnings: List[str] | None = None


def create_router(service: GenerateAndExecuteQueryService) -> APIRouter:
    @router.post("/", response_model=QueryResponse)
    async def generate_and_execute(payload: QueryRequest) -> QueryResponse:
        if payload.role == Role.MERCHANT and not payload.merchant_ids:
            raise HTTPException(status_code=400, detail="merchant_ids is required for merchant role.")

        scope = Scope(
            role=payload.role,
            merchant_ids=payload.merchant_ids,
        )
        question = Question(text=payload.question, scope=scope)

        try:
            result = await service.handle(question)
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc

        warnings: List[str] | None = list(result.warnings) if result.warnings else None

        return QueryResponse(
            final_sql=result.sql.text,
            rows=list(result.rows),
            summary=result.summary,
            warnings=warnings,
        )

    return router


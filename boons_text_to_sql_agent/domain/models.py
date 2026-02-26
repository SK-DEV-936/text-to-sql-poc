from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Any, Mapping, Sequence


class Role(str, Enum):
    MERCHANT = "merchant"
    INTERNAL = "internal"


@dataclass(frozen=True)
class Scope:
    role: Role
    merchant_ids: Sequence[int]
    customer_id: int | None = None
    max_rows: int = 1000
    default_time_window_days: int = 90


@dataclass(frozen=True)
class Question:
    text: str
    scope: Scope


@dataclass(frozen=True)
class SqlQuery:
    text: str
    parameters: Mapping[str, Any]


@dataclass(frozen=True)
class QueryResult:
    sql: SqlQuery | None
    rows: Sequence[Mapping[str, Any]] | None
    summary: str | None = None
    warnings: Sequence[str] | None = None


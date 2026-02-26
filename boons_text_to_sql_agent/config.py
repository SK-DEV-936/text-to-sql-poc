from __future__ import annotations

from dataclasses import dataclass
import os


@dataclass(frozen=True)
class Settings:
    db_dsn: str
    llm_api_key: str
    llm_model: str
    max_rows: int
    default_time_window_days: int


def load_settings() -> Settings:
    return Settings(
        db_dsn=os.getenv("DB_DSN", "mysql+aiomysql://user:password@localhost:3306/boons"),
        llm_api_key=os.getenv("LLM_API_KEY", ""),
        llm_model=os.getenv("LLM_MODEL", "gpt-4o-mini"),
        max_rows=int(os.getenv("MAX_ROWS", "1000")),
        default_time_window_days=int(os.getenv("DEFAULT_TIME_WINDOW_DAYS", "90")),
    )


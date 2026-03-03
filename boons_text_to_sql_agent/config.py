from __future__ import annotations

import os
from typing import Dict, List, Literal

import yaml
from pydantic import BaseModel, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class PromptSettings(BaseModel):
    base_system_prompt: str
    summarization_prompt: str = ""
    fix_sql_prompt: str = ""
    intent_gatekeeper_prompt: str = ""
    few_shot_examples: str = ""
    role_contexts: Dict[str, str]


class GuardrailSettings(BaseModel):
    dangerous_regex_patterns: List[str]
    blocked_tables: List[str]


class Settings(BaseSettings):
    # Core Application Settings
    environment: Literal["local", "aws-dev", "aws-prod"] = "local"
    max_rows: int = 1000
    default_time_window_days: int = 90

    # YAML Configurations (loaded post-init)
    prompts: PromptSettings | None = None
    guardrails: GuardrailSettings | None = None

    # Database Settings (Local MySQL or AWS RDS)
    db_host: str = "localhost"
    db_port: int = 3306
    db_user: str = "boons_readonly"
    db_password: str = "change-me"
    db_name: str = "boons"
    use_in_memory_executor: bool = False

    # LLM Settings (OpenAI for local, Bedrock for AWS)
    llm_api_key: str = Field(default="", alias="OPENAI_API_KEY")
    llm_model: str = "gpt-4o-mini"
    aws_region: str = "us-east-1"
    bedrock_model_id: str = "anthropic.claude-3-sonnet-20240229-v1:0"
    force_local_rag: bool = False

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

    @property
    def is_aws_environment(self) -> bool:
        return self.environment.startswith("aws")


def load_settings() -> Settings:
    settings = Settings()
    
    # Load YAML files from the project root config/ directory
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    prompts_path = os.path.join(base_dir, "config", "prompts.yaml")
    guardrails_path = os.path.join(base_dir, "config", "guardrails.yaml")

    if os.path.exists(prompts_path):
        with open(prompts_path, "r") as f:
            prompts_data = yaml.safe_load(f)
            settings.prompts = PromptSettings(**prompts_data)
            
    if os.path.exists(guardrails_path):
        with open(guardrails_path, "r") as f:
            guardrails_data = yaml.safe_load(f)
            settings.guardrails = GuardrailSettings(**guardrails_data)
            
    return settings


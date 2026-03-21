import os
import pytest
from unittest.mock import patch
from boons_text_to_sql_agent.config import Settings, load_settings

def test_default_settings():
    """Verify that settings default to 'local' if no environment variables are set."""
    # We use patch.dict to ensure a clean process environment for this test
    with patch.dict(os.environ, {}, clear=True):
        settings = Settings(_env_file=None)
        assert settings.environment == "local"
        assert settings.is_aws_environment is False

def test_environment_override():
    """Verify that the ENVIRONMENT variable correctly overrides the setting."""
    with patch.dict(os.environ, {"ENVIRONMENT": "aws-dev"}, clear=True):
        settings = Settings(_env_file=None)
        assert settings.environment == "aws-dev"
        assert settings.is_aws_environment is True

def test_prod_environment_override():
    """Verify that the ENVIRONMENT variable correctly overrides to aws-prod."""
    with patch.dict(os.environ, {"ENVIRONMENT": "aws-prod"}, clear=True):
        settings = Settings(_env_file=None)
        assert settings.environment == "aws-prod"
        assert settings.is_aws_environment is True

def test_llm_api_key_mapping():
    """Verify that LLM_API_KEY is correctly mapped to the settings."""
    test_key = "sk-test-key-123"
    with patch.dict(os.environ, {"LLM_API_KEY": test_key}, clear=True):
        settings = Settings(_env_file=None)
        assert settings.llm_api_key == test_key

def test_is_aws_environment_property():
    """Verify the is_aws_environment helper property."""
    settings = Settings(environment="aws-dev")
    assert settings.is_aws_environment is True
    
    settings = Settings(environment="local")
    assert settings.is_aws_environment is False

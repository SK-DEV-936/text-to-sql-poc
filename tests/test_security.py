import pytest
from boons_text_to_sql_agent.config import Settings, GuardrailSettings, PromptSettings
from boons_text_to_sql_agent.domain import Scope, Role, SqlQuery
from boons_text_to_sql_agent.infrastructure.security.simple_sql_validator import SimpleSqlValidator

@pytest.fixture
def validator():
    settings = Settings(
        guardrails=GuardrailSettings(
            dangerous_regex_patterns=[], 
            blocked_tables=["users_passwords"]
        ),
        prompts=PromptSettings(
            base_system_prompt="...",
            role_contexts={},
            summarization_prompt="...",
            fix_sql_prompt="..."
        )
    )
    return SimpleSqlValidator(settings)

def test_validate_select_only(validator):
    scope = Scope(role=Role.INTERNAL, merchant_ids=[], max_rows=100)
    
    # Valid
    query = SqlQuery(text="SELECT * FROM orders", parameters={})
    result = validator.validate_and_enforce(scope, query)
    assert "SELECT" in result.text.upper()
    
    # Invalid
    with pytest.raises(ValueError, match="Only SELECT statements are allowed"):
        validator.validate_and_enforce(scope, SqlQuery(text="DROP TABLE orders", parameters={}) )

def test_block_forbidden_tables(validator):
    scope = Scope(role=Role.INTERNAL, merchant_ids=[], max_rows=100)
    query = SqlQuery(text="SELECT * FROM users_passwords", parameters={})
    with pytest.raises(ValueError, match="Access to blocked table 'users_passwords' is forbidden"):
        validator.validate_and_enforce(scope, query)

def test_rls_injection(validator):
    scope = Scope(role=Role.MERCHANT, merchant_ids=[123], max_rows=100)
    query = SqlQuery(text="SELECT * FROM orders WHERE restaurant_id IN (__RLS_MERCHANTS__)", parameters={})
    result = validator.validate_and_enforce(scope, query)
    
    assert "restaurant_id" in result.text
    assert "rls_restaurant_id_0" in result.parameters
    assert "%(rls_restaurant_id_0)s" in result.text
    assert result.parameters["rls_restaurant_id_0"] == 123

def test_limit_clamping(validator):
    scope = Scope(role=Role.INTERNAL, merchant_ids=[], max_rows=50)
    
    # Adds limit
    query = SqlQuery(text="SELECT * FROM orders", parameters={})
    result = validator.validate_and_enforce(scope, query)
    assert "LIMIT 50" in result.text.upper()
    
    # Clamps limit
    query = SqlQuery(text="SELECT * FROM orders LIMIT 1000", parameters={})
    result = validator.validate_and_enforce(scope, query)
    assert "LIMIT 50" in result.text.upper()

def test_validate_union(validator):
    scope = Scope(role=Role.INTERNAL, merchant_ids=[], max_rows=100)
    query = SqlQuery(text="SELECT 1 UNION ALL SELECT 2", parameters={})
    result = validator.validate_and_enforce(scope, query)
    assert "UNION ALL" in result.text.upper()

def test_syntax_error_handling(validator):
    scope = Scope(role=Role.INTERNAL, merchant_ids=[], max_rows=100)
    query = SqlQuery(text="SELECT * FROM orders WHERE WRONG SYNTAX", parameters={})
    with pytest.raises(ValueError, match="Invalid SQL syntax"):
        validator.validate_and_enforce(scope, query)

import pytest

from boons_text_to_sql_agent.config import load_settings
from boons_text_to_sql_agent.domain import Role, Scope, SqlQuery
from boons_text_to_sql_agent.infrastructure.security.simple_sql_validator import SimpleSqlValidator


@pytest.fixture
def validator() -> SimpleSqlValidator:
    settings = load_settings()
    return SimpleSqlValidator(settings=settings)


@pytest.fixture
def internal_scope() -> Scope:
    return Scope(role=Role.INTERNAL, merchant_ids=[], max_rows=100)


@pytest.fixture
def merchant_scope() -> Scope:
    return Scope(role=Role.MERCHANT, merchant_ids=[1, 2], max_rows=50)


def test_internal_select_only(validator: SimpleSqlValidator, internal_scope: Scope) -> None:
    query = SqlQuery(text="SELECT * FROM merchants", parameters={})
    result = validator.validate_and_enforce(internal_scope, query)
    
    assert "limit 100" in result.text.lower()
    assert result.parameters == {}


def test_internal_clamps_limit(validator: SimpleSqlValidator, internal_scope: Scope) -> None:
    query = SqlQuery(text="SELECT * FROM merchants LIMIT 500", parameters={})
    result = validator.validate_and_enforce(internal_scope, query)
    
    # Should clamp 500 down to max_rows (100)
    assert result.text.lower().endswith("limit 100")


def test_rejects_non_select(validator: SimpleSqlValidator, internal_scope: Scope) -> None:
    query = SqlQuery(text="UPDATE merchants SET status='inactive'", parameters={})
    with pytest.raises(ValueError, match="Only SELECT statements are allowed."):
        validator.validate_and_enforce(internal_scope, query)


def test_rejects_dangerous_patterns(validator: SimpleSqlValidator, internal_scope: Scope) -> None:
    query = SqlQuery(text="SELECT * FROM merchants; DROP TABLE merchants", parameters={})
    # The updated sqlglot parser throws an invalid syntax error when multiple statements are present
    with pytest.raises(ValueError, match="Only SELECT statements are allowed."):
        validator.validate_and_enforce(internal_scope, query)


def test_merchant_rls_wrapper_applied(validator: SimpleSqlValidator, merchant_scope: Scope) -> None:
    query = SqlQuery(text="SELECT id, name FROM orders WHERE restaurant_id IN (__RLS_MERCHANTS__)", parameters={"existing": "param"})
    result = validator.validate_and_enforce(merchant_scope, query)
    
    text = result.text.lower()
    assert "restaurant_id in (%(rls_restaurant_id_0)s, %(rls_restaurant_id_1)s)" in text
    assert "limit 50" in text

    # Parameters should be preserved and updated
    assert result.parameters["existing"] == "param"
    assert result.parameters["rls_restaurant_id_0"] == 1
    assert result.parameters["rls_restaurant_id_1"] == 2


def test_merchant_fails_without_ids(validator: SimpleSqlValidator) -> None:
    merchant_scope = Scope(
        role=Role.MERCHANT, 
        merchant_ids=[], 
        customer_id=None, 
        max_rows=100, 
        default_time_window_days=90
    )
    query = SqlQuery(text="SELECT * FROM orders", parameters={})

    with pytest.raises(ValueError, match="Merchant role requires at least one merchant_id"):
        validator.validate_and_enforce(merchant_scope, query)


def test_rejects_blocked_tables(validator: SimpleSqlValidator, internal_scope: Scope) -> None:
    query = SqlQuery(text="SELECT * FROM users_passwords", parameters={})
    with pytest.raises(ValueError, match="Access to blocked table 'users_passwords' is forbidden."):
        validator.validate_and_enforce(internal_scope, query)

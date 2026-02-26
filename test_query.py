import asyncio
from boons_text_to_sql_agent.config import load_settings
from boons_text_to_sql_agent.infrastructure.db.in_memory_executor import InMemoryDemoExecutor
from boons_text_to_sql_agent.infrastructure.db.mysql_executor import MySqlExecutor
from boons_text_to_sql_agent.domain import SqlQuery

async def main():
    settings = load_settings()
    if settings.use_in_memory_executor:
        executor = InMemoryDemoExecutor()
    else:
        executor = MySqlExecutor(
            host=settings.db_host, port=settings.db_port,
            user=settings.db_user, password=settings.db_password,
            db_name=settings.db_name
        )
    sql = SqlQuery(text="SELECT COUNT(*) AS total_orders FROM orders WHERE DATE(created_date) = CURDATE();", parameters={})
    try:
        rows = await executor.execute(sql)
        print("Success:", rows)
    except Exception as e:
        print("Error:", type(e), e)

asyncio.run(main())

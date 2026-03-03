from __future__ import annotations

import sqlite3
from dataclasses import dataclass
from typing import Any, Mapping, Sequence

from boons_text_to_sql_agent.application.ports import SqlExecutorPort
from boons_text_to_sql_agent.domain import SqlQuery


class InMemoryDemoExecutor(SqlExecutorPort):
    """SQLite executor for local demos without requiring MySQL/Docker.

    Hosts a fully functioning relational database entirely in memory,
    pre-seeded with merchants, orders, and order_items.
    """

    def __init__(self):
        self.conn = sqlite3.connect(":memory:", check_same_thread=False)
        self.conn.row_factory = sqlite3.Row
        self._seed_database()

    def _seed_database(self) -> None:
        cursor = self.conn.cursor()
        cursor.executescript('''
            CREATE TABLE merchants (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                city TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                status TEXT DEFAULT 'active'
            );
            CREATE TABLE customers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                customer_segment TEXT
            );
            CREATE TABLE orders (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                merchant_id INTEGER NOT NULL,
                customer_id INTEGER,
                order_status TEXT NOT NULL,
                total_amount REAL NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            );
            CREATE TABLE order_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                order_id INTEGER NOT NULL,
                menu_item_id INTEGER NOT NULL,
                quantity INTEGER NOT NULL,
                item_price REAL NOT NULL
            );
            
            INSERT INTO merchants (name, city, status) VALUES
            ('Demo Merchant A', 'San Francisco', 'active'),
            ('Demo Merchant B', 'New York', 'active'),
            ('Demo Merchant C', 'Los Angeles', 'inactive');
            
            INSERT INTO customers (customer_segment) VALUES
            ('new'), ('loyal'), ('churn_risk');
            
            INSERT INTO orders 
                (merchant_id, customer_id, order_status, total_amount, created_at) 
            VALUES
            (1, 1, 'completed', 25.50, date('now', '-1 day')),
            (1, 2, 'completed', 40.00, date('now', '-1 day')),
            (2, 3, 'cancelled', 15.75, date('now', '-1 day')),
            (2, 1, 'completed', 60.10, date('now', '-2 days')),
            (3, 2, 'completed', 10.00, date('now', '-20 days'));
            
            INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
            (1, 101, 2, 10.00),
            (1, 102, 1, 5.50),
            (2, 103, 4, 10.00),
            (3, 104, 1, 15.75),
            (4, 105, 3, 20.03),
            (5, 106, 1, 10.00);
        ''')
        self.conn.commit()

    def _shim_mysql_dates(self, query_text: str) -> str:
        import re
        
        def _replacer(match: re.Match) -> str:
            amount = match.group(1)
            unit = match.group(2).lower()
            if not unit.endswith('s'):
                unit += 's'
            return f"date('now', '-{amount} {unit}')"
            
        pattern = r"(?:NOW\(\)|CURDATE\(\)|CURRENT_DATE(?:\(\))?)\s*-\s*INTERVAL\s+(\d+)\s+([A-Za-z]+)"
        query_text = re.sub(pattern, _replacer, query_text, flags=re.IGNORECASE)
        
        # Also handle standalone NOW() or CURDATE()
        query_text = re.sub(r"\bNOW\(\)", "datetime('now')", query_text, flags=re.IGNORECASE)
        query_text = re.sub(r"\bCURDATE\(\)", "date('now')", query_text, flags=re.IGNORECASE)
        
        query_text = query_text.replace("DATE(", "date(")
        return query_text

    async def execute(self, sql_query: SqlQuery) -> Sequence[Mapping[str, Any]]:
        cursor = self.conn.cursor()
        
        # Shim MySQL date functions to SQLite for the demo
        query_text = self._shim_mysql_dates(sql_query.text)
        
        # Shim MySQL parameter syntax %(param)s to SQLite syntax :param
        import re
        query_text = re.sub(r'%\(([\w_]+)\)s', r':\1', query_text)
        
        cursor.execute(query_text, sql_query.parameters or {})
        rows = cursor.fetchall()
        return [dict(row) for row in rows]

    async def get_active_merchant_ids(self) -> list[int]:
        cursor = self.conn.cursor()
        cursor.execute("SELECT id FROM merchants WHERE status = 'active'")
        rows = cursor.fetchall()
        return [row['id'] for row in rows]


@dataclass
class MySqlExecutor(SqlExecutorPort):
    """Async MySQL executor using a read-only user.

    This implementation expects that SQL text and parameters are safe and
    already validated by the validator layer.
    """

    host: str
    port: int
    user: str
    password: str
    db_name: str
    connect_timeout: float = 3.0
    read_timeout: float = 5.0

    async def execute(self, sql_query: SqlQuery) -> Sequence[Mapping[str, Any]]:
        # Local import to avoid requiring aiomysql for non-DB scenarios.
        import aiomysql  # type: ignore[import]

        params = sql_query.parameters or {}
        sql_text = sql_query.text

        # If a parameters dict is provided, the driver (aiomysql/PyMySQL) will 
        # attempt to format the SQL string using those parameters. 
        # We must escape literal '%' characters as '%%' to avoid errors like
        # "unsupported format character 'Y'".
        if params is not None:
            import re
            # Escape % that is NOT followed by (key)s
            sql_text = re.sub(r'%(?!\()', '%%', sql_text)

        conn = await aiomysql.connect(
            host=self.host,
            port=self.port,
            user=self.user,
            password=self.password,
            db=self.db_name,
            autocommit=True,
            connect_timeout=self.connect_timeout,
            cursorclass=aiomysql.DictCursor,
        )
        try:
            async with conn.cursor() as cursor:
                # Only pass params if it's not empty, otherwise some drivers 
                # might still attempt formatting and fail on escaped '%%'.
                if params:
                    await cursor.execute(sql_text, params)
                else:
                    # If no params, use the original (unescaped) text if possible, 
                    # but since we already escaped it above, we should be consistent.
                    # Actually, if params is empty, we don't need to escape.
                    # Let's refine the logic.
                    await cursor.execute(sql_query.text)
                rows = await cursor.fetchall()
        finally:
            conn.close()

        # aiomysql.DictCursor already returns dict-like rows.
        return list(rows)

    async def get_active_merchant_ids(self) -> list[int]:
        import aiomysql  # type: ignore[import]

        conn = await aiomysql.connect(
            host=self.host,
            port=self.port,
            user=self.user,
            password=self.password,
            db=self.db_name,
            autocommit=True,
            connect_timeout=self.connect_timeout,
            cursorclass=aiomysql.DictCursor,
        )
        try:
            async with conn.cursor() as cursor:
                # Get up to 50 active merchants based on orders table
                await cursor.execute("SELECT DISTINCT customer_id FROM orders WHERE customer_id IS NOT NULL LIMIT 50")
                rows = await cursor.fetchall()
                return [row['customer_id'] for row in rows]
        finally:
            conn.close()



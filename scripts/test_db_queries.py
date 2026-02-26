import sys
import mysql.connector
from datetime import datetime
from boons_text_to_sql_agent.config import load_settings

def run_test_queries():
    settings = load_settings()
    
    print(f"Connecting to MySQL Database at {settings.db_host}:{settings.db_port}...")
    try:
        conn = mysql.connector.connect(
            host=settings.db_host,
            port=settings.db_port,
            user=settings.db_user,
            password=settings.db_password,
            database=settings.db_name
        )
        cursor = conn.cursor(dictionary=True)
        print("Successfully connected to MySQL!\n")
    except Exception as e:
        print(f"Failed to connect to MySQL: {e}")
        print("Please ensure Docker is running and 'docker compose up -d mysql' was successful.")
        sys.exit(1)

    queries = [
        {
            "name": "1. Total orders by type",
            "sql": "SELECT order_status, COUNT(*) as count FROM orders GROUP BY order_status;"
        },
        {
            "name": "2. Catering orders count",
            "sql": "SELECT order_status, COUNT(*) as count FROM catering_orders GROUP BY order_status;"
        },
        {
            "name": "3. Order History events",
            "sql": "SELECT particulars, COUNT(*) as count FROM order_history GROUP BY particulars;"
        },
        {
            "name": "4. Top 3 Restaurants by Regular Order volume",
            "sql": '''
                SELECT od.restaurant_id, SUM(od.total) as total_revenue
                FROM order_details od
                GROUP BY od.restaurant_id
                ORDER BY total_revenue DESC
                LIMIT 3;
            '''
        },
        {
            "name": "5. Top 3 Restaurants by Catering Order volume",
            "sql": '''
                SELECT cod.restaurant_id, SUM(cod.total) as total_revenue
                FROM catering_order_details cod
                GROUP BY cod.restaurant_id
                ORDER BY total_revenue DESC
                LIMIT 3;
            '''
        }
    ]

    for q in queries:
        print(f"--- {q['name']} ---")
        try:
            cursor.execute(q['sql'])
            rows = cursor.fetchall()
            for row in rows:
                print(row)
        except Exception as e:
            print(f"Query Failed: {e}")
        print()

    cursor.close()
    conn.close()

if __name__ == "__main__":
    run_test_queries()

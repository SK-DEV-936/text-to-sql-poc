#!/bin/bash

if [ "$RUN_UI" = "true" ] || [ "$RUN_UI" = "1" ]; then
    PORT=${PORT:-8000}
    echo "--------------------------------------------------------"
    echo "🚀 Starting Streamlit UI on port $PORT..."
    echo "🔧 Env: API_BASE_URL=$API_BASE_URL"
    echo "--------------------------------------------------------"
    exec streamlit run demo_chat.py --server.port "$PORT" --server.address 0.0.0.0
else
    PORT=${PORT:-8000}
    echo "--------------------------------------------------------"
    echo "⚡ Starting FastAPI Backend on port $PORT..."
    echo "🔧 Env: DB_HOST=$DB_HOST, DB_NAME=$DB_NAME"
    echo "--------------------------------------------------------"
    exec uvicorn boons_text_to_sql_agent.main:app --host 0.0.0.0 --port "$PORT"
fi

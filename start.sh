#!/bin/bash

if [ "$RUN_UI" = "true" ] || [ "$RUN_UI" = "1" ]; then
    PORT=${PORT:-8000}
    echo "🚀 Starting Streamlit UI on port $PORT..."
    exec streamlit run demo_chat.py --server.port "$PORT" --server.address 0.0.0.0
else
    PORT=${PORT:-8000}
    echo "⚡ Starting FastAPI Backend on port $PORT..."
    exec uvicorn boons_text_to_sql_agent.main:app --host 0.0.0.0 --port "$PORT"
fi

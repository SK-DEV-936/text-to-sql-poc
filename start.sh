#!/bin/bash

if [ "$RUN_UI" = "true" ] || [ "$RUN_UI" = "1" ]; then
    echo "🚀 Starting Streamlit UI..."
    exec streamlit run demo_chat.py --server.port 8000 --server.address 0.0.0.0
else
    echo "⚡ Starting FastAPI Backend..."
    exec uvicorn boons_text_to_sql_agent.main:app --host 0.0.0.0 --port 8000
fi

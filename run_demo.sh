#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting Boons Text-to-SQL Agent Demo..."

# Cleanup existing processes on ports 8000 and 8501
echo "Cleaning up existing processes on ports 8000 and 8501..."
lsof -ti:8000 | xargs kill -9 2>/dev/null || true
lsof -ti:8501 | xargs kill -9 2>/dev/null || true

# Activate the virtual environment
if [ -d "venv" ]; then
    source venv/bin/activate
else
    echo "Virtual environment 'venv' not found. Please ensure dependencies are installed."
    exit 1
fi

# Define a cleanup function to kill background processes on exit
# Define a cleanup function to kill background processes on exit
cleanup() {
    echo "Shutting down services..."
    kill $BACKEND_PID 2>/dev/null || true
    exit 0
}

# Trap SIGINT (Ctrl+C) and SIGTERM to run the cleanup function
trap cleanup SIGINT SIGTERM EXIT

ROOT_DIR=$(pwd)

# Let the application pick the executor based on .env or defaults
# export USE_IN_MEMORY_EXECUTOR=true

# Start the FastAPI backend in the background
echo "Starting FastAPI backend on port 8000..."
uvicorn boons_text_to_sql_agent.main:app --host 127.0.0.1 --port 8000 &
BACKEND_PID=$!

# Wait briefly for the backend to initialize
echo "Waiting for API to start..."
sleep 2

# Start the Streamlit frontend
echo "Launching Streamlit Chat UI..."
streamlit run demo_chat.py

# When Streamlit exits, the trap will automatically kill the backend.

FROM python:3.11-slim

# Set environment variables for Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Use ARG to allow setting the environment at build time (e.g., --build-arg APP_ENV=aws-dev)
# Default is 'local' if not provided.
# ARG APP_ENV=local
# ENV ENVIRONMENT=${APP_ENV}
# ENV FORCE_LOCAL_RAG=1

WORKDIR /app

# Install system dependencies
# aiomysql and other drivers occasionally require basic build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy python project requirements first to leverage Docker cache
COPY pyproject.toml README.md ./

# Install the application and its production dependencies
# (Excludes FAISS/Pytest because they are local test/dev tools)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir .
    
RUN pip install --no-cache-dir langchain-community faiss-cpu langchain-google-genai
RUN pip install sqlglot

# Copy the core application logic and configuration
COPY boons_text_to_sql_agent/ boons_text_to_sql_agent/
COPY config/ config/
COPY scripts/build_knowledge_base.py scripts/

# Copy FAISS index generated during CodeBuild
# COPY faiss_index/ faiss_index/

# Generate FAISS index inside Docker
ARG LLM_API_KEY
RUN LLM_API_KEY=$LLM_API_KEY python scripts/build_knowledge_base.py
#RUN python scripts/build_knowledge_base.py


# Expose the precise port for AWS Load Balancers / App Runner
EXPOSE 8000

# Start the high-performance Uvicorn server explicitly bound to 0.0.0.0
CMD ["uvicorn", "boons_text_to_sql_agent.main:app", "--host", "0.0.0.0", "--port", "8000"]

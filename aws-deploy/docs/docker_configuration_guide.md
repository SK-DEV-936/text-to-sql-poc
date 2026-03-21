# Docker & Configuration Guide: Boons Text-to-SQL Agent

This document explains the Docker-based deployment strategy and environment configuration for the Boons Text-to-SQL Agent.

## 1. Dockerfile Overview

The `Dockerfile` in the root directory is designed for **portability** and **performance**. It uses a multi-stage approach to keep the image size small while ensuring all dependencies are present.

### Key Sections:
- **Base Image**: `python:3.11-slim` (Balanced for stability and size).
- **System Dependencies**: Installs `build-essential` for compiling database drivers if necessary.
- **Application Logic**: Copies `boons_text_to_sql_agent/` and `config/` into the container.
- **FAISS Index Integration**: The build process (CodeBuild) should generate the `faiss_index/` which is then copied into the image.
- **Production Server**: Uses `uvicorn` to serve the FastAPI application on port `8000`.

---

## 2. Environment Variables

The application's behavior is primarily controlled through environment variables. These can be set in a `.env` file for local development or injected via **AWS App Runner / ECS** service settings for cloud deployments.

### Core Configurations:

| Variable | Default | Purpose |
| :--- | :--- | :--- |
| `ENVIRONMENT` | `local` | Can be `local`, `aws-dev`, or `aws-prod`. Controls features like Bedrock vs. Gemini. |
| `LLM_API_KEY` | (Empty) | The primary API key for LLM services (Gemini or OpenAI compatible). Map from Secrets Manager in AWS. |
| `LLM_MODEL` | `gemini-2.5-pro` | The Gemini model version to use locally. |
| `BEDROCK_MODEL_ID` | `anthropic.claude-3-sonnet-20240229-v1:0` | The Bedrock model ID for production SQL generation. |
| `DB_HOST` | `localhost` | The endpoint for the MySQL database (or RDS endpoint). |
| `DB_PORT` | `3306` | Database connection port. |
| `DB_USER` | `boons_readonly` | Database username (Ensure this is a read-only user in production). |
| `DB_PASSWORD` | `change-me` | Database password. Use Secrets Manager integration in AWS. |
| `DB_NAME` | `boons` | The target database name. |
| `FORCE_LOCAL_RAG` | `1` | Set to `0` in production to use AWS Bedrock Knowledge Base instead of local FAISS. |
| `AWS_REGION` | `us-east-1` | The AWS region for Bedrock and Secrets Manager access. |
| `MAX_ROWS` | `1000` | Safety limit for SQL query result rows. |
| `USE_IN_MEMORY_EXECUTOR` | `False` | Set to `True` to use SQLite fallback for local demos without MySQL. |

---

## 3. Local Development vs. AWS Strategy

### Local Flow:
1. Environment defaults to `local`.
2. Uses `.env` for secrets.
3. Uses local FAISS index for RAG.

### AWS Flow (App Runner / ECS):
1. Environment set to `aws-dev` or `aws-prod`.
2. Secrets are injected via **AWS Secrets Manager** (Refer to [gemini_secrets_setup.md](./gemini_secrets_setup.md)).
3. `FORCE_LOCAL_RAG` is typically set to `0` to leverage Bedrock's scalable knowledge base.

---

## 4. Local Verification Commands

To verify the Docker configuration locally before pushing to ECR:

### Build Image:
```bash
docker build -t boons-agent:latest .
```

### Run with Overrides:
```bash
docker run -p 8000:8000 \
  -e ENVIRONMENT=aws-dev \
  -e GEMINI_API_KEY=YOUR_KEY \
  -e DB_HOST=YOUR_RDS_ENDPOINT \
  boons-agent:latest
```

---

## 5. Security Best Practices

> [!IMPORTANT]
> - **Read-Only Database Access**: Always use a read-only DB user for the agent in Docker to prevent accidental data modification.
> - **Secret Management**: Never bake API keys or passwords directly into the `Dockerfile` or push them to version control.
> - **Image Scanning**: Ensure ECR image scanning is enabled to detect vulnerabilities in the base Python image.

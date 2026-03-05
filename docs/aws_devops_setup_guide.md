# Boons Text-to-SQL Agent: AWS DevOps Setup Guide

This document serves as a comprehensive playbook for the DevOps and Infrastructure teams responsible for deploying the **Boons Text-to-SQL Analytics Agent** into an AWS environment. It maps the project's internal architecture to specific AWS services and provides a step-by-step provisioning guide.

---

## 1. Architecture Overview & Services Mapping

The application is a stateless FastAPI backend that relies heavily on asynchronous connections to a relational database, Retrieval-Augmented Generation (RAG) for business context, and large language models for query generation.

### How the Project Maps to AWS Services

| Project Component | AWS Service | Purpose & Configuration Notes |
| :--- | :--- | :--- |
| **Compute / API Server** | **AWS Lambda** (Containerized) | The "Single Unit" architecture. The FastAPI app runs inside a single Docker image deployed to Lambda. Requires the `aws-lambda-web-adapter` layer to translate API Gateway events to FastAPI ASGI natively. Memory: `2048MB - 4096MB`. Timeout: `60 seconds`. *(Alternative: AWS App Runner or ECS on Fargate for persistent connections).* |
| **Relational Database** | **Amazon RDS (MySQL)** | Stores the actual order and merchant data. Must be MySQL 8.0+. Needs to handle asynchronous connections (`aiomysql`) from the Lambda compute. |
| **Generative AI Details** | **Amazon Bedrock** | Replaces local OpenAI calls. Handles Text-to-SQL generation, self-correction, and final text summarization. **Required Models**: `Claude 3.5 Sonnet` (for generation/reasoning) and `Titan Embeddings G1` (for RAG). |
| **Knowledge Retrieval (RAG)** | **Knowledge Bases for Bedrock** | Replaces local FAISS vector stores. Stores the business synonyms, definitions, and database schema context to teach the LLM the "business language." |
| **Vector Database** | **Amazon OpenSearch Serverless** | Automated backend for the Bedrock Knowledge Base. |
| **Knowledge Storage** | **Amazon S3** | Stores the raw JSON/Markdown schema files and business rules. Bedrock Knowledge Bases sync directly from this bucket to OpenSearch. |
| **Networking** | **Amazon VPC & NAT Gateway** | The Lambda function must be placed in a private subnet. It requires a NAT Gateway to reach the public Bedrock endpoints, and a Security Group that allows it to reach the RDS cluster. |
| **Container Registry** | **Amazon ECR** | Stores the heavy Docker image (containing Python, LangChain, dependencies) for the Lambda deployment. |

---

## 2. Step-by-Step Provisioning Checklist

### Phase 1: Networking & Security Foundation
- [ ] **VPC Provisioning**: Ensure a VPC exists with both Public and Private subnets.
- [ ] **NAT Gateway**: Provision a NAT Gateway in the Public subnet and route the Private subnets' external traffic through it (critical for Lambda reaching Bedrock).
- [ ] **Security Groups**:
  - `sg-lambda-compute`: Outbound allowed to `0.0.0.0/0` (for Bedrock/API access).
  - `sg-rds-database`: Inbound allowed on port `3306` *only* from `sg-lambda-compute`.

### Phase 2: Database (Amazon RDS) Setup
- [ ] **Cluster Creation**: Provision a MySQL 8.0+ RDS Instance or Aurora Serverless v2 cluster in the Private subnets.
- [ ] **Authentication**: Enable **IAM Database Authentication** (recommended) or create a secure, secret-manager-backed password.
- [ ] **User Provisioning**: Ensure the schema is deployed (via `db/init/01-order-schemas.sql`) and a `boons_readonly` user is created with strictly `SELECT` privileges.

### Phase 3: Generative AI (Amazon Bedrock & RAG)
- [ ] **Model Access**: Request/Enable access to **Anthropic Claude 3.5 Sonnet** and **Amazon Titan Embeddings G1 - Text** in the target AWS region via the Bedrock console.
- [ ] **S3 Bucket**: Create a private S3 bucket (e.g., `boons-schema-rag-source-prod`). Upload the database semantic descriptions and synonyms here.
- [ ] **Knowledge Base Creation**: 
  - Create a Bedrock Knowledge Base pointing to the S3 bucket.
  - Allow AWS to automatically provision an OpenSearch Serverless collection.
  - Note the **Knowledge Base ID** (needed for Lambda env vars).
  - *Action*: Trigger a sync in the Bedrock console to embed the S3 files.

### Phase 4: Compute Deployment (Containerized Lambda)
- [ ] **ECR Repository**: Create a private ECR repository (e.g., `boons-text-to-sql-agent`).
- [ ] **Docker Build**: Build the `Dockerfile` and push it to the ECR repo.
- [ ] **Lambda Function**:
  - Create a new Lambda function from the ECR Container Image.
  - **Memory/Timeout**: Set Memory to `2048 MB` and Timeout to `60 seconds` (LLM generations are slow).
  - **Layer**: Attach the `aws-lambda-web-adapter` extension layer for your region (allows FastAPI to run natively).
  - **VPC Configuration**: Attach the Lambda to the Private Subnets and assign `sg-lambda-compute`.
- [ ] **API Gateway**: Attach an API Gateway (HTTP API) triggering the Lambda.

### Phase 5: CI/CD Pipeline Integration
- [ ] **Automated Deployments**: Configure AWS CodePipeline or GitHub Actions to:
  1. Build the Docker image.
  2. Push to ECR.
  3. `aws lambda update-function-code` to push the new image version to the existing function.

---

## 3. Environment Variables (Required on Lambda)

The application code uses the `ENVIRONMENT` flag to dynamically switch infrastructure connectors. The DevOps team must inject these variables into the Lambda configuration:

```env
# Tells the app to use Bedrock/AWS instead of local OpenAI/FAISS
ENVIRONMENT="aws-prod" # (or "aws-dev")

# Database Connection
DB_HOST="your-rds-cluster-endpoint.rds.amazonaws.com"
DB_PORT="3306"
DB_USER="boons_readonly"
DB_PASSWORD="your-secure-password" # Omit if using IAM Auth (Requires app-side IAM token generation)
DB_NAME="boons"

# Bedrock RAG
BEDROCK_KB_ID="ABCDEF1234" # The specific ID from the created Bedrock Knowledge Base

# Security
# Depending on FastAPI configuration, CORS origins might need to be set
```

## 4. Alternative: ECS on Fargate

If Lambda's 60-second limit or connection management becomes an issue under heavy load, the exact same Docker image can be deployed to **AWS App Runner** or **AWS ECS on Fargate**. 
- *Why change?* ECS maintains persistent connections (no cold starts) and avoids potential API Gateway 29-second hard timeouts for extremely complex analytical queries. The environment variables and RDS/Bedrock steps remain exactly the same.

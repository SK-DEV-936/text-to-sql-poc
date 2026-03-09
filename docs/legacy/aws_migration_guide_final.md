# AWS Production Migration: "Single Unit" Deployment Guide

This document describes the definitive, streamlined strategy for migrating the Boons Analytics Agent to AWS. It is intended for both Infrastructure and Development teams to ensure a clean, performant handover.

---

## 🏗️ Core Strategy: The "Single Unit" Lambda
To minimize operational complexity and eliminate internal network latency, we deploy the entire Text-to-SQL engine as a **Single Unit** inside a single AWS Lambda function.

### What is the "Single Unit"?
Instead of splitting the engine into microservices, we package everything into one Docker image:
1.  **FastAPI Backend**: Handles all incoming API requests.
2.  **AI Orchestrator**: Manages SQL generation, self-correction, and final summarization.
3.  **Security Layer**: The mandatory RLS Token Validator (`__RLS_MERCHANTS__`).
4.  **Database Layer**: Asynchronous connection management to AWS RDS.

**Why this approach?** Use of a single unit eliminates "cold start" chains and ensures that the **Self-Correction Retry Loop** (fixing SQL on the fly) is as fast as possible.

---

## � Phase 1: Infrastructure (Infra Team)

### 1.1 VPC & Networking
- **Lambda Subnets**: Deploy the Lambda function in **Private Subnets**.
- **Outbound Access**: Private subnets must have a **NAT Gateway** to allow the Lambda to call Amazon Bedrock and OpenAI APIs.
- **RDS Connectivity**: Configure the RDS Security Group to allow inbound traffic from the Lambda's Security Group on port 3306.

### 1.2 Database (RDS)
- **Engine**: MySQL 8.0+.
- **User Setup**: Create a `boons_readonly` user. 
- **Security**: It is highly recommended to use **IAM Database Authentication** for the Lambda-to-RDS connection.
- **Init**: Run the schemas in `db/init/01-order-schemas.sql` to initialize the production tables.

### 1.3 Amazon Bedrock
- **Model Access**: Ensure the AWS account has access to **Claude 3.5 Sonnet** and **Titan Embeddings G1**.
- **Knowledge Base**: Set up a Bedrock Knowledge Base and point its Data Source to the S3 bucket where you will store schema documentation.

---

## 🚢 Phase 2: Deployment (Dev Team)

### 2.1 Containerized Lambda
- **Base Image**: Build the application using the existing `Dockerfile`.
- **Lambda Web Adapter**: Add the official `aws-lambda-web-adapter` layer to the Lambda function. This allows the existing FastAPI application to run on Lambda without any code changes.
- **Compute Allocation**: 
    - **Memory**: Set to **2048MB - 4096MB**.
    - **Timeout**: Set to **60 seconds** to account for complex query generation and execution.

### 2.2 Configuration (.env)
Set the following environment variables in the Lambda configuration:
- `ENVIRONMENT`: "aws-prod" or "aws-dev".
- `DB_HOST`: The RDS Endpoint.
- `BEDROCK_KB_ID`: The unique ID for your Bedrock Knowledge Base.

---

## 🔄 Phase 3: CI/CD & Verification

### 3.1 Deployment Automation
- Use **AWS SAM** or **AWS CDK** to manage the stack.
- Configure **AWS CodePipeline** to rebuild the Docker image and update the Lambda function upon pushes to the main branch.

### 3.2 Security Validation
- **Token Check**: Verify that every merchant request includes the `__RLS_MERCHANTS__` token.
- **Data Isolation**: Confirm that the `SimpleSqlValidator` correctly replaces this token with verified merchant IDs, ensuring no data leakage between restaurants.

# Boons Text-to-SQL Agent: AWS App Runner Deployment Guide

This document provides instructions for deploying the Boons AI agent to **AWS App Runner**. This replaces previous EKS-based documentation.

## 1. Prerequisites (Infrastructure Dependencies)

Before creating the App Runner service, ensure the following are provisioned:
1. **Amazon RDS (MySQL):** An accessible RDS instance holding the `boons` database.
2. **Amazon ECR Repository:** A registry named `boons-agent` to store the Docker images.
3. **IAM Access Role:** A role that App Runner will use to:
   - Access the ECR image.
   - Access AWS Bedrock APIs (for production RAG).
   - Access AWS Secrets Manager (for `GEMINI_API_KEY` and DB credentials).

---

## 2. CI/CD Build & Deployment Pipeline

The core deployment flow is:
1. **Build Docker Image:** Using the `Dockerfile` in the root directory.
2. **Push to ECR:** Tag and push the image to your repository.
3. **App Runner Service Update:** Trigger a new deployment in App Runner.

### 2.1 Build and Push:
```bash
# Authenticate to ECR
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com

# Build and Tag
docker build -t boons-agent .
docker tag boons-agent:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/boons-agent:latest

# Push
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/boons-agent:latest
```

---

## 3. App Runner Service Configuration

You will deploy **two** App Runner services using the exact same ECR Docker image: one for the backend API, and one for the Streamlit UI.

### Service 1: FastAPI Backend (API)
1. **Source & Deployment:** Select your ECR repository.
2. **Runtime & Port:** Managed Container, Port `8000`.
3. **Start Command:** Leave blank (uses Dockerfile default `uvicorn`).
4. **Environment Variables:**
   - `ENVIRONMENT`: `aws-prod` or `aws-dev`
   - `DB_HOST`: Your RDS endpoint
   - `FORCE_LOCAL_RAG`: `0` for production
5. **Secrets (Crucial):** Inject `LLM_API_KEY` and `DB_PASSWORD` from AWS Secrets Manager.

### Service 2: Streamlit UI
1. **Source & Deployment:** Select the *same* ECR repository.
2. **Runtime & Port:** Managed Container, Port `8000`.
3. **Start Command:** Leave blank (the `start.sh` script handles routing automatically via `RUN_UI`).
4. **Environment Variables:**
   - `RUN_UI`: `true` (This tells the Docker container to launch Streamlit instead of FastAPI)
   - `API_BASE_URL`: **Set this to the App Runner URL of Service 1** (e.g., `https://<api-id>.awsapprunner.com`).
   
   *Example of Environment Variable Configuration (AWS CLI / CloudFormation):*
   ```json
   {
       "RUN_UI": "true",
       "API_BASE_URL": "https://abc123xyz.us-east-1.awsapprunner.com"
   }
   ```

5. **Secrets:** (No secrets required for the UI, it communicates with the secured API).

> [!TIP]
> Refer to [llm_secrets_setup.md](./llm_secrets_setup.md) for detailed steps on setting up the secret in AWS Secrets Manager.

---

## 4. Verification

Once the service status is **Running**:
1. Get the **Service URL** from the App Runner console.
2. Test the connection:
```bash
curl -X POST https://<app-runner-url>/text-to-sql \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, is the database connected?", "role": "internal", "merchant_ids": []}'
```

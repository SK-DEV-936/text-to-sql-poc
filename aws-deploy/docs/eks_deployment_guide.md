# Boons Text-to-SQL Agent: AWS EKS Deployment Guide for DevOps

This document provides complete instructions for the DevOps or SRE team to deploy the Boons AI agent across all three environments (`aws-dev`, `aws-qa`, `aws-prod`) into Amazon EKS.

## 1. Prerequisites (Infrastructure Dependencies)

Before applying the Kubernetes manifests, the following AWS infrastructure must be provisioned per environment:
1. **Amazon RDS (MySQL):** An accessible RDS instance holding the `boons` database. Keep note of the endpoint, port, and read-only credentials.
2. **Amazon ECR Repository:** A registry named `boons-agent` to store the Docker images.
3. **Amazon Bedrock Knowledge Base:** 
   - S3 Bucket deployed containing the split-file RAG schema definitions.
   - Bedrock Knowledge Base provisioned and synced, generating a valid `BEDROCK_KB_ID`.
4. **AWS IAM Role (IRSA):** Create an IAM Role for the Kubernetes ServiceAccount (`boons-agent-sa`) that contains:
   - `AmazonBedrockFullAccess` (or scoped equivalent for Claude and Knowledge Base Retrieve APIs).
5. **AWS Load Balancer Controller:** Must be installed on the EKS cluster for the `Ingress` object to provision an ALB.

---

## 2. CI/CD Build & Deployment Pipeline (Docker + S3 RAG Storage)

To eliminate DevOps overhead, we have created an automated **Single-Click Deployment Pipeline Script** that simultaneously handles:
1. Dynamically parsing the SQL databases to generate `.md` schemas (`auto_generated/`).
2. Building the highly optimized FastAPI container (`Dockerfile`).
3. Tagging and pushing the final container up to Amazon ECR.
4. Uploading both the human logic and AI-generated logic directly to Amazon S3.

### 2.1 Prepare the Data & Configurations:
Before executing the script, the Data Engineers and DevOps team MUST execute the following prerequisites:
1. **Prepare Database Schemas:** Copy all relevant `.sql` schema files (e.g., `orders.sql`, `users.sql`) directly into the `aws-deploy/db/init/` directory. The AI will scan this exact folder.
2. **Review Manual Rules:** If the business has custom logical definitions (like "dinner hours"), place them meticulously inside `aws-deploy/knowledge/manual_business_rules.md`.
3. **Configure AWS Identity:** Ensure your terminal is authenticated to an AWS CLI profile that has rights to write to ECR and S3.

### 2.2 Execute the Pipeline Trigger:
Open `aws-deploy/scripts/deploy_aws_pipeline.sh` and populate your specific variables (`AWS_ACCOUNT_ID`, `S3_BUCKET_NAME_PREFIX`). Then simply run the script from the root of the project, explicitly passing your target environment (`dev`, `qa`, or `prod`):
```bash
./aws-deploy/scripts/deploy_aws_pipeline.sh qa
```

### After Execution:
Once the pipeline pushes everything successfully up to AWS:
1. Log into your **AWS Bedrock Console**.
2. Navigate to your Knowledge Base and strictly click the **"Sync"** button so it digests the newly uploaded markdown schemas.
3. Once synced, copy the resulting `BEDROCK_KB_ID` so you can inject it into your Kubernetes ConfigMaps in the next section!

---

## 3. Kubernetes Deployment (By Environment)

All declarative manifests are separated into environment-specific folders. Choose the target environment (`k8s/aws-dev/`, `k8s/aws-qa/`, `k8s/aws-prod/`).

### Step 1: Apply Namespace & ConfigMap
The `ConfigMap` controls the application's runtime variables. Ensure the `BEDROCK_KB_ID` and `DB_HOST` are correct for this environment.
```bash
kubectl apply -f aws-deploy/k8s/aws-dev/namespace.yaml
kubectl apply -f aws-deploy/k8s/aws-dev/configmap.yaml
```

### Step 2: Inject Secrets
Database passwords and API keys should **never** be hardcoded in Git. 
Either rely on AWS Secrets Manager (via the External Secrets Operator) or manually apply the `secret.yaml` (populated securely by the CI/CD pipeline):

> [!CAUTION]
> **Data Loss Prevention:** The database credentials provided in this Secret MUST belong to a strictly **Read-Only** user. The AI Agent must have absolute zero capability to mutate or drop tables.

```bash
kubectl apply -f aws-deploy/k8s/aws-dev/secret.yaml
```

### Step 3: Apply the Deployment
This file provisions the pods, sets resource requests/limits (critical for LLM orchestration), attaches the IRSA IAM Role for Bedrock, and configures Liveness/Readiness probes.
*(Before applying, ensure the `image:` tag points to the correct ECR URI)*.
```bash
kubectl apply -f aws-deploy/k8s/aws-dev/deployment.yaml
```

### Step 4: Expose via Service and Ingress
This will create a TargetGroup and an Application Load Balancer (ALB) to expose port 8000 to the outside world.
```bash
kubectl apply -f aws-deploy/k8s/aws-dev/service.yaml
kubectl apply -f aws-deploy/k8s/aws-dev/ingress.yaml
```

---

## 4. Verification

After the deployment passes health checks, test the agent connection end-to-end:
```bash
# 1. Get the assigned ALB endpoint
kubectl get ingress boons-agent-ingress -n boons-agent

# 2. Issue a health check or a sample query (replace ALB_DNS)
curl -X POST http://<ALB_DNS>/text-to-sql \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, are you connected?", "role": "internal", "merchant_ids": []}'
```
If the API successfully responds, the EKS pods have correctly established communication with both AWS Bedrock and AWS RDS!

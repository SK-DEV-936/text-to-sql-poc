# GCP Migration Strategy: Boons Text-to-SQL

This document outlines the strategy for migrating the `boons-text-to-sql-agent` from its current AWS environment to **Google Cloud Platform (GCP)**. 

---

## 1. Why Consider GCP?
While AWS is an excellent infrastructure provider, GCP offers specific advantages for this project because the "brain" (Gemini) is a native Google product:

1.  **Lower Latency**: Running the agent in **Cloud Run** (GCP) puts it in the same physical data centers as the **Vertex AI Gemini** models. This removes cross-cloud network hops.
2.  **Simplified Authentication**: No more managing API keys via Secrets Manager. You can use **Service Account Impersonation** to talk to Gemini securely.
3.  **Vertex AI Ecosystem**: Access to advanced tools like **Vertex AI Search** (a managed RAG service that is highly optimized for Gemini) and **Vertex AI Pipelines**.
4.  **Consolidated Billing**: If your AI spend is on Google, having your hosting spend there too can simplify financial management.

---

## 2. Service Mapping: AWS to GCP
The current "Clean Architecture" makes the migration straightforward. Here is the 1:1 service mapping:

| Project Need | AWS Component (Current) | GCP Component (Equivalent) |
| :--- | :--- | :--- |
| **Compute** | AWS App Runner | **Cloud Run** |
| **Database** | Amazon RDS MySQL | **Cloud SQL for MySQL** |
| **Secrets** | AWS Secrets Manager | **Secret Manager** |
| **Container Registry**| Amazon ECR | **Artifact Registry** |
| **AI LLM** | Bedrock / Gemini API | **Vertex AI Gemini** |
| **Vector Search** | Local FAISS | **Local FAISS / Vertex AI Search** |
| **Observability** | CloudWatch | **Cloud Logging / Monitoring** |

---

## 3. Migration Roadmap (4 Steps)

### Step 1: Data Migration
- Export the **MySQL schema and seed data** from RDS.
- Re-import into a **Cloud SQL for MySQL** instance in the same region.

### Step 2: Secret Management
- Move the `DB_PASSWORD` and other keys into **GCP Secret Manager**.
- Grant the Cloud Run service account `secretmanager.versions.access` permission.

### Step 3: Container Deployment
- Build the Docker image locally.
- Authenticate with `gcloud` and push to **GCP Artifact Registry**.
- Deploy to **Cloud Run** using the `gcloud run deploy` command.

### Step 4: LLM Transition
- Update the `infrastructure/llm` adapter to use the `langchain-google-vertexai` package instead of the generic `google-generativeai` package. This allows for native IAM-based authentication.

---

## 4. Architectural Impact
Because you are using **Local FAISS** today, your RAG logic **does not need to change**. You simply copy the `faiss_index` folder into your new Docker image, and it will run exactly as it does on AWS.

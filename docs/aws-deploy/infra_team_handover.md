# AWS Infrastructure Team: Deployment Requirements

This document outlines the infrastructure requirements to deploy the **Boons Text-to-SQL Analytics Agent** into any AWS environment (Dev, QA, or Prod). 

The application has been packaged and configured for a fully automated, Serverless deployment using AWS SAM (AWS Lambda + Amazon API Gateway). It is designed to act as a single, discrete compute unit that can be deployed into your existing VPC.

## Your Action Required
To deploy the agent, we need you to populate the environment-specific configuration files located in this directory:
- `config.dev.json`
- `config.qa.json`
- `config.prod.json`

Because the application is fully containerized, populating these files is the **only** infrastructure action required. Once filled, our deployment pipeline will read these files to automatically provision the compute resources.

---

## Configuration Requirements Explained

Here is an explanation of every field requested in the `config.*.json` files and why the application needs it.

### 1. Network Configuration (`vpc_config`)
The AI agent translates natural language into SQL and then executes those queries against the Boons MySQL database. Therefore, the compute lambda must run inside the same Virtual Private Cloud (VPC) as the database.
*   `subnet_ids`: Provide at least two **Private Subnets**. The Lambda function must be placed in private subnets (no direct route to an Internet Gateway) for security.
*   `security_group_ids`: Provide the ID of a Security Group that will be attached to the Lambda. **Crucially, your RDS Database's Security Group must allow inbound TCP traffic on port 3306 originating from this Lambda Security Group.**

### 2. Database Connectivity (`database_config`)
The agent needs to know how to reach the database and securely authenticate.
*   `rds_host`: The endpoint URL of the Amazon RDS instance for this environment.
*   `rds_port`: Typically `3306` for MySQL.
*   `database_name`: The specific logical database name (e.g., `boons_dev`).
*   `rds_user_secret_arn`: The ARN to an AWS Secrets Manager secret containing the database credentials. 
    *   **Security Note:** We do not hardcode passwords. The Lambda function will pull this secret dynamically at runtime.
    *   **Security Note:** The credentials provided in this secret must be **strictly Read-Only**. The agent is an analytics tool and should have zero capability to alter data.

### 3. AI Permissions (`iam_config`)
The agent uses LangChain to communicate with the Anthropic Claude 3 Sonnet model hosted on Amazon Bedrock.
*   `bedrock_role_arn`: If your organizational policies require you to pre-provision IAM roles, provide the ARN of an IAM Execution Role that possesses the `bedrock:InvokeModel` permission. 
    *   If you leave this string empty `""`, our AWS SAM deployment script will automatically create a new, least-privilege IAM role for the Lambda function.

### 4. API Routing (`api_gateway_config`)
The frontend (e.g., Streamlit web application) will communicate with the Lambda function via HTTP REST calls. We use a Mangum adapter to translate API Gateway events directly into our FastAPI backend.
*   `existing_api_gateway_id`: If you have an existing Amazon API Gateway that you want this microservice attached to (e.g., routed via `/v1/ai/text-to-sql`), provide the REST API ID here.
    *   If you leave this string empty `""`, the deployment script will spin up a brand new, dedicated Amazon API Gateway and output the new URL.

---

Once these JSON files are populated, the primary development team will run the `deploy_aws.sh` pipeline, which will seamlessly containerize the application and deploy it into your secure infrastructure boundaries.

# Boons Text-to-SQL Agent: AWS Infrastructure Deployment Questionnaire

Hello Boons Engineering & DevOps Team,

We are preparing to deploy the **Boons Text-to-SQL Analytics Agent** into your existing AWS infrastructure.

To ensure the agent is highly secure and runs as a single, cost-effective, Serverless unit (AWS Lambda + API Gateway), we need to integrate it with your existing VPC, Database instances, and IAM Roles.

We have fully automated the deployment process. You simply need to provide the configuration values requested below, populate an `aws_config.json` file, and run our one-click `./deploy_aws.sh` script.

This document details exactly **what** we need and **why** we need it.

---

## Part 1: Networking & VPC Configuration

The Text-to-SQL Agent utilizes an AI (AWS Bedrock) to convert natural language into database queries. To execute these queries securely, the AWS Lambda function must be placed inside the same Virtual Private Cloud (VPC) where your database lives.

### **1.1 Private Subnets**
*   **What we need:** A list of at least 2 Private Subnet IDs.
*   **Format:** `["subnet-xxxxxxxxxxx", "subnet-yyyyyyyyyyy"]`
*   **Why we need it:** AWS Lambda requires multiple subnets across different Availability Zones (AZs) for high availability. These **must** be private subnets (no direct route to an Internet Gateway) to ensure the agent's compute environment cannot be publicly accessed.

### **1.2 Security Group IDs**
*   **What we need:** A Security Group ID to attach to the Lambda function.
*   **Format:** `["sg-xxxxxxxxxxxxxxxxx"]`
*   **Why we need it:** When the Lambda function attempts to connect to the MySQL database, your Database's Security Group must allow incoming traffic from this specific Lambda Security Group on port 3306. 

---

## Part 2: Database Configuration

The agent requires an endpoint to connect to your existing relational database, as well as a pre-provisioned read-only credential set.

> [!IMPORTANT]
> **Security Requirement:** Please ensure the database credentials provided belong to a strictly **Read-Only user**. The application uses an AST parser (`sqlglot`) to block destructive queries, but database-level restriction is the ultimate defense.

### **2.1 MySQL RDS Host URL**
*   **What we need:** The Amazon RDS endpoint address.
*   **Format:** `"db.xxxxx.us-east-1.rds.amazonaws.com"`
*   **Why we need it:** This is where the agent routes the generated SQL queries to fetch aggregated analytics data for the merchants.

### **2.2 Secret Manager ARN (Credentials)**
*   **What we need:** The ARN to an AWS Secrets Manager secret containing the database username and password.
*   **Format:** `"arn:aws:secretsmanager:us-east-1:123456789012:secret:BoonsDbAgentUser-xxxxx"`
*   **Why we need it:** We do not hardcode passwords in configuration files or Lambda environment variables. The agent will dynamically fetch the database credentials at runtime from AWS Secrets Manager using this ARN.

---

## Part 3: AI & Compute Identity (IAM)

The agent needs permission to speak to AWS Bedrock (Claude 3 Sonnet) and the AWS Secrets Manager.

### **3.1 Bedrock Access Role ARN**
*   **What we need:** The ARN of an existing IAM Execution Role OR a Permissions Boundary we are allowed to use.
*   **Format:** `"arn:aws:iam::123456789012:role/BoonsBedrockAgentAccessRole"`
*   **Why we need it:** AWS Lambda needs explicit permission to call `bedrock:InvokeModel` so it can communicate with Claude. If you prefer to have the AWS SAM template create the role automatically, please leave this blank. 

---

## Part 4: API Gateway & Exposing the Agent

Our deployment uses the `Mangum` adapter. This allows AWS to take standard HTTP requests and pipe them directly into our FastAPI backend running inside the Lambda function container.

### **4.1 Do you already use Amazon API Gateway?**
*   **If Yes:** We can configure our AWS SAM template to attach the new Text-to-SQL Lambda function as a new route (e.g., `POST /v1/ai/text-to-sql`) on your existing API Gateway.
    *   *Please provide:* Your existing **API Gateway REST API ID**.
*   **If No:** Our default `./deploy_aws.sh` script will automatically spin up a brand new dedicated Amazon API Gateway. 
    *   *Please note:* If we create a new one, we will need to coordinate with your frontend team to update the Streamlit/Web application with the new endpoint URL.
*   **Alternative:** If you use Application Load Balancers (ALB) instead of API Gateway to route to Lambda, let us know and we will adjust the Serverless template to attach to an ALB Target Group instead.

---

## Next Steps

Once you have gathered this information, please place it into the `aws_config.json` template at the root of the repository:

```json
{
  "subnet_ids": [
    "subnet-xxxxxxxxxxx", 
    "subnet-yyyyyyyyyyy"
  ],
  "security_group_ids": [
    "sg-xxxxxxxxxxxxxxxxx"
  ],
  "rds_host": "db.xxxxx.us-east-1.rds.amazonaws.com",
  "rds_user_secret_arn": "arn:aws:secretsmanager:...",
  "bedrock_role_arn": "arn:aws:iam::123456789012:role/...",
  "existing_api_gateway_id": "xxxxx (Leave blank if you want us to create one)"
}
```

### How This Fits Into Boons Infrastructure
When this configuration is provided, running `./deploy_aws.sh` will:
1.  Package the Python LangChain FastAPI app into a Docker container.
2.  Push that container to AWS ECR.
3.  Spin up an AWS Lambda function inside your secured VPC (using the subnets and security groups provided) so it can reach your RDS securely.
4.  Attach the Lambda to either your existing API Gateway or a new one, making the `POST /text-to-sql` endpoint available to your internal tools and frontend applications.

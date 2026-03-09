# AWS Deployment Architecture Analysis: Boons Text-to-SQL Agent

This document evaluates the architectural options for deploying the `boons-text-to-sql-agent` (a FastAPI application heavily reliant on Generative AI, LangChain, and persistent MySQL database routing) to Amazon Web Services (AWS).

## Workload Characteristics
Before selecting a compute platform, we must define the system's unique requirements:
1.  **Heavy Dependencies:** The Python environment includes `langchain`, `openai`, `pydantic`, `fastapi`, and database drivers. This package size exceeds standard limitations.
2.  **Long-Running Executions:** LLM generations (especially planning, executing SQL, and summarizing results) frequently take 5 to 30+ seconds depending on API latency and generation length.
3.  **Relational Database State:** The agent establishes a stateful connection to a MySQL database to execute actual queries.

---

## Approach 1: AWS ECS on Fargate (Enterprise Recommendation)
**Concept:** Package the entire FastAPI application as a Docker container, push it to AWS ECR, and run it continuously on Elastic Container Service (ECS) using serverless Fargate compute.

> [!TIP]
> **Expert View:** This is the industry standard for production-grade Machine Learning APIs because it supports persistent database connections and avoids API gateway timeout limits.

### Pros
*   **No Cold Starts:** The container remains active in memory. The first user request of the day is as fast as the 1000th.
*   **Connection Pooling:** The FastAPI app can establish and safely pool persistent connections to the MySQL RDS instance, reducing connection handshake latency and preventing database exhaustion.
*   **No Hard Timeouts:** Unlike API Gateway, an Application Load Balancer (ALB) fronting ECS can support much longer idle timeouts (e.g., 60-120 seconds), accommodating slow LLM generations safely.
*   **Infinite Package Size:** Docker images can be gigabytes in size without issue.

### Cons
*   **Complexity:** Requires provisioning a VPC, Subnets, Security Groups, an ALB, and ECS Task Definitions via Infrastructure as Code (e.g., Terraform or AWS CDK).
*   **Baseline Cost:** You pay for the container's CPU/Memory 24/7 (around $15-$40/month minimum), regardless of user traffic.

---

## Approach 2: AWS App Runner (Fastest Setup)
**Concept:** A fully-managed "Platform as a Service" (PaaS) by AWS. You provide the Docker image, and AWS automatically handles the load balancer, auto-scaling, and TLS certificates.

> [!NOTE]
> **Expert View:** The best choice for teams that want the benefits of a robust containerized architecture without managing VPCs, load balancers, or ECS task definitions.

### Pros
*   **Painless Setup:** Can be deployed via the AWS UI in 5 minutes.
*   **Native Docker Support:** Runs the exact same `Dockerfile` you use locally.
*   **Auto-scaling built-in:** Automatically spins up more container instances if concurrent request volume spikes.
*   **Supports Persistent Connections:** Better suited for MySQL than ephemeral Lambda functions.

### Cons
*   **Network Isolation:** Integrating App Runner securely with a private RDS database in a VPC requires configuring an App Runner VPC Connector, which can be slightly tedious.
*   **Cost Scaling:** While easy to use, it can become more expensive than tuned ECS Fargate at very high traffic volumes.

---

## Approach 3: AWS Lambda "Lambdalith" (Original Proposal)
**Concept:** Use the `mangum` library to map API Gateway HTTP requests to the FastAPI ASGI loop. Package the massive dependencies as a Lambda Container Image to bypass the 250MB `.zip` limit.

> [!WARNING]
> **Expert View:** Deploying LLM agents on Lambda introduces severe architectural risks due to hard timeouts and connection exhaustion, despite the appealing "scale-to-zero" cost model.

### Pros
*   **Scale-to-Zero pricing:** You only pay for the exact milliseconds the code is executing. If traffic is 0, cost is $0.
*   **Massive Parallel Scaling:** Lambda can instantly spin up 1,000 concurrent environments if a traffic spike hits.

### Cons (Critical Risks)
*   **The 29-Second Hard Timeout:** Amazon API Gateway enforces a strict 29-second maximum integration timeout. If the OpenAI API takes 30 seconds to generate a complex financial summary, API Gateway will sever the connection and return a `504 Gateway Timeout` to the user, *even if the Lambda function successfully finishes the query 1 second later*.
*   **Database Connection Storms:** If 100 concurrent users request a query, AWS Lambda instantly spins up 100 isolated environments. Each environment will attempt to open a brand-new connection to the MySQL database. This causes a "Connection Storm" that can easily crash a standard RDS instance.
*   *(Mitigation)*: You MUST implement **AWS RDS Proxy** to pool connections in front of the database, significantly increasing architectural complexity and cost.
*   **Cold Starts:** Even when using Lambda Container Images, the time taken to boot the Python environment, load LangChain, and initialize the database connection can add 3-6 seconds of latency to the first request.

---

## Executive Summary & Recommendation

1.  If the priority is **minimizing operational overhead** while maintaining a robust, containerized environment that accurately mimics local development, deploy to **AWS App Runner**.
2.  If the priority is **enterprise scalability, security, and fine-grained network control**, deploy to **AWS ECS on Fargate**.
3.  We **strongly advise against AWS Lambda** for this specific architecture due to the heavy reliance on synchronous, long-running LLM API calls which conflict with API Gateway's unchangeable 29-second limit, and the risk of database connection exhaustion.

## Next Steps & Project Status (V2 Completed)

This file captures **where the POC is today** and a suggested sequence of next steps so a future engineer or AI agent can continue seamlessly into V3.

### What works today (V1 & V2 Features)

1. **Production-Ready DB Simulation**: Local MySQL Docker DB with 5000+ seed records spanning regular and catering orders.
2. **Text-to-SQL Pipeline**: End-to-end `POST /text-to-sql` endpoint utilizing LangChain (OpenAI locally, AWS Bedrock compatible).
3. **Firm Security (sqlglot)**: Strict AST parsing guarantees SELECT-only read-only queries and automatically injects Row-Level Security (`merchant_id IN (...)`).
4. **Self-Correction & Fallbacks**: The LLM will catch its own SQL faults and attempt to fix them up to 2 times.
5. **Conversational Memory**: The agent accepts `chat_history` via the Streamlit UI, allowing it to remember follow-up questions and conversational contexts over multi-turn interactions.
6. **Data Visualization**: The `LlmSummarizer` detects aggregation queries and generates valid `Vega-Lite` JSON specifications, which the Streamlit UI natively renders as interactive charts.
7. **Compliance & QA**: A secondary `LlmWatcherAgent` audits the draft summaries to guarantee zero tech-jargon leaks, professional tone, and factual precision against the raw JSON payload.

---

### V3 Roadmap: Proactive Insights & Scalability

Now that the reactive chat agent is fully featured, the next step is shifting from a **pull** model to a **push** model.

#### 1. Proactive Notification Agent
- **Description**: An agent that runs on a `--cron` schedule (e.g., daily at 8 AM).
- **Goal**: It should automatically query the database for anomalies or daily rollups (e.g., "You had 15 cancelled orders yesterday, which is 200% higher than average.") and push a notification or email to the Merchant.
- **Implementation strategy**: 
  - Create a new CLI entrypoint (`proactive_job.py`).
  - Reuse `GenerateAndExecuteQueryService` by passing system-generated `Question` objects.
  - Integrate a basic mocked Email/Webhook Port.

#### 2. Advanced Caching Layer
- **Description**: Currently, the DB is hit on every request.
- **Goal**: Implement a Semantic Caching layer (like Redis or local in-memory dict) that hashes the incoming question intent and returns the previous SQL and Summary if the data hasn't changed.

#### 3. AWS RDS & Bedrock Migration
- **Description**: The code is heavily abstracted, but currently defaults to `local`.
- **Goal**: Provision the actual AWS RDS read replicas and hook the application up to AWS Bedrock using the existing `.is_aws_environment` conditional logic. 
- **Requirement**: Update CI/CD pipelines to CodeCommit.

### How a future agent should continue
1. Read `README.md` at project root.
2. Study `docs/architecture.md` to understand the Multi-Agent flow (Text-to-SQL -> Summarizer -> Watcher).
3. Review `demo_chat.py` to see how the frontend handles state and charts.
4. Begin implementing **V3 Roadmap Item #1** (Proactive Notification Agent).

# DevOps Guide: Configuring LLM API Key in AWS Secrets Manager

This guide describes how to securely store and inject the `LLM_API_KEY` for the Boons Text-to-SQL Agent.

## 1. Create the Secret in AWS Secrets Manager

1.  Log in to the **AWS Management Console**.
2.  Navigate to **Secrets Manager** > **Store a new secret**.
3.  Choose **Other type of secret**.
4.  Enter the following Key/Value pair:
    *   **Key:** `LLM_API_KEY`
    *   **Value:** `[Your Gemini/OpenAI API Key]`
5.  Name the secret (e.g., `boons/agent/llm-api-key`).
6.  Click **Store**.

## 2. AWS App Runner Integration (Recommended)

When configuring your App Runner service:
1.  Go to **Configuration** > **Environment variables**.
2.  Select **Add from Secrets Manager**.
3.  Choose your secret (e.g., `boons/agent/llm-api-key`).
4.  Set the environment variable name to **`LLM_API_KEY`**.
5.  Click **Save and Deploy**.

## 3. Local Development (.env)

For local testing, place the key in your project's `.env` file:
```env
LLM_API_KEY=AIzaSy...
```

---
> [!IMPORTANT]
> The application uses Pydantic to automatically load `LLM_API_KEY` from the environment. No code changes are required for this injection.

# DevOps Guide: Configuring Gemini API Key in AWS Secrets Manager

This guide describes how to securely store and inject the `GEMINI_API_KEY` for the Boons Text-to-SQL Agent.

## 1. Create the Secret in AWS Secrets Manager

1.  Log in to the **AWS Management Console**.
2.  Navigate to **Secrets Manager** > **Store a new secret**.
3.  Choose **Other type of secret**.
4.  Enter the following Key/Value pair:
    *   **Key:** `GEMINI_API_KEY`
    *   **Value:** `[Your Gemini API Key]`
5.  Name the secret (e.g., `boons/agent/gemini-api-key`).
6.  Click **Store**.

## 2. AWS App Runner Integration (Recommended)

When configuring your App Runner service:
1.  Go to **Configuration** > **Environment variables**.
2.  Select **Add from Secrets Manager**.
3.  Choose your secret (e.g., `boons/agent/gemini-api-key`).
4.  Set the environment variable name to **`GEMINI_API_KEY`**.
5.  Click **Save and Deploy**.

## 3. Local Development (.env)

For local testing, place the key in your project's `.env` file:
```env
GEMINI_API_KEY=AIzaSy...
```

---
> [!IMPORTANT]
> The application uses Pydantic to automatically load `GEMINI_API_KEY` from the environment. No code changes are required for this injection.

# Elastic Beanstalk Deployment & Cost Optimization (Streamlit UI)

Due to AWS App Runner's native lack of WebSocket support, the Streamlit UI must be deployed to a service like AWS Elastic Beanstalk (EB). 

## 1. Deployment Steps

1. **Environment Type:** Web server environment.
2. **Platform:** Docker (Amazon Linux 2023).
3. **Application Code:** Provide the same `Dockerfile` and `start.sh` you pushed to Git.
4. **Environment Properties (Variables):**
   - `RUN_UI`: `true`
   - `API_BASE_URL`: `https://<your-app-runner-api-id>.awsapprunner.com`
5. **Instance Type:** `t3.small` (Recommended for minimum Streamlit footprint).
6. **Load Balancer:** Set to **Single Instance** (No ALB) to save ~$16/month, since this is an internal tool.

---

## 2. Scheduled Stop/Start (Cron) for Cost Savings

You can reduce the monthly cost of this Elastic Beanstalk environment from ~$17.00 to roughly **$5.00/month** by "stopping" the environment outside of business hours.

Elastic Beanstalk handles this via **Time-based Auto Scaling**:

1. Go to your Elastic Beanstalk Environment in the AWS Console.
2. Click **Configuration** -> **Capacity** -> Edit.
3. Scroll down to **Time-based scaling** and add two scheduled actions:

### Action 1: "Stop at Night" (e.g., 6:00 PM on Weekdays)
- **Start time:** `0 18 * * 1-5` (Cron expression)
- **Min instances:** `0`
- **Max instances:** `0`
*(This completely terminates the active EC2 instance, dropping compute costs to zero.)*

### Action 2: "Start in Morning" (e.g., 8:00 AM on Weekdays)
- **Start time:** `0 8 * * 1-5`
- **Min instances:** `1`
- **Max instances:** `1`
*(This wakes everything up and provisions a fresh instance automatically right before work starts.)*

> [!NOTE]
> By setting the instance count to `0` instead of deleting the whole environment, you preserve your networking, URLs, and environment variables while saving 100% of the EC2 computing cost.

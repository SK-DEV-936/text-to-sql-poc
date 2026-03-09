#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

ENV_NAME=$1

if [[ ! "$ENV_NAME" =~ ^(dev|qa|prod)$ ]]; then
    echo "❌ ERROR: You must specify a valid environment."
    echo "Usage: $0 <dev|qa|prod>"
    echo "Example: $0 qa"
    exit 1
fi

echo "=========================================================="
echo "🚀 BOONS TEXT-TO-SQL: DEPLOYING TO [ $ENV_NAME ] ENVIRONMENT"
echo "=========================================================="

# ---------------------------------------------------------
# AWS CONFIGURATION VARIABLES 
# (Set these in your terminal, or override them here)
# ---------------------------------------------------------
AWS_REGION=${AWS_REGION:-"us-east-1"}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-"<YOUR_AWS_ACCOUNT_ID>"}
ECR_REPO_NAME=${ECR_REPO_NAME:-"boons-agent"}
S3_BUCKET_NAME=${S3_BUCKET_NAME:-"<YOUR_BUCKET_NAME_PREFIX>-$ENV_NAME"}
IMAGE_TAG="$ENV_NAME"

echo ""
echo "⚠️ PRE-FLIGHT CHECKLIST:"
echo "----------------------------------------------------------"
echo "1. Ensuring all structural SQL schemas are located inside: aws-deploy/db/init/"
echo "2. Ensuring any human logical overrides are inside: aws-deploy/knowledge/manual_business_rules.md"
echo "3. Validating target Kubernetes ConfigMap configuration intended for: aws-deploy/k8s/aws-$ENV_NAME/"
echo "4. Target S3 Bucket: $S3_BUCKET_NAME"
echo "5. Target ECR Registry Image: $ECR_REPO_NAME:$IMAGE_TAG"
echo "6. Confirm terminal is authenticated to AWS Account: $AWS_ACCOUNT_ID in region: $AWS_REGION"
echo "7. CRITICAL SECURITY: Ensure the Kubernetes Secret provides STRICTLY READ-ONLY database access!"
echo ""
read -p "Ready to deploy? Press [Enter] to initiate pipeline or Ctrl+C to abort..."


echo ""
echo "▶ STEP 1: AI SCHEMA INGESTION (RAG RULE GENERATION)"
echo "----------------------------------------------------------"
# Loop through all SQL files in db/init and overwrite the Bedrock schemas in auto_generated/
python aws-deploy/scripts/aws_ingest_schema.py --schema aws-deploy/db/init/ --prompt "Write precise SQL using exact schema mappings."


echo ""
echo "▶ STEP 2: DOCKER IMAGE BUILD"
echo "----------------------------------------------------------"
# Build the highly-optimized Python FastAPI backend container, tagging it for the exact environment
docker build -t $ECR_REPO_NAME:$IMAGE_TAG .


echo ""
echo "▶ STEP 3: ECR AUTHENTICATION & PUSH (Optional/CI Only)"
echo "----------------------------------------------------------"
# To enable automated pushing, uncomment the 3 lines below once your AWS CLI is configured
# aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
# docker tag $ECR_REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG
# docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG
echo "Skipping push... (Uncomment code in deploy script to enable)"


echo ""
echo "▶ STEP 4: AMAZON BEDROCK S3 KNOWLEDGE BASE SYNC"
echo "----------------------------------------------------------"
# To enable automated S3 uploads, uncomment the 2 lines below once your S3 bucket exists
# aws s3 cp aws-deploy/knowledge/manual_business_rules.md s3://$S3_BUCKET_NAME/manual_business_rules.md
# aws s3 sync aws-deploy/knowledge/auto_generated/ s3://$S3_BUCKET_NAME/auto_generated/
echo "Skipping S3 upload... (Uncomment code in deploy script to enable)"


echo ""
echo "✅ PIPELINE EXECUTION COMPLETE!"
echo "If you pushed rules to S3, remember to press 'Sync' on your Knowledge Base in the AWS Bedrock Console."
echo "=========================================================="

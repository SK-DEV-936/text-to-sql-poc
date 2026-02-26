#!/usr/bin/env bash
set -euo pipefail

# Simple helper script to call the POC's /text-to-sql endpoint via curl.
#
# Usage:
#   ./scripts/query.sh "Show top merchants by orders in the last 7 days"
#
# Optional environment variables:
#   API_URL      - defaults to http://localhost:8000/text-to-sql
#   ROLE         - defaults to merchant
#   MERCHANT_IDS - comma-separated list, defaults to 1  (e.g. "1,2,3")

API_URL="${API_URL:-http://localhost:8000/text-to-sql}"
ROLE="${ROLE:-merchant}"
MERCHANT_IDS="${MERCHANT_IDS:-1}"

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 \"your question here\"" >&2
  exit 1
fi

QUESTION="$*"

# Build a simple JSON array from MERCHANT_IDS (comma-separated string).
MERCHANT_IDS_JSON=$(printf '%s\n' "$MERCHANT_IDS" | awk -F',' '{
  printf "[";
  for (i = 1; i <= NF; i++) {
    gsub(/^[ \t]+|[ \t]+$/, "", $i);
    printf "%s%s", (i > 1 ? "," : ""), $i;
  }
  printf "]";
}')

# Note: this naive JSON construction assumes the question does not contain
# double quotes; for typical CLI testing this is sufficient.
JSON_PAYLOAD=$(cat <<EOF
{"role":"$ROLE","merchant_ids":$MERCHANT_IDS_JSON,"question":"$QUESTION"}
EOF
)

curl -sS -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD"


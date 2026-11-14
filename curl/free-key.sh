#!/usr/bin/env bash
# Self-serve a FREE API key (500 calls a month plus 10 PDF extractions, no card, no account).
# The key is shown once — save it. Requires: curl, jq.
# Usage: bash curl/free-key.sh you@company.ro
set -euo pipefail
EMAIL="${1:?Usage: bash curl/free-key.sh you@company.ro}"

curl -s -X POST https://fiscura.ro/api/v1/keys/free \
  -H "content-type: application/json" \
  -d "{\"email\": \"$EMAIL\"}" | jq

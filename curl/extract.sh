#!/usr/bin/env bash
# Extract structured JSON from a PDF invoice (scanned or digital). The numbers
# are copied off the page, then reconciled arithmetically. Requires an API key.
# Requires: curl, jq, base64.   Usage: FISCURA_API_KEY=... bash curl/extract.sh invoice.pdf
set -euo pipefail
: "${FISCURA_API_KEY:?Set FISCURA_API_KEY — get one free at https://fiscura.ro/free-key}"
PDF="${1:?Usage: bash curl/extract.sh path/to/invoice.pdf}"

jq -n --arg b64 "$(base64 < "$PDF" | tr -d '\n')" '{pdfBase64: $b64}' \
  | curl -s -X POST https://fiscura.ro/api/v1/extract \
      -H "Authorization: Bearer $FISCURA_API_KEY" \
      -H "content-type: application/json" -d @- \
  | jq

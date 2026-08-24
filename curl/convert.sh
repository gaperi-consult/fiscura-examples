#!/usr/bin/env bash
# Convert an invoice between UBL and CII. `target` is the syntax to convert TO.
# Requires an API key. Requires: curl, jq.
# Usage: FISCURA_API_KEY=... bash curl/convert.sh [path/to/invoice.xml] [ubl|cii]
set -euo pipefail
: "${FISCURA_API_KEY:?Set FISCURA_API_KEY — get one free at https://fiscura.ro/free-key}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
XML_FILE="${1:-$ROOT/samples/invoice.xml}"
TARGET="${2:-cii}"

jq -n --arg xml "$(cat "$XML_FILE")" --arg t "$TARGET" '{xml: $xml, target: $t}' \
  | curl -s -X POST https://fiscura.ro/api/v1/convert \
      -H "Authorization: Bearer $FISCURA_API_KEY" \
      -H "content-type: application/json" -d @- \
  | jq

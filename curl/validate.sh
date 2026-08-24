#!/usr/bin/env bash
# Validate an e-invoice. FREE — no API key required.
# Prints which EN 16931 / CIUS-RO (BR-RO) rules fail, explained in RO + EN.
# Requires: curl, jq.   Usage: bash curl/validate.sh [path/to/invoice.xml]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
XML_FILE="${1:-$ROOT/samples/invoice.xml}"

jq -n --arg xml "$(cat "$XML_FILE")" '{xml: $xml, profile: "ro", explain: true}' \
  | curl -s -X POST https://fiscura.ro/api/v1/validate \
      -H "content-type: application/json" -d @- \
  | jq

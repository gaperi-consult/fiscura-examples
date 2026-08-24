#!/usr/bin/env bash
# Generate a RO_CIUS UBL 2.1 invoice from structured JSON. Requires an API key.
# The response includes the generated XML plus any rules it still fails (200,
# not a 4xx) — a product outcome, so you get the document AND what to fix.
# Requires: curl, jq.   Get a free key: https://fiscura.ro/free-key
set -euo pipefail
: "${FISCURA_API_KEY:?Set FISCURA_API_KEY — get one free at https://fiscura.ro/free-key}"

curl -s -X POST https://fiscura.ro/api/v1/generate \
  -H "Authorization: Bearer $FISCURA_API_KEY" \
  -H "content-type: application/json" \
  -d '{
    "number": "FCT-2026-001",
    "issueDate": "2026-07-23",
    "dueDate": "2026-08-22",
    "currency": "RON",
    "note": "Factura demo",
    "supplier": {
      "name": "Furnizor Demo SRL", "vatId": "RO13548146", "companyId": "J40/1234/2020",
      "address": { "line1": "Str. Exemplu nr. 1", "city": "Bucuresti", "postalZone": "010101", "countySubentity": "RO-B", "countryCode": "RO" }
    },
    "buyer": {
      "name": "Client Demo SRL", "vatId": "RO12345678", "companyId": "J12/567/2019",
      "address": { "line1": "Bd. Test nr. 22", "city": "Cluj-Napoca", "postalZone": "400001", "countySubentity": "RO-CJ", "countryCode": "RO" }
    },
    "lines": [
      { "description": "Servicii consultanta", "quantity": 10, "unitCode": "HUR", "unitPrice": 100, "vatRate": 19 },
      { "description": "Licenta software", "quantity": 1, "unitCode": "C62", "unitPrice": 500, "vatRate": 19 }
    ],
    "payeeIban": "RO49AAAA1B31007593840000"
  }' | jq

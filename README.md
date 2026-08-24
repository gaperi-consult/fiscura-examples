# Fiscura API — examples

Copy-paste `curl` and JavaScript examples for the **[Fiscura](https://fiscura.ro) e-Factura API** —
**validate**, **generate**, and **convert** Romanian (RO_CIUS) and EN 16931 e-invoices from your
own code, with cryptic rule failures **explained in plain language** (Romanian + English).

- 🌐 **Website & free validator:** <https://fiscura.ro>
- 📖 **API docs:** <https://fiscura.ro/docs>
- 🔑 **Free API key** (100 calls/day, no card): <https://fiscura.ro/free-key>
- 📦 **TypeScript SDK:** [`@gaperi/fiscura-sdk`](https://www.npmjs.com/package/@gaperi/fiscura-sdk)

> Romania's e-Factura is mandatory. Fiscura is the developer API for it: deterministic
> validation on the official EN 16931 + CIUS-RO Schematron, invoice generation and UBL↔CII
> conversion — plus the part every other tool skips: turning `BR-RO-081` into a sentence a
> human can act on.

## Base URL & auth

Base URL is `https://fiscura.ro/api`; every endpoint lives under `/v1`.

Authenticate with your API key on the routes that need one:

```
Authorization: Bearer fisc_live_your_key
# or:  x-api-key: fisc_live_your_key
```

`validate` is **free and needs no key**. `generate`, `convert`, and `extract` need a key —
[grab a free one](https://fiscura.ro/free-key).

## Quickstart — validate an invoice (free, no key)

```bash
# needs: curl, jq  — runs against the sample invoice in this repo
bash curl/validate.sh
```

or in JavaScript (Node 18+, no dependencies):

```bash
node javascript/validate.mjs
```

Both hit `POST /v1/validate` with the [sample invoice](samples/invoice.xml) and print the
failing rules with their explanations, e.g.:

```
valid: false  ·  2 errors, 1 warnings

[BR-RO-081] Adresa Vanzatorului - Linia 1 (BT-35) trebuie furnizata. / Seller address line 1 (BT-35) must be provided.
   fix: cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName
[BR-RO-082] Adresa Cumparatorului - Linia 1 (BT-50) trebuie furnizata. / Buyer address line 1 (BT-50) must be provided.
   fix: cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName
```

(Well-known rule codes get a curated, plain-language explanation; the rest fall back
to the official bilingual message plus the exact path to fix — as above.)

## Endpoints

| Endpoint | Key? | What it does |
|---|---|---|
| `POST /v1/validate` | free | Validate UBL/CII → structured pass/fail on EN 16931 + CIUS-RO, with RO+EN explanations |
| `POST /v1/generate` | ✅ | Structured JSON → RO_CIUS UBL 2.1, self-validated |
| `POST /v1/convert` | ✅ | Convert between UBL and CII |
| `POST /v1/extract` | ✅ (or free, IP-capped) | PDF invoice → structured JSON, reconciled arithmetically |
| `POST /v1/keys/free` | free | Self-serve a free API key (email only) |

A rule failure is a **`200` with `valid: false`** — a product outcome, not a `4xx` — so SDK
clients don't retry or fall back; you get the document plus exactly what to fix.

## What's in here

```
curl/          runnable shell examples (need: curl, jq)
  validate.sh    free — validate the sample invoice
  free-key.sh    get a free API key by email
  generate.sh    JSON → RO_CIUS UBL 2.1     (needs FISCURA_API_KEY)
  convert.sh     UBL ↔ CII                  (needs FISCURA_API_KEY)
  extract.sh     PDF → structured JSON      (needs FISCURA_API_KEY)
javascript/    Node examples
  validate.mjs   plain fetch, no key, no deps
  sdk.mjs        the typed @gaperi/fiscura-sdk (validate · convert · generate)
samples/
  invoice.xml    a minimal RO_CIUS UBL invoice to try things against
```

### Running the keyed examples

```bash
export FISCURA_API_KEY=fisc_live_your_key   # https://fiscura.ro/free-key
bash curl/generate.sh
bash curl/convert.sh samples/invoice.xml cii
```

### TypeScript / JavaScript SDK

```bash
npm install @gaperi/fiscura-sdk
```

```js
import { Fiscura } from "@gaperi/fiscura-sdk";

const fiscura = new Fiscura({ apiKey: "fisc_live_…" });
const res = await fiscura.validate(xml, { profile: "ro" });
console.log(res.valid, res.errors);
```

Full runnable version: [`javascript/sdk.mjs`](javascript/sdk.mjs).

## Notes

- **Standards:** EN 16931 core + CIUS-RO (`ro16931-ubl`); validation runs the official
  Schematron artefacts.
- **Not tax advice.** Fiscura validates and transforms the *format* of e-invoices. It is a
  developer tool, not tax or accounting advice — for your specific situation, consult a
  licensed accountant or ANAF.
- **Questions / issues:** open an issue here, or email **support@fiscura.ro**.

## License

[MIT](LICENSE) — © 2026 Gaperi Consult SRL. Use these snippets freely.

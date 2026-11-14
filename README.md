# Fiscura API — examples

Copy-paste `curl` and JavaScript examples for the **[Fiscura](https://fiscura.ro) e-Factura API** —
**validate**, **generate**, and **convert** Romanian (RO_CIUS) and EN 16931 e-invoices from your
own code, with cryptic rule failures **explained in plain language** (Romanian + English).

- 🌐 **Website & free validator:** <https://fiscura.ro>
- 📖 **API docs:** <https://fiscura.ro/docs>
- 🔑 **Free API key** (500 calls a month plus 10 PDF extractions, no card): <https://fiscura.ro/free-key>
- 📦 **TypeScript SDK:** [`@gaperi/fiscura-sdk`](https://www.npmjs.com/package/@gaperi/fiscura-sdk)

> Romania's e-Factura is mandatory (OUG 120/2021). Fiscura is a developer API for it:
> deterministic validation on the official EN 16931 + CIUS-RO Schematron, invoice generation
> and UBL↔CII conversion, and plain-language explanations of failed rules, so `BR-RO-081`
> becomes a sentence a person can act on, in Romanian and English.

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

Both hit `POST /v1/validate` with the deliberately incomplete [sample invoice](samples/invoice.xml)
and print each failing rule with its explanation. Abridged output of `node javascript/validate.mjs`,
run on 2026-11-14 (the `…` line stands for six more EN 16931 errors):

```
valid: false  ·  10 errors, 0 warnings

[BR-CO-15] The invoice total with VAT (BT-112) does not equal total without VAT (BT-109) plus total VAT (BT-110).
   fix: Set TaxInclusiveAmount = TaxExclusiveAmount + total TaxAmount, rounded to 2 decimals.
…
[BR-RO-081] Seller address line 1 must be provided. ANAF e-Factura requires the complete seller address to verify business identity.
   fix: Add the seller's street address (BT-35), for example: 'Str. Exemplu nr. 10' or 'Calea Victoriei 123'.
[BR-RO-082] Buyer address line 1 must be provided. ANAF e-Factura requires the complete buyer address for invoice validation.
   fix: Add the buyer's street address (BT-50), for example: 'Bulevardul Unirii 45' or 'Piața Romană 8'.
[BR-RO-100] If seller is in Bucharest (country subdivision BT-39 = RO-B), the city name (BT-37) must use SECTOR-RO codes (SECTOR1 through SECTOR6) instead of 'Bucuresti'. This ensures precise location coding for Bucharest's administrative divisions.
   fix: Replace 'Bucuresti' or 'Bucuresti S1' with the correct sector code: 'SECTOR1', 'SECTOR2', 'SECTOR3', 'SECTOR4', 'SECTOR5', or 'SECTOR6' (matching the actual sector where the seller operates).
```

(BR-CO-15 is explained from Fiscura's curated dictionary, so its text is the same on every run.
The other codes in this run were explained by a capped AI model; when the model is unavailable,
the API falls back to the official rule text plus the condition it checks. That wording can
differ between runs; the verdict and the rule codes do not.)

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

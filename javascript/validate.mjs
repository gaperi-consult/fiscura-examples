// Validate an e-invoice with plain `fetch` — FREE, no API key required.
// Run:  node validate.mjs           (Node 18+, uses the built-in fetch)
//
// Validation tells you exactly which EN 16931 / CIUS-RO (BR-RO) rules fail,
// each explained in Romanian and English with a fix.

import { readFile } from "node:fs/promises";

const xml = await readFile(new URL("../samples/invoice.xml", import.meta.url), "utf8");

const res = await fetch("https://fiscura.ro/api/v1/validate", {
  method: "POST",
  headers: { "content-type": "application/json" },
  body: JSON.stringify({ xml, profile: "ro", explain: true }),
});

// NOTE: an invalid invoice is a 200 with `valid: false` — a product outcome,
// not a 4xx — so you never have to retry or fall back.
const result = await res.json();

console.log(`valid: ${result.valid}  ·  ${result.errors.length} errors, ${result.warnings.length} warnings\n`);
for (const e of result.errors) {
  console.log(`[${e.ruleId}] ${e.explanation?.en ?? e.message}`);
  if (e.explanation?.fix) console.log(`   fix: ${e.explanation.fix}`);
}

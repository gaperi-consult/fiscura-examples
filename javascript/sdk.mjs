// Use the typed TypeScript/JavaScript SDK.
//   npm install                         (installs @gaperi/fiscura-sdk)
//   FISCURA_API_KEY=fisc_live_... node sdk.mjs
//
// Get a free key (no card): https://fiscura.ro/free-key

import { Fiscura, FiscuraError } from "@gaperi/fiscura-sdk";
import { readFile } from "node:fs/promises";

const apiKey = process.env.FISCURA_API_KEY;
if (!apiKey) {
  console.error("Set FISCURA_API_KEY — get one free at https://fiscura.ro/free-key");
  process.exit(1);
}

const fiscura = new Fiscura({ apiKey }); // baseUrl defaults to https://fiscura.ro/api
const xml = await readFile(new URL("../samples/invoice.xml", import.meta.url), "utf8");

try {
  // 1) Validate (free) — which rules fail, explained in RO + EN.
  const v = await fiscura.validate(xml, { profile: "ro", explain: true });
  console.log("validate →", v.valid ? "valid" : `${v.errors.length} errors`);

  // 2) Convert UBL → CII (or "ubl" the other way).
  const c = await fiscura.convert(xml, "cii");
  console.log("convert  → produced", c.xml.length, "chars of", c.target.toUpperCase());

  // 3) Generate a RO_CIUS UBL 2.1 invoice from structured data.
  const g = await fiscura.generate({
    number: "FCT-2026-001",
    issueDate: "2026-07-23",
    currency: "RON",
    supplier: { name: "Furnizor Demo SRL", vatId: "RO13548146",
      address: { line1: "Str. Exemplu nr. 1", city: "Bucuresti", countryCode: "RO" } },
    buyer: { name: "Client Demo SRL", vatId: "RO12345678",
      address: { line1: "Bd. Test nr. 22", city: "Cluj-Napoca", countryCode: "RO" } },
    lines: [{ description: "Servicii consultanta", quantity: 10, unitPrice: 100, vatRate: 19 }],
  });
  console.log("generate →", g.valid ? "valid RO_CIUS UBL" : `${g.errors.length} rules to fix`);
} catch (err) {
  if (err instanceof FiscuraError) {
    console.error(`API error ${err.status} (${err.code}): ${err.message}`);
    process.exit(1);
  }
  throw err;
}

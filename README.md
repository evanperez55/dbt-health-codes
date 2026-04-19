# dbt-health-codes

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**MIT-licensed dbt package for US medical code systems.** ICD-10-CM/PCS, HCPCS, CARC, RARC, HIPPS, MS-DRG, NDC, POS — 439,000+ codes — refreshed on every CMS release.

> No CPT codes (AMA-licensed). No SNOMED (non-US redistribution restrictions). No dependencies beyond dbt. Free forever.

## Install

Add to your `packages.yml`:

```yaml
packages:
  - git: "https://github.com/evanperez55/dbt-health-codes.git"
    revision: v0.2.0
```

Then:

```bash
dbt deps
dbt seed --select dbt_health_codes
```

## Quickstart

```sql
-- Look up the description of a code
select description_long
from {{ ref('codes_pos') }}
where code = '11';
-- → "Office"

-- Join claim data to POS descriptions
select
    c.claim_id,
    c.pos_code,
    pos.description_short as pos
from {{ ref('claims') }} c
left join {{ ref('codes_pos') }} pos on c.pos_code = pos.code;
```

Or use the built-in macros:

```sql
-- {{ hc_lookup('POS', '11') }} returns the description of POS code 11
select {{ hc_lookup('POS', '11') }} as office_description;
```

## What's in this package (v0.2.0)

### Code systems — 439,326 codes across 12 systems

| System | Rows | Source | Refresh cadence |
|---|---:|---|---|
| ICD-10-CM (diagnoses) | 98,186 | CDC NCHS | annual Oct + April mid-year |
| ICD-10-PCS (inpatient procedures) | 80,110 | CMS | annual Oct + April mid-year |
| HCPCS Level II | 8,685 | CMS ANWEB | quarterly |
| HCPCS modifiers | 383 | CMS ANWEB | quarterly |
| CARC (Claim Adjustment Reason) | 308 | X12.org | tri-annual (Mar/Jul/Nov) |
| RARC (Remittance Advice Remark) | 1,198 | X12.org | tri-annual |
| MS-DRG (FY2026 v43.1) | 772 | CMS Table 5 | annual Oct + April mid-year |
| NDC (FDA National Drug Code) | 213,454 | FDA | daily upstream, weekly in package |
| HIPPS Home Health | 2,908 | CMS | annual |
| HIPPS SNF | 32,824 | CMS | annual |
| HIPPS IRF | 446 | CMS | annual |
| POS (Place of Service) | 52 | HL7 Terminology | ad-hoc |

Plus **85,143 ICD-10-CM parent/child hierarchy edges** in `codes_icd10cm_hierarchy`.

### Macros

- `hc_lookup(system, code)` — long description for any code in any system
- `hc_parent_of(system, code)` — parent in the hierarchy (ICD-10-CM only so far)
- `hc_drg_weight(code)` — MS-DRG relative weight, for Medicare payment estimation

### dbt tests (ship with the package)

Every seed has `not_null` + `unique` on `code` out of the box. Add your own tests in your project's `schema.yml` as needed.

## Why this package exists

Healthcare data teams re-invent this wheel every quarter. Tuva's docs literally say "users should maintain these themselves." This package eliminates that work.

**Licensing posture:** all codes here are public-domain CMS/FDA data. **No CPT** (AMA license, $500+/seat/yr) — intentionally. Given [Senator Cassidy's 2025 Senate probe of AMA CPT licensing](https://www.cassidy.senate.gov/), CPT-free infrastructure is an increasingly relevant choice.

## Companion API

If you need real-time lookups (sub-100ms) or webhooks on release days, there's a hosted REST API at [codes.neurovai.org](https://codes.neurovai.org). The dbt package and the API share the same underlying ingest pipeline.

- Free tier: [docs.neurovai.org](https://codes.neurovai.org/docs)
- Data quality scorecard (public): [/health/quality](https://codes.neurovai.org/health/quality)

## Status

**v0.2.0** — full code system coverage (12 systems, 439k codes). Tested against Postgres 17 and DuckDB 1.x. Snowflake/BigQuery/Databricks compatibility expected but not yet verified — bug reports welcome.

Roadmap:
- **v0.3.0** — RxNorm + LOINC (once UMLS + Regenstrief licensing is resolved)
- **v0.4.0** — HCPCS-to-NDC crosswalk, concept-map tables, deprecated-code history
- **v1.0.0** — Snowflake/BigQuery/Databricks verified, dbt Hub publication

## License

MIT. See [LICENSE](LICENSE).

## Maintainer

Built by [Evan Perez](https://github.com/evanperez55) at Neurova LLC. Bug reports + PRs welcome.

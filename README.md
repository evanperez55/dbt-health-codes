# dbt-health-codes

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**MIT-licensed dbt package for US medical code systems.** ICD-10-CM/PCS, HCPCS, CARC, RARC, HIPPS, MS-DRG, NDC, POS — 439,000+ codes — refreshed on every CMS release.

> No CPT codes (AMA-licensed). No SNOMED (non-US redistribution restrictions). No dependencies beyond dbt. Free forever.

## Install

Add to your `packages.yml`:

```yaml
packages:
  - git: "https://github.com/evanperez55/dbt-health-codes.git"
    revision: v0.1.0
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

## What's in this package

### Code systems (v0.1.0)

| System | Rows | Source | Refresh |
|---|---|---|---|
| POS (Place of Service) | 52 | HL7 Terminology | ad-hoc |

### Code systems coming in v0.2.0 (ETA May 2026)

| System | Rows | Source | Refresh |
|---|---|---|---|
| ICD-10-CM | ~98k | CDC NCHS | annual Oct + April mid-year |
| CARC (Claim Adjustment Reason Codes) | ~300 | X12.org | tri-annual (Mar/Jul/Nov) |
| RARC (Remittance Advice Remark Codes) | ~1,200 | X12.org | tri-annual |
| HCPCS Level II + modifiers | ~9k | CMS ANWEB | quarterly |
| NDC (National Drug Code) | ~213k | FDA | daily upstream, weekly in package |
| HIPPS (home health / SNF / IRF) | ~36k | CMS | annual |
| MS-DRG (FY2026 v43.1) | 772 | CMS Table 5 | annual Oct + April mid-year |
| ICD-10-PCS | ~80k | CMS | annual Oct + April mid-year |

### Macros

- `hc_lookup(system, code)` — returns the long description for a given code
- More coming in v0.2.0: `hc_parent_of`, `hc_children_of`, `hc_is_billable`, `hc_drg_weight`

### dbt tests

Every seed ships with the following tests out of the box:
- `not_null` on `code` and `description_long`
- `unique` on `(system, code)`
- Referential tests for hierarchy (v0.2.0+)

## Why this package exists

Healthcare data teams re-invent this wheel every quarter. Tuva's docs literally say "users should maintain these themselves." This package eliminates that work.

**Licensing posture:** all codes here are public-domain CMS/FDA data. **No CPT** (AMA license, $500+/seat/yr) — intentionally. Given [Senator Cassidy's 2025 Senate probe of AMA CPT licensing](https://www.cassidy.senate.gov/), CPT-free infrastructure is an increasingly relevant choice.

## Companion API

If you need real-time lookups (sub-100ms) or webhooks on release days, there's a hosted REST API at [codes.neurovai.org](https://codes.neurovai.org). The dbt package and the API share the same underlying ingest pipeline.

- Free tier: [docs.neurovai.org](https://codes.neurovai.org/docs)
- Data quality scorecard (public): [/health/quality](https://codes.neurovai.org/health/quality)

## Status

**v0.1.0** — early access. POS only in this release; full code system coverage ships in v0.2.0 (early May 2026). Star the repo to follow releases.

## License

MIT. See [LICENSE](LICENSE).

## Maintainer

Built by [Evan Perez](https://github.com/evanperez55) at Neurova LLC. Bug reports + PRs welcome.

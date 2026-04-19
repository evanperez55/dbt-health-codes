{# hc_lookup(system, code) → returns the long description of a code.
   Works across all code systems shipped in this package.

   Usage:
     select {{ hc_lookup('POS', '11') }}            -- inline
     where code = '{{ var("admit_code") }}'         -- templated

   Expands to a correlated subquery against the seeded table for `system`.
#}
{% macro hc_lookup(system, code) %}
    (
        select description_long
        from {{ ref('codes_' ~ system | lower) }}
        where code = '{{ code }}'
        limit 1
    )
{% endmacro %}

{# hc_parent_of(system, code) → parent code(s) for a given code.

   Only works for systems with a hierarchy seed (ICD-10-CM in v0.2.0).
   Returns a correlated subquery — use in SELECT or WHERE contexts.

   Usage:
     select {{ hc_parent_of('ICD10CM', 'E11.9') }}   -- → 'E11'
#}
{% macro hc_parent_of(system, code) %}
    (
        select parent_code
        from {{ ref('codes_' ~ system | lower ~ '_hierarchy') }}
        where child_code = '{{ code }}'
        limit 1
    )
{% endmacro %}

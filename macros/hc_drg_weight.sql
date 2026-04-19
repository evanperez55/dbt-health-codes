{# hc_drg_weight(code) → CMS relative weight for an MS-DRG.

   Multiply by the hospital's base rate to estimate Medicare payment.

   Usage:
     select sum({{ hc_drg_weight('drg') }} * discharges) as total_weight
     from {{ ref('claims') }}
#}
{% macro hc_drg_weight(code) %}
    (select weight from {{ ref('codes_msdrg') }} where code = {{ code }})
{% endmacro %}

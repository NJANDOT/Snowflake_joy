{% macro load_bronze() %}

-- Parquet
{{ load_parquet('CALL_CENTER') }}
{{ load_parquet('CATALOG_SALES') }}
{{ load_parquet('CUSTOMER_DEMOGRAPHICS') }}
{{ load_parquet('INCOME_BAND') }}
{{ load_parquet('PROMOTION') }}
{{ load_parquet('STORE') }}
{{ load_parquet('TIME_DIM') }}
{{ load_parquet('WEB_RETURNS') }}

-- CSV
{{ load_csv('CATALOG_PAGE') }}
{{ load_csv('CUSTOMER') }}
{{ load_csv('DATE_DIM') }}
{{ load_csv('INVENTORY') }}
{{ load_csv('REASON') }}
{{ load_csv('STORE_RETURNS') }}
{{ load_csv('WAREHOUSE') }}
{{ load_csv('WEB_SALES') }}

-- JSON
{{ load_json('CATALOG_RETURNS') }}
{{ load_json('CUSTOMER_ADDRESS') }}
{{ load_json('HOUSEHOLD_DEMOGRAPHICS') }}
{{ load_json('ITEM') }}
{{ load_json('SHIP_MODE') }}
{{ load_json('STORE_SALES') }}
{{ load_json('WEB_PAGE') }}
{{ load_json('WEB_SITE') }}

{% endmacro %}

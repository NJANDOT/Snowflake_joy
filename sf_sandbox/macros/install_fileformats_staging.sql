{% macro install_fileformats_staging() %}

{% set create_stage %}
CREATE STAGE IF NOT EXISTS {{ var('stages')['raw'] }}
    STORAGE_INTEGRATION = s3_int
    URL = 's3://{{ var("bucket_name") }}/tpcds/'
{% endset %}

{% set create_csv %}
CREATE FILE FORMAT IF NOT EXISTS {{ var('file_formats')['csv'] }}
    TYPE = CSV
    SKIP_HEADER = 1
{% endset %}

{% set create_json %}
CREATE FILE FORMAT IF NOT EXISTS {{ var('file_formats')['json'] }}
    TYPE = JSON
{% endset %}

{% set create_parquet %}
CREATE FILE FORMAT IF NOT EXISTS {{ var('file_formats')['parquet'] }}
    TYPE = PARQUET
{% endset %}

{% do run_query(create_stage) %}
{% do run_query(create_csv) %}
{% do run_query(create_json) %}
{% do run_query(create_parquet) %}

{% endmacro %}
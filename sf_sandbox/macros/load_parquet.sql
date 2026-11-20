{% macro load_parquet(table_name) %}

COPY INTO TPCDS.BRONZE.{{ table_name }}
FROM @{{ var('stages')['raw'] }}/tpcds/{{ table_name | lower }}.parquet
FILE_FORMAT = (FORMAT_NAME = '{{ var('file_formats')['parquet'] }}')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = ABORT_STATEMENT;

{% endmacro %}

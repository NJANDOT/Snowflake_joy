{% macro load_json(table_name) %}

COPY INTO TPCDS.BRONZE.{{ table_name }}
FROM @{{ var('stages')['raw'] }}/tpcds/{{ table_name | lower }}.json
FILE_FORMAT = (FORMAT_NAME = '{{ var('file_formats')['json'] }}')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = ABORT_STATEMENT;

{% endmacro %}

{% macro load_csv(table_name) %}

COPY INTO TPCDS.BRONZE.{{ table_name }}
FROM @{{ var('stages')['raw'] }}/tpcds/{{ table_name | lower }}.csv
FILE_FORMAT = (FORMAT_NAME = '{{ var('file_formats')['csv'] }}')
ON_ERROR = ABORT_STATEMENT;

{% endmacro %}

{{ config(materialized='table') }}

select * from {{ source('tpcds_raw', 'store') }}

{{ config(materialized='table') }}

select * from {{ source('tpcds_raw', 'date_dim') }}

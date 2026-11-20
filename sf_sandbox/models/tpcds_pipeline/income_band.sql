{{ config(materialized='table') }}

select * from {{ source('tpcds_raw', 'income_band') }}

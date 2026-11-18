from pathlib import Path

import duckdb
import boto3

OUT_DIR = Path("tpcds_data")
OUT_DIR.mkdir(exist_ok=True)

con = duckdb.connect()
con.execute("INSTALL tpcds")
con.execute("LOAD tpcds")
con.execute("CALL dsdgen(sf=1)")

exports = {
    "call_center": "parquet",
    "catalog_page": "csv",
    "catalog_returns": "json",
    "catalog_sales": "parquet",
    "customer": "csv",
    "customer_address": "json",
    "customer_demographics": "parquet",
    "date_dim": "csv",
    "household_demographics": "json",
    "income_band": "parquet",
    "inventory": "csv",
    "item": "json",
    "promotion": "parquet",
    "reason": "csv",
    "ship_mode": "json",
    "store": "parquet",
    "store_returns": "csv",
    "store_sales": "json",
    "time_dim": "parquet",
    "warehouse": "csv",
    "web_page": "json",
    "web_returns": "parquet",
    "web_sales": "csv",
    "web_site": "json",
}

for table, fmt in exports.items():

    try:
        path = OUT_DIR / f"{table}.{fmt}"

        if fmt == "parquet":
            con.execute(f"COPY {table} TO '{path}' (FORMAT PARQUET)")
        elif fmt == "csv":
            con.execute(f"COPY {table} TO '{path}' (HEADER, DELIMITER ',')")
        else:
            con.execute(f"COPY {table} TO '{path}' (FORMAT JSON)")
    except Exception as e:
        print(e)

s3 = boto3.client(
    "s3",
    region_name="ca-central-1",
)
prefix = "tpcds/"


for file in OUT_DIR.iterdir():
    s3.upload_file(
        str(file),
        'tpcdsnicolasstage',
        f"{prefix}{file.name}"
    )

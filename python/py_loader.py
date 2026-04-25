# -*- coding: utf-8 -*-
"""
Created on Fri Apr 24 17:53:18 2026

@author: family
"""

import pandas as pd
from sqlalchemy import create_engine
import urllib

def getengine():
    server = r"super_secret_server"
    database = "some_db"
    username = "123456"
    password = "123456"
    driver = "ODBC Driver 17 for SQL Server"

    params = urllib.parse.quote_plus(
        f"DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};TrustServerCertificate=yes;"
    )

    return create_engine(
        f"mssql+pyodbc:///?odbc_connect={params}",
        fast_executemany=True
    )

def upload_df_with_progress(fpath, table_name, if_exists="replace"):
    engine = getengine()
    first = True

    for chunk in pd.read_csv(fpath, chunksize=5000, low_memory=False):
        chunk = chunk.replace('"', '', regex=True)

        chunk_size = max(1, 2000 // len(chunk.columns))

        chunk.to_sql(
            table_name,
            con=engine,
            if_exists=if_exists if first else "append",
            index=False,
            chunksize=chunk_size,
            method=None)
        
        first = False
        print(f"Loaded {len(chunk):,} rows")

def main(fpath, table_name):
    upload_df_with_progress(fpath, table_name )    

fpath=r'C:\uw_cert\330\Final\Data\COVID-19_US_Vaccinations_ALL.csv'
table_name ='raw_us_all_vaccinations'

#**Running REPLACES table
main(fpath, table_name)
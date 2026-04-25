# -*- coding: utf-8 -*-
"""
Created on Fri Apr 24 18:52:39 2026

@author: JNault
"""

import os
import pyodbc

def getconndb():
    rDriver = "ODBC Driver 17 for SQL Server"
    rServer = r"super_secret_server_name"
    rDatabase = "some_nifty_db"
    rUid = "User_ID"
    rPwd = "User_Pwd_123"

    connstr = (
        f"Driver={{{rDriver}}};"
        f"Server={rServer};"
        f"Database={rDatabase};"
        f"UID={rUid};"
        f"PWD={rPwd};"
        f"TrustServerCertificate=yes;"
    )
    return pyodbc.connect(connstr)

def export_stored_procedures(output_dir="sprocs"):
    os.makedirs(output_dir, exist_ok=True)
    conn = getconndb()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            s.name AS schema_name,
            p.name AS proc_name,
            OBJECT_DEFINITION(p.object_id) AS proc_definition
        FROM sys.procedures p
        JOIN sys.schemas s
            ON p.schema_id = s.schema_id
        WHERE p.is_ms_shipped = 0
        ORDER BY s.name, p.name;
    """)

    for schema_name, proc_name, proc_definition in cur.fetchall():
        if proc_definition is None:
            continue

        file_path = os.path.join(output_dir, f"{schema_name}.{proc_name}.sql")
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(proc_definition)

    cur.close()
    conn.close()

export_stored_procedures()
#!/usr/bin/env python3
"""
UPDATE_DB script to (pre-)populate the utilities database(s) from an excel file
The whole repo where this script belongs to works under the UTILITIES virtual environment, 
which can be replicated by installing the tools in the requirements.txt file.

I used mkvirtualenv to create and manage the virtual environment:
 ``` 
 user@localhost % mkvirtualenv utilities
 ```
 To create a requirements.txt file while inside the working environment:
 ```
 (utilities) user@localhost % pip freeze > requirements.txt
 ```
 To install the modules from the requirements.txt, in the virtual environment:
```
 (utilities) user@localhost % pip install -r /path/to/requirements.txt
 ```
"""

import os
import json
import argparse
import pandas as pd
from json_minify import json_minify
from sqlalchemy import create_engine, exc

# Import local modules
from utils import Conf


def run_main(conf_struct):
    
    """
    CONF_STRUCT contains the database access details. It should be in the following format:
    
    """
    
    # Create a database connection
    db_conn = f"mariadb+mariadbconnector://{conf_struct['database']['user']}:{conf_struct['database']['pwd']}@{conf_struct['database']['host']}/{conf_struct['database']['dbname']}"
    engine = create_engine(db_conn)
    
    # Load Excel file (sheet_name=None will open all sheets in the file)
    df = pd.read_excel(conf_struct['source_data'], sheet_name=None)
    
    # Import the table on each sheet into the database (there must be coherence between the names and type of each field)
    for tab in df:
        print(f'Processing sheet name: {tab}. Please wait...')
        df_tab = df[tab]
        try:
            # Update the corresponding table in the database:
            df_tab.to_sql(tab, con=engine, if_exists='append', index=False)
        except exc.IntegrityError as e:
            print(f'There is a problem with the source data. See below the error message')
            print(f'Error message:\n{e}')
        except:
            print(f'Something went wrong with the update')
        finally:
            print('Update finished')

    if False:
        # More ellaborated procedures:
        # 1) Import fields with different names, e.g. UtilityName into the Table Utility:
        utilities = df[['UtilityName']].drop_duplicates()
        utilities.to_sql('Utility', con=engine, if_exists='append', index=False)

        # 2) Retrieve utility IDs
        utility_df = pd.read_sql('SELECT * FROM Utility', con=engine)
        df = df.merge(utility_df, on='UtilityName')

        # 3) Prepare Bill data
        df_bills = df[['UtilityID', 'IssueDate', 'AmountBilled', 'AmountConsumed', 'PaymentDeadline', 'PaymentDate']]

        # 3.1) Set bill status
        df_bills['Status'] = df_bills.apply(lambda row: 'Paid' if pd.notnull(row['PaymentDate']) else 'Unpaid', axis=1)

        # 3.2) Import bills
        df_bills.to_sql('Bill', con=engine, if_exists='append', index=False)

if __name__ == "__main__":
    # construct the argument parser and parse the arguments
    ap = argparse.ArgumentParser()
    ap.add_argument("-c", "--conf", required=True, 
                    help="path to the configuration file (json format)")
    args = vars(ap.parse_args())
    config = Conf(args['conf'])
    run_main(config)
    
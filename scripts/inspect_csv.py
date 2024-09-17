import os
import pandas as pd

folder_path = '../data'

csv_files = [file for file in os.listdir(folder_path) if file.endswith('.csv')]

csv_headers = {}

for csv_file in csv_files:
    file_path = os.path.join(folder_path, csv_file)
    df = pd.read_csv(file_path, nrows=0)
    csv_headers[csv_file] = list(df.columns)

for csv_file, headers in csv_headers.items():
    print(f"CSV File: {csv_file}")
    print(f"Headers: {headers}")
    print("\n")

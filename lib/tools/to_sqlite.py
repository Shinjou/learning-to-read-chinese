import csv_to_sqlite 

# all the usual options are supported
options = csv_to_sqlite.CsvOptions(typing_style="full") 
input_files = ["c://Users/even/Downloads/nani.csv"] # pass in a list of CSV files
csv_to_sqlite.write_csv(input_files, "./lib/data/data_files/南一.sqlite", options)
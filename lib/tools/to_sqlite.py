import csv_to_sqlite 

# all the usual options are supported
options = csv_to_sqlite.CsvOptions(typing_style="full") 
input_files = ["c://Users/even/Downloads/vocabulary_utf8.csv"] # pass in a list of CSV files
csv_to_sqlite.write_csv(input_files, "./assets/data_files/vocabulary.sqlite", options)
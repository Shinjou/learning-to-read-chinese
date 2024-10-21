#!/bin/bash

output_file="all_dart_files.txt"

# Clear the output file if it exists
> "$output_file"

# Find all .dart files and concatenate them
find . -name "*.dart" -not -path "./build/*" -not -path "./ios/*" -not -path "./android/*" | while read -r file; do
    echo "// File: $file" >> "$output_file"
    echo "" >> "$output_file"
    cat "$file" >> "$output_file"
    echo "" >> "$output_file"
    echo "// End of file: $file" >> "$output_file"
    echo "//----------------------" >> "$output_file"
    echo "" >> "$output_file"
done

echo "All Dart files have been concatenated into $output_file"
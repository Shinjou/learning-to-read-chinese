#!/bin/bash

output_file="all_dart_files.txt"

# Clear the output file if it exists
> "$output_file"

# Find all .dart files and concatenate them, excluding specific directories
find . -type f -name "*.dart" \
  ! -path "./build/*" \
  ! -path "./ios/*" \
  ! -path "./android/*" | while read -r file; do
    {
        echo "// File: $file"
        echo ""
        cat "$file"
        echo ""
        echo "// End of file: $file"
        echo "//----------------------"
        echo ""
    } >> "$output_file"
done

echo "All Dart files have been concatenated into $output_file"

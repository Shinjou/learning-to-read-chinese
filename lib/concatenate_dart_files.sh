#!/bin/bash

output_file="all_dart_files.txt"
teach_word_output_file="all_teach_word_dart_files.txt"

# Clear the output files if they exist
> "$output_file"
> "$teach_word_output_file"

# Check if ./ directory exists
if [ -d "./" ]; then
    # Find all .dart files under ./* and concatenate them, excluding specific directories
    find ./ -type f -name "*.dart" \
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
    echo "All Dart files in ./* have been concatenated into $output_file"
else
    echo "Directory ./ does not exist."
fi

# Check if ./teach_word directory exists
if [ -d "./teach_word" ]; then
    # Find all .dart files under ./teach_word/* and concatenate them
    find ./teach_word -type f -name "*.dart" | while read -r file; do
        {
            echo "// File: $file"
            echo ""
            cat "$file"
            echo ""
            echo "// End of file: $file"
            echo "//----------------------"
            echo ""
        } >> "$teach_word_output_file"
    done
    echo "All Dart files in ./teach_word/* have been concatenated into $teach_word_output_file"
else
    echo "Directory ./teach_word does not exist."
fi

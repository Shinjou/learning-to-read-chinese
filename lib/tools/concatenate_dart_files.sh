#!/bin/bash

output_file="teach_word_dart_files.txt"

# Clear the output file if it exists
> "$output_file"

echo "Starting to search for Dart files..."

# Find "teach_word_view.dart" in "views" and all Dart files in "views/teach_word/" and its subdirectories
find ./views -type f \( -name "teach_word_view.dart" -o -path "./views/teach_word/*.dart" -o -path "./views/teach_word/**/*.dart" \) \
    ! -path "./build/*" \
    ! -path "./ios/*" \
    ! -path "./android/*" | while read -r file; do
    if [[ -f "$file" ]]; then
        echo "Found file: $file"  # Debug print
        {
            echo "// File: $file"
            echo ""
            cat "$file"
            echo ""
            echo "// End of file: $file"
            echo "//----------------------"
            echo ""
        } >> "$output_file"
    else
        echo "Skipped (not a file): $file"  # Debug print for troubleshooting
    fi
done

echo "Specified Dart files have been concatenated into $output_file"

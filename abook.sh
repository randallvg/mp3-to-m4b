#!/usr/bin/env bash

abook() {
    # Set output filename based on the current directory name
    local output_file="$(basename "$PWD").m4b"
    local temp_list="$(gmktemp)"
    local metadata_file="$(gmktemp)"
    local temp_mp3="$(gmktemp --suffix=.mp3)"
    local temp_m4b="$(gmktemp --suffix=.m4b)"

    # Cleanup temporary files when the script exits
    cleanup() {
        rm -f "$temp_list" "$metadata_file" "$temp_mp3" "$temp_m4b"
    }
    trap cleanup EXIT

    # Display help message
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: abook"
        echo "Merges all MP3 files in the current directory into a single M4B file named after the folder."
        return 0
    fi

    # Remove existing output files if they exist
    rm -f "$output_file" "$temp_list" "$metadata_file" "$temp_mp3" "$temp_m4b"

    # Create a list of MP3 files for concatenation (excluding temp.mp3)
    create_mp3_list() {
        rm -f "$temp_list"
        find . -maxdepth 1 -type f -name "*.mp3" ! -name "$(basename "$temp_mp3")" | sort | while read -r file; do
            echo "file '$(realpath "$file")'" >> "$temp_list"
        done
    }

    # Merge MP3 files using ffmpeg
    merge_mp3() {
        ffmpeg -f concat -safe 0 -i "$temp_list" -c copy "$temp_mp3"
        [[ ! -f "$temp_mp3" ]] && { echo "Error: Failed to create temp.mp3"; return 1; }
    }

    # Convert merged MP3 to AAC (M4B format)
    convert_to_m4b() {
        ffmpeg -i "$temp_mp3" -c:a aac -b:a 64k "$temp_m4b"
        [[ ! -f "$temp_m4b" ]] && { echo "Error: Failed to create temp.m4b"; return 1; }
    }

    # Generate chapter metadata
    generate_metadata() {
        echo ";FFMETADATA1" > "$metadata_file"
        echo "title=$(basename "$PWD")" >> "$metadata_file"
        echo "artist=Unknown" >> "$metadata_file"
        echo "album=$(basename "$PWD")" >> "$metadata_file"

        local index=1
        local start_time=0

        find . -maxdepth 1 -type f -name "*.mp3" ! -name "$(basename "$temp_mp3")" | sort | while read -r file; do
            local duration=$(ffmpeg -i "$file" 2>&1 | grep "Duration" | awk '{print $2}' | tr -d ,)
            
            # Convert time to milliseconds
            local seconds=$(echo "$duration" | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
            local start_ms=$(echo "$start_time * 1000" | bc)
            local end_ms=$(echo "($start_time + $seconds) * 1000" | bc)

            echo "" >> "$metadata_file"
            echo "[CHAPTER]" >> "$metadata_file"
            echo "TIMEBASE=1/1000" >> "$metadata_file"
            echo "START=$start_ms" >> "$metadata_file"
            echo "END=$end_ms" >> "$metadata_file"
            echo "title=Chapter $index" >> "$metadata_file"

            start_time=$(echo "$start_time + $seconds" | bc)
            index=$((index + 1))
        done
    }

    # Add metadata to the final M4B file
    add_metadata() {
        ffmpeg -i "$temp_m4b" -i "$metadata_file" -map_metadata 1 -c copy "$output_file"
        echo "M4B file created: $output_file"
    }

    # Execute functions
    create_mp3_list
    merge_mp3
    convert_to_m4b
    generate_metadata
    add_metadata
}

abook "$1"
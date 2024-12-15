#!/bin/bash

# Check if the URL is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <output_directory> <video_url>"
    exit 1
fi

OUTPUT_DIR="$1"
VIDEO_URL="$2"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR" || exit 1

# Download the video using yt command
echo "Downloading video..."
yt-dlp_linux -f '137+bestaudio[ext=m4a]/136+bestaudio[ext=m4a]/135+bestaudio[ext=m4a]/134+bestaudio[ext=m4a]/133+bestaudio[ext=m4a]/160+bestaudio[ext=m4a]' "$VIDEO_URL"

# Extract the video title from the downloaded file name (assuming it's in the format 'Title [id].mp4')
VIDEO_FILE=$(ls *.mp4 2>/dev/null | head -n 1)
if [ -z "$VIDEO_FILE" ]; then
    echo "No video file found after download."
    exit 1
fi

# Remove the extension and extract the title part
#
VIDEO_TITLE=$(basename "$VIDEO_FILE" .mp4)
VIDEO_TITLE = CLEAN_FILENAME=$(echo "$VIDEO_TITLE" | tr '[:space:]' '-' | tr -cd '[:alnum:]-')
# Get the transcription using fabric
echo "Getting transcription..."
fabric --youtube "$VIDEO_URL" > transcript.txt

# Create a 5 sentence summary
echo "Creating 5 sentence summary..."
less transcript.txt | fabric -sp create_5_sentence_summary >> keywords.md

# Create a summary
echo "Creating summary..."
less transcript.txt | fabric -sp summarize >> summary.md

# Extract wisdom
echo "Extracting wisdom..."
WISDOM_FILE_NAME="${VIDEO_TITLE// /\\ }".md
less transcript.txt | fabric -sp extract_wisdom >> "$WISDOM_FILE_NAME"

echo "Process completed successfully."

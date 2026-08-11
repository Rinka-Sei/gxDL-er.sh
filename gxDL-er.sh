#!/usr/bin/env bash

# Set strict mode for script robustness
set -euo pipefail

# --- Configuration ---
TARGET_DIR="$HOME/.config/guitarix/banks"
LOG_FILE="guitarix_preset_download.log"

# --- Color Codes ---
GREEN='\033[0;32m'  # For success messages
RED='\033[0;31m'    # For error/failure messages
YELLOW='\033[0;33m' # For in-progress messages / warnings
BLUE='\033[0;34m'   # For informational messages
CYAN='\033[0;36m'   # For ASCII art banner
WHITE='\033[1;37m'  # For script crash/exit
NC='\033[0m'        # No Color - resets text to default

# --- Global Counters ---
TOTAL_URLS=0
PROCESSED_URLS=0
SUCCESS_COUNT=0
FAILED_COUNT=0

# --- Functions ---

# Display ASCII Art Banner
show_banner() {
    printf "%b" "$CYAN"
    cat << 'EOF'
              ___    _                                  _     
             (  _`\ ( )                                ( )    
   __        | | ) || |    ______   __   _ __     ___ | |__  
 /'_ `\(`\/')| | | )| |  _(______)/'__`\( '__)   /',__)|  _ `\
( (_) | >  < | |_) || |_( )      (  ___/| |    _ \__, \| | | |
`\__  |(_/\_)(____/'(____/'      `\____)(_)   (_)(____/(_) (_)
( )_) |                                                       
 \___/'                                                       
EOF
    printf "%b\n" "$NC"
}

# Display help and usage manual
usage() {
    show_banner
    printf "%bUsage: %s <URL_or_file1> [URL_or_file2 ...]%b\n" "$BLUE" "$0" "$NC"
    printf "%b  <URL_or_file>: Direct preset URL(s) or paths to .txt file(s) containing URLs.%b\n" "$BLUE" "$NC"
    printf "\n"
    printf "This script dynamically downloads Guitarix preset banks (.gx / .gxb)\n"
    printf "from Musical Artifacts (or any web host) directly into:\n"
    printf "  %s%s%b\n" "$YELLOW" "$TARGET_DIR" "$NC"
    printf "\n"
    printf "Features:\n"
    printf "  - Automatically follows HTTP 301/302 redirects.\n"
    printf "  - Automatically derives input filenames via curl.\n"
    printf "  - Supports space-separated URLs and line-by-line .txt batch files.\n"
    printf "  - Logs conversion activity to %s.%b\n" "$LOG_FILE" "$NC"
    exit 1
}

# Trap CTRL+C to ensure clean exit
trap 'printf "\n%bSCRIPT INTERRUPTED BY USER (Ctrl+C)! Exiting.%b\n" "$WHITE" "$NC"; exit 1' INT TERM

# Check dependency helper
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Core function to download a single URL
download_url() {
    local url="$1"
    PROCESSED_URLS=$((PROCESSED_URLS + 1))
    
    # Extract baseline name for status reporting
    local url_filename
    url_filename=$(basename "$url")

    printf "%b[%d/%d] Downloading: %s%b\n" "$YELLOW" "$PROCESSED_URLS" "$TOTAL_URLS" "$url_filename" "$NC"
    printf "%b  Source: %s%b\n" "$BLUE" "$url" "$NC"

    local current_datetime
    current_datetime=$(date +"%Y-%m-%d_%H:%M:%S")

    # -L: Follow redirects (fixes HTTP 302 errors)
    # -O: Use remote filename
    # --output-dir: Specify targeted directory safely
    if curl -sSL -O --output-dir "$TARGET_DIR" "$url"; then
        local log_msg="$current_datetime $url_filename successfully downloaded."
        printf "%b  SUCCESS: %s%b\n" "$GREEN" "$log_msg" "$NC" | tee -a "$LOG_FILE"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        local log_msg="$current_datetime $url_filename FAILED to download from $url"
        printf "%b  ERROR: %s%b\n" "$RED" "$log_msg" "$NC" | tee -a "$LOG_FILE"
        FAILED_COUNT=$((FAILED_COUNT + 1))
    fi
    printf "\n"
}

# --- Initial Checks ---

if [ "$#" -eq 0 ]; then
    usage
fi

if ! command_exists "curl"; then
    show_banner
    printf "%bError: 'curl' is not installed or not found in your PATH.%b\n" "$RED" "$NC"
    printf "%bPlease install curl before running this script.%b\n" "$RED" "$NC"
    exit 1
fi

# Show Intro Banner at execution start
show_banner

# Create Target Directory & Log File
mkdir -p "$TARGET_DIR"
> "$LOG_FILE"

# --- Step 1: Input Parsing & Queue Building ---
printf "%bScanning inputs and queuing URLs...%b\n" "$YELLOW" "$NC"
QUEUE=()

for arg in "$@"; do
    if [ -f "$arg" ]; then
        # Argument is a text file; read line by line
        while IFS= read -r line || [ -n "$line" ]; do
            # Strip trailing CR (Windows carriage returns) & trim whitespace
            line=$(echo "$line" | tr -d '\r' | xargs)
            
            # Skip blank lines and lines starting with '#'
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            
            QUEUE+=("$line")
        done < "$arg"
    else
        # Argument is a direct URL string
        QUEUE+=("$arg")
    fi
done

TOTAL_URLS=${#QUEUE[@]}

if [ "$TOTAL_URLS" -eq 0 ]; then
    printf "%bError: No valid URLs found to process.%b\n" "$RED" "$NC"
    exit 1
fi

printf "%bFound %d preset file(s) to download.%b\n" "$BLUE" "$TOTAL_URLS" "$NC"
printf "%bTarget Directory: %s%b\n" "$BLUE" "$TARGET_DIR" "$NC"
printf "\n"

# --- Step 2: User Confirmation ---
printf "%b----------------------------------------------------%b\n" "$YELLOW" "$NC"
printf "%bDo you want to proceed with downloading %d preset bank(s)? (y/N)%b\n" "$YELLOW" "$TOTAL_URLS" "$NC"
read -p "Enter 'y' to confirm download: " -n 1 -r REPLY_CONFIRM
printf "\n"

if [[ ! "$REPLY_CONFIRM" =~ ^[Yy]$ ]]; then
    printf "%bDownload process cancelled by user. Exiting.%b\n" "$BLUE" "$NC"
    exit 0
fi

printf "%bProceeding with batch download...%b\n" "$BLUE" "$NC"
printf "%b----------------------------------------------------%b\n" "$BLUE" "$NC"
printf "\n"

# --- Step 3: Main Download Loop ---
for url_item in "${QUEUE[@]}"; do
    download_url "$url_item"
done

# --- Step 4: Final Summary ---
printf "%b----------------------------------------------------%b\n" "$BLUE" "$NC"
printf "%bDownload task completed.%b\n" "$BLUE" "$NC"
printf "%bTotal Queue Items: %d%b\n" "$BLUE" "$TOTAL_URLS" "$NC"
printf "%bSuccessfully Downloaded: %d%b\n" "$GREEN" "$SUCCESS_COUNT" "$NC"
printf "%bFailed Downloads: %d%b\n" "$RED" "$FAILED_COUNT" "$NC"
printf "%bCheck '%s' for a detailed operation log.%b\n" "$BLUE" "$LOG_FILE" "$NC"
printf "%b----------------------------------------------------%b\n" "$BLUE" "$NC"

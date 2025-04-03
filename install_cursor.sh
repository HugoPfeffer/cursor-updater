#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

LOG_PREFIX="[Cursor Installer]"
TARGET_DIR="/home/hpfeffer/.cursor_bins"
OPT_TARGET="/opt/cursor.appimage"
SEARCH_PATTERN="Cursor*x86_64.AppImage"

log_message() {
    echo "$LOG_PREFIX $1"
}

log_error() {
    echo "$LOG_PREFIX ERROR: $1" >&2
}

# --- Check for root privileges for later steps ---
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script needs to be run as root (using sudo) to copy files to /opt."
        exit 1
    fi
    log_message "Running with root privileges."
}

# --- Search for files ---
log_message "Starting filesystem search for '$SEARCH_PATTERN'. This may take a while..."
# Use find -print0 and read -d '' to handle filenames with spaces or special characters
# Exclude the target directory itself from the search using -prune
mapfile -d $'\0' found_files < <(find / -path "$TARGET_DIR" -prune -o -name "$SEARCH_PATTERN" -print0 2>/dev/null)

# Clean up potential empty element from mapfile if find returns nothing but prints a null byte
if [[ ${#found_files[@]} -gt 0 && -z "${found_files[-1]}" ]]; then
    unset 'found_files[-1]'
fi

if [ ${#found_files[@]} -eq 0 ]; then
    log_message "No files matching '$SEARCH_PATTERN' found (excluding '$TARGET_DIR')."
    exit 0
fi

log_message "Found the following files (excluding '$TARGET_DIR'):"
printf "  %s\n" "${found_files[@]}"

# --- Create target directory ---
log_message "Ensuring target directory exists: $TARGET_DIR"
mkdir -p "$TARGET_DIR"
log_message "Directory check complete. '$TARGET_DIR' is ready."

# --- Confirm and Move files ---
# First, ask if the user wants to proceed with moving *any* files
read -p "$LOG_PREFIX Move the found files to $TARGET_DIR (potential overwrites will be prompted)? (y/N): " confirm_move_initial
if [[ ! "$confirm_move_initial" =~ ^[Yy]$ ]]; then
    log_message "Move operation cancelled by user."
    exit 0
fi

moved_files_paths=()
skipped_files=0
log_message "Processing files for move..."
for file_path in "${found_files[@]}"; do
    if [ -z "$file_path" ]; then continue; fi # Skip empty entries if any

    filename=$(basename "$file_path")
    destination_path="$TARGET_DIR/$filename"

    log_message "Checking file: '$file_path'"

    # Check if destination exists
    if [ -e "$destination_path" ]; then
        log_message "  Destination '$destination_path' already exists."
        read -p "$LOG_PREFIX   Overwrite existing file? (y/N): " confirm_overwrite
        if [[ "$confirm_overwrite" =~ ^[Yy]$ ]]; then
            log_message "  Overwriting confirmed for '$destination_path'."
            # Attempt to remove first to ensure overwrite works reliably
            if ! rm -f "$destination_path"; then
                 log_error "  Failed to remove existing file '$destination_path' before overwrite. Skipping move."
                 ((skipped_files++))
                 continue
            fi
        else
            log_message "  Skipping move for '$file_path' (overwrite denied)."
            ((skipped_files++))
            continue # Skip to the next file
        fi
    fi

    # Proceed with moving
    log_message "  Moving '$file_path' to '$destination_path'"
    if mv "$file_path" "$destination_path"; then
        moved_files_paths+=("$destination_path")
    else
        log_error "  Failed to move '$file_path'. Skipping."
        ((skipped_files++))
    fi
done

log_message "Move processing complete. ${#moved_files_paths[@]} files moved, $skipped_files files skipped."

if [ ${#moved_files_paths[@]} -eq 0 ]; then
    log_error "No files were successfully moved to $TARGET_DIR."
    exit 1
fi

# This log message might be slightly misleading if some files were skipped, but it confirms *some* success.
log_message "Files processed. Check logs for details."

# --- Select file to install ---
selected_file=""
if [ ${#moved_files_paths[@]} -eq 1 ]; then
    selected_file="${moved_files_paths[0]}"
    log_message "Only one file moved, selecting '$selected_file' for installation."
else
    log_message "Multiple files moved. Please select which one to install to $OPT_TARGET:"
    select opt in "${moved_files_paths[@]}"; do
        if [[ -n "$opt" ]]; then
            selected_file="$opt"
            log_message "Selected '$selected_file'."
            break
        else
            log_message "Invalid selection. Please try again."
        fi
    done
fi

if [ -z "$selected_file" ]; then
    log_error "No file selected for installation."
    exit 1
fi

# --- Check root privileges before proceeding ---
check_root

# --- Handle existing file in /opt ---
if [ -e "$OPT_TARGET" ]; then
    log_message "File already exists at $OPT_TARGET."
    read -p "$LOG_PREFIX Do you want to remove the existing file and replace it? (y/N): " confirm_replace
    if [[ "$confirm_replace" =~ ^[Yy]$ ]]; then
        log_message "Removing existing file: $OPT_TARGET"
        if ! rm "$OPT_TARGET"; then
            log_error "Failed to remove existing file '$OPT_TARGET'."
            exit 1
        fi
        log_message "Existing file removed."
    else
        log_message "Replacement cancelled by user. Exiting."
        exit 0
    fi
fi

# --- Copy selected file to /opt ---
log_message "Copying '$selected_file' to '$OPT_TARGET'..."
if ! cp "$selected_file" "$OPT_TARGET"; then
    log_error "Failed to copy '$selected_file' to '$OPT_TARGET'."
    exit 1
fi
log_message "File successfully copied."

# --- Set permissions ---
log_message "Setting execute permissions for '$OPT_TARGET'..."
if ! chmod +x "$OPT_TARGET"; then
    log_error "Failed to set execute permissions on '$OPT_TARGET'."
    # Attempt cleanup? Or just report error? Reporting for now.
    exit 1
fi
log_message "Execute permissions set."

log_message "--------------------------------------------------"
log_message "Cursor AppImage installation process complete!"
log_message "Installed file: $OPT_TARGET"
log_message "Original location: $selected_file (moved from initial location)"
log_message "--------------------------------------------------"

exit 0 
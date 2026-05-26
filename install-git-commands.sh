#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# URL of the zip file
ZIP_URL="https://github.com/mxprnc/git-commands/archive/refs/heads/main.zip"

# Temporary directory for download and extraction within the workspace
TEMP_DIR=".tmp_git_commands_$(date +%s)"
ZIP_FILE="${TEMP_DIR}/archive.zip"

# Determine namespace (default to "git")
NAMESPACE="git"
if [ -n "$1" ]; then
    NAMESPACE="$1"
fi

# Validate namespace format (only letters, numbers, hyphens, and underscores)
if [[ ! "$NAMESPACE" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: Invalid namespace '$NAMESPACE'. Only alphanumeric characters, hyphens, and underscores are allowed." >&2
    exit 1
fi

# Ensure cleanup of the temporary directory on any exit (success or failure/interrupt)
cleanup() {
    if [ -d "${TEMP_DIR}" ]; then
        echo "Cleaning up temporary files..."
        rm -rf "${TEMP_DIR}"
    fi
}
# Register trap for cleanup
trap cleanup EXIT INT TERM

# OS-compatible search and replace function
replace_text() {
    local search="$1"
    local replace="$2"
    local file="$3"
    if [ "$(uname)" = "Darwin" ]; then
        sed -i '' "s|${search}|${replace}|g" "${file}"
    else
        sed -i "s|${search}|${replace}|g" "${file}"
    fi
}

# 1. Verify working directory (must be run from the root of a Git repo)
if [ ! -d ".git" ]; then
    echo "Error: This script must be run from the root of a Git repository." >&2
    exit 1
fi

# 2. Check dependencies
MISSING_DEPS=()
if ! command -v unzip >/dev/null 2>&1; then
    MISSING_DEPS+=("unzip")
fi

# Check for download tool
DOWNLOAD_TOOL=""
if command -v curl >/dev/null 2>&1; then
    DOWNLOAD_TOOL="curl"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOAD_TOOL="wget"
else
    MISSING_DEPS+=("curl or wget")
fi

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo "Error: Missing required tool(s): ${MISSING_DEPS[*]}" >&2
    exit 1
fi

echo "Creating temporary directory..."
mkdir -p "${TEMP_DIR}"

echo "Downloading git-commands from ${ZIP_URL}..."
if [ "${DOWNLOAD_TOOL}" = "curl" ]; then
    curl -L "${ZIP_URL}" -o "${ZIP_FILE}"
else
    wget "${ZIP_URL}" -O "${ZIP_FILE}"
fi

echo "Extracting archive..."
unzip -q "${ZIP_FILE}" -d "${TEMP_DIR}"

# Locate the source directory inside the extracted zip
# GitHub zips are extracted into 'git-commands-<branch_name>'
SRC_DIR="${TEMP_DIR}/git-commands-main/.gemini/commands/git"
DEST_DIR="./.gemini/commands/${NAMESPACE}"

if [ ! -d "${SRC_DIR}" ]; then
    # Fallback to find .gemini/commands/git dynamically in case branch name is different
    SRC_DIR=$(find "${TEMP_DIR}" -type d -path "*/.gemini/commands/git" 2>/dev/null | head -n 1)
    if [ -z "${SRC_DIR}" ] || [ ! -d "${SRC_DIR}" ]; then
        echo "Error: Could not locate .gemini/commands/git in the extracted archive." >&2
        exit 1
    fi
fi

echo "Creating destination directory parent..."
mkdir -p "./.gemini/commands"

echo "Copying git commands to ${DEST_DIR}..."
# Remove existing destination directory to prevent nested copy
if [ -d "${DEST_DIR}" ]; then
    rm -rf "${DEST_DIR}"
fi

cp -r "${SRC_DIR}" "${DEST_DIR}"

# Customize the namespace within the copied files if not using the default "git"
if [ "${NAMESPACE}" != "git" ]; then
    echo "Customizing command prefix to /${NAMESPACE}..."
    find "${DEST_DIR}" -type f \( -name "*.toml" -o -name "*.md" \) | while read -r file; do
        replace_text "/git:" "/${NAMESPACE}:" "${file}"
        replace_text ".gemini/commands/git" ".gemini/commands/${NAMESPACE}" "${file}"
    done
fi

echo "Successfully updated git commands in ${DEST_DIR}!"
echo "Now you can reload command definitions in Gemini CLI by typing: /commands reload"

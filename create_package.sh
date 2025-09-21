#!/usr/bin/env bash

# Disable DEBUG for packaging/release
sed -i "s/DEBUG = true/DEBUG = false/g" "main.lua"

OUTPUT_ZIP=${1:-"Xaidee-ShowArtifacts.zip"}

EXCLUDE_PATTERNS=("$OUTPUT_ZIP")

if [ -f .gitignore ]; then
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        EXCLUDE_PATTERNS+=("$line")
    done < .gitignore
fi

zip -r "$OUTPUT_ZIP" . -x "${EXCLUDE_PATTERNS[@]}"
# Re-enable DEBUG for in-dev
sed -i "s/DEBUG = false/DEBUG = true/g" "main.lua"
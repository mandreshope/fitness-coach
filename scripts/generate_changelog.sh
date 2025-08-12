#!/bin/bash

# Set the output file for the changelog
OUTPUT_FILE="CHANGELOG.md"
TEMP_FILE="CHANGELOG_TEMP.md"
VERSION=""

# Check if Git and pubspec.yaml are available
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please install Git and try again."
    exit 1
fi

if [ ! -f "pubspec.yaml" ]; then
    echo "pubspec.yaml not found. Please ensure this script is run in the root of a Flutter project."
    exit 1
fi

# Get the current version from pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | awk -F ': ' '{print $2}' | awk -F '+' '{print $1}')

if [ -z "$VERSION" ]; then
    echo "Failed to extract version from pubspec.yaml."
    exit 1
fi

# Check if OUTPUT_FILE exists, if not create it
if [ ! -f "$OUTPUT_FILE" ]; then
    echo "# Changelog" > "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "All notable changes to this project are documented below." >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# Write the new version at the top
echo "## $VERSION" > "$TEMP_FILE"

# Generate sections based on commit types
echo "Generating changelog for version $VERSION..."

# Features
echo "### Features" >> "$TEMP_FILE"
git log --no-merges --pretty=format:"- %s" | grep "feat:" >> "$TEMP_FILE" || echo "No features found." >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Bug Fixes
echo "### Bug Fixes" >> "$TEMP_FILE"
git log --no-merges --pretty=format:"- %s" | grep "fix:" >> "$TEMP_FILE" || echo "No bug fixes found." >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Chores
echo "### Chores" >> "$TEMP_FILE"
git log --no-merges --pretty=format:"- %s" | grep "chore:" >> "$TEMP_FILE" || echo "No chores found." >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Miscellaneous
echo "### Miscellaneous" >> "$TEMP_FILE"
git log --no-merges --pretty=format:"- %s" | grep -v -E "feat:|fix:|chore:" >> "$TEMP_FILE" || echo "No miscellaneous changes found." >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Append the existing changelog to the temporary file
cat "$OUTPUT_FILE" >> "$TEMP_FILE"

# Replace the old changelog with the new one
mv "$TEMP_FILE" "$OUTPUT_FILE"

# Notify user
echo "Changelog updated successfully: $OUTPUT_FILE"
#!/bin/bash

# File path
PUBSPEC_FILE="pubspec.yaml"

# Function to increment version
increment_version() {
    local version=$1
    local index=$2
    IFS='.' read -r -a parts <<< "$version"
    
    # Incremente la version en fonction de l'index et remet les autres à 0
    parts[$index]=$((parts[$index] + 1))
    
    # Remet les parties suivantes à 0
    for ((i = index + 1; i < ${#parts[@]}; i++)); do
        parts[$i]=0
    done
    
    echo "${parts[*]}" | tr ' ' '.'
}

# Check if pubspec.yaml exists
if [ ! -f "$PUBSPEC_FILE" ]; then
    echo "Error: $PUBSPEC_FILE not found in the current directory."
    exit 1
fi

# Extract the current version and build number
CURRENT_VERSION=$(grep 'version:' $PUBSPEC_FILE | awk -F ': ' '{print $2}')
VERSION=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
BUILD=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

if [ -z "$VERSION" ] || [ -z "$BUILD" ]; then
    echo "Error: Could not extract version and build number from pubspec.yaml."
    exit 1
fi

# Get commit types from the latest changes
LATEST_COMMITS=$(git log --oneline -10)
echo "Analyzing latest commits..."
echo "$LATEST_COMMITS"

if echo "$LATEST_COMMITS" | grep -iq "breaking"; then
    INCREMENT_TYPE="major"
elif echo "$LATEST_COMMITS" | grep -iq "feat"; then
    INCREMENT_TYPE="minor"
elif echo "$LATEST_COMMITS" | grep -iq "fix"; then
    INCREMENT_TYPE="patch"
else
    INCREMENT_TYPE="build"
fi

echo "Detected increment type: $INCREMENT_TYPE"

# Determine new version and build number
case $INCREMENT_TYPE in
major)
    NEW_VERSION=$(increment_version "$VERSION" 0)
    NEW_BUILD=1
    ;;
minor)
    NEW_VERSION=$(increment_version "$VERSION" 1)
    NEW_BUILD=1
    ;;
patch)
    NEW_VERSION=$(increment_version "$VERSION" 2)
    NEW_BUILD=1
    ;;
build)
    NEW_VERSION=$VERSION
    NEW_BUILD=$((BUILD + 1))
    ;;
*)
    echo "Error: Unknown increment type."
    exit 1
    ;;
esac

# Update the version in pubspec.yaml
sed -i.bak "s/^version: .*/version: $NEW_VERSION+$NEW_BUILD/" $PUBSPEC_FILE

echo "Version updated to $NEW_VERSION+$NEW_BUILD in $PUBSPEC_FILE"
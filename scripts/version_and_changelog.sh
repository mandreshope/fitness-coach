#!/bin/bash

# File paths
PUBSPEC_FILE="pubspec.yaml"
CHANGELOG_FILE="CHANGELOG.md"

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

echo "Current version: $VERSION+$BUILD"

# Function to increment version
increment_version() {
    local version=$1
    local index=$2
    IFS='.' read -r -a parts <<< "$version"
    parts[$index]=$((parts[$index] + 1))
    for ((i = index + 1; i < ${#parts[@]}; i++)); do
        parts[$i]=0
    done
    echo "${parts[*]}" | tr ' ' '.'
}

# Get the hash of the last commit containing "chore: increment version"
LAST_BOT_COMMIT_HASH=$(git log --oneline --grep="chore: increment version" -n 1 | cut -d ' ' -f1 || echo "NONE")

# Get commits after the bot commit to analyze changes
if [ "$LAST_BOT_COMMIT_HASH" == "NONE" ]; then
    LATEST_COMMITS=$(git log --oneline --no-merges)
else
    LATEST_COMMITS=$(git log --oneline --no-merges "$LAST_BOT_COMMIT_HASH"..HEAD)
fi

echo "Analyzing latest commits..."
echo "$LATEST_COMMITS"

# Determine increment type based on commit messages
if echo "$LATEST_COMMITS" | grep -iq "breaking:"; then
    INCREMENT_TYPE="major"
elif echo "$LATEST_COMMITS" | grep -iq "feat:"; then
    INCREMENT_TYPE="minor"
elif echo "$LATEST_COMMITS" | grep -iq "fix:"; then
    INCREMENT_TYPE="patch"
elif echo "$LATEST_COMMITS" | grep -iq "chore:"; then
    INCREMENT_TYPE="patch"
elif echo "$LATEST_COMMITS" | grep -iq "build:"; then
    INCREMENT_TYPE="build"
else
    INCREMENT_TYPE="patch"
fi

echo "Detected increment type: $INCREMENT_TYPE"

# Determine new version and build number based on the increment type
NEW_BUILD=$(($BUILD + 1))

case $INCREMENT_TYPE in
major)
    NEW_VERSION=$(increment_version "$VERSION" 0)
    ;;
minor)
    NEW_VERSION=$(increment_version "$VERSION" 1)
    ;;
patch)
    NEW_VERSION=$(increment_version "$VERSION" 2)
    ;;
*)
    echo "Error: Unknown increment type."
    exit 1
    ;;
esac

# Update the version in pubspec.yaml
sed -i.bak "s/^version: .*/version: $NEW_VERSION+$NEW_BUILD/" $PUBSPEC_FILE
echo "Version updated to $NEW_VERSION+$NEW_BUILD in $PUBSPEC_FILE"

# Ensure the changelog file exists
if [ ! -f "$CHANGELOG_FILE" ]; then
    echo "# Changelog" > "$CHANGELOG_FILE"
    echo "" >> "$CHANGELOG_FILE"
fi

# Start building the changelog for the current version
TEMP_CHANGELOG="CHANGELOG_TEMP.md"
DATE=$(date +"%Y-%m-%d")
{
    echo "## $NEW_VERSION+$NEW_BUILD ($DATE)"
    echo ""
    echo "### Breaking Changes"
    BREAKING=$(git log --oneline --no-merges "$LAST_BOT_COMMIT_HASH"..HEAD | grep "breaking:" | sed -E 's/^([a-f0-9]+) breaking: /- (#\1) /g')
    echo "${BREAKING:-No breaking changes found.}"
    echo ""
    echo "### Features"
    FEATURES=$(git log --oneline --no-merges "$LAST_BOT_COMMIT_HASH"..HEAD | grep "feat:" | sed -E 's/^([a-f0-9]+) feat: /- (#\1) /g')
    echo "${FEATURES:-No features found.}"
    echo ""
    echo "### Bug Fixes"
    BUG_FIXES=$(git log --oneline --no-merges "$LAST_BOT_COMMIT_HASH"..HEAD | grep "fix:" | sed -E 's/^([a-f0-9]+) fix: /- (#\1) /g')
    echo "${BUG_FIXES:-No bug fixes found.}"
    echo ""
    echo "### Chores"
    CHORES=$(git log --oneline --no-merges "$LAST_BOT_COMMIT_HASH"..HEAD | grep "chore:" | sed -E 's/^([a-f0-9]+) chore: /- (#\1) /g')
    echo "${CHORES:-No chores found.}"
    echo ""
    echo "### Refactors"
    CHORES=$(git log --oneline --no-merges "$LAST_BOT_COMMIT_HASH"..HEAD | grep "refactor:" | sed -E 's/^([a-f0-9]+) refactor: /- (#\1) /g')
    echo "${CHORES:-No refactors found.}"
    echo ""
    echo "### Style Changes"
    CHORES=$(git log --oneline --no-merges "$LAST_BOT_COMMIT_HASH"..HEAD | grep "style:" | sed -E 's/^([a-f0-9]+) style: /- (#\1) /g')
    echo "${CHORES:-No style Changes found.}"
    echo ""
    echo "### Miscellaneous"
    MISC=$(git log --oneline --no-merges "$LAST_BOT_COMMIT_HASH"..HEAD | grep -v -E "breaking:|feat:|fix:|chore:" | sed -E 's/^([a-f0-9]+) /- (#\1) /g')
    echo "${MISC:-No miscellaneous changes found.}"
    echo ""
    cat "$CHANGELOG_FILE"
} > "$TEMP_CHANGELOG"

mv "$TEMP_CHANGELOG" "$CHANGELOG_FILE"
echo "Changelog updated successfully."

# # Commit version and changelog update
# git config --global user.email "your-email@example.com"
# git config --global user.name "your-name"
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: increment version $NEW_VERSION+$NEW_BUILD and update changelog"
# git push
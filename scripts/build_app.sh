#!/bin/bash

# Get the project name from pubspec.yaml
PROJECT_NAME=$(grep 'name:' pubspec.yaml | awk -F ': ' '{print $2}')

# Set the path to your Flutter project
PROJECT_PATH="."

# Navigate to the project directory
cd "$PROJECT_PATH"

# Clean the project
flutter clean

# Get the latest dependencies
flutter pub get

# Get the current version from pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | awk -F ': ' '{print $2}')
VERSION_NUMBER=$(echo $VERSION | awk -F '+' '{print $1}')
BUILD_NUMBER=$(echo $VERSION | awk -F '+' '{print $2}')

# Update the version in pubspec.yaml
NEW_VERSION="$VERSION_NUMBER+$BUILD_NUMBER"
sed -i '' "s/version: $VERSION/version: $NEW_VERSION/" pubspec.yaml

# Build and rename function for APK
build_and_rename_apk() {
  local flavor="$1"
  flutter build apk --no-tree-shake-icons

  # Determine the output directory based on the flavor
  OUTPUT_DIR="$PROJECT_PATH/build/app/outputs/flutter-apk"

  # Rename the output APK file with the version
  APK_FILE="$OUTPUT_DIR/app-release.apk"
  NEW_APK_NAME="$OUTPUT_DIR/${flavor}_v$NEW_VERSION.apk"
  mv "$APK_FILE" "$NEW_APK_NAME"

  echo "Build completed and APK for $flavor renamed to $NEW_APK_NAME"
}

# Build and rename function for IPA
build_and_rename_ipa() {
  local flavor="$1"
  flutter build ipa

  # Determine the output directory for the IPA file
  OUTPUT_DIR="$PROJECT_PATH/build/ios/ipa"

  # Rename the output IPA file with the version
  IPA_FILE="$OUTPUT_DIR/app.ipa"
  NEW_IPA_NAME="$OUTPUT_DIR/${flavor}_v$NEW_VERSION.ipa"
  mv "$IPA_FILE" "$NEW_IPA_NAME"

  echo "Build completed and IPA for $flavor renamed to $NEW_IPA_NAME"
}

# Function to display usage instructions
show_usage() {
  echo "Usage: $0 [android|ios|both]"
  echo "  android - Build only the Android APK"
  echo "  ios     - Build only the iOS IPA (macOS only)"
  echo "  both    - Build both Android APK and iOS IPA (macOS only)"
}

# Check for user input
if [ -z "$1" ]; then
  show_usage
  exit 1
fi

# Process the user's choice
case "$1" in
  android)
    echo "Building APK for Android..."
    build_and_rename_apk $PROJECT_NAME
    ;;
  ios)
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "Building IPA for iOS..."
      build_and_rename_ipa $PROJECT_NAME
    else
      echo "Skipping IPA build; not running on macOS."
    fi
    ;;
  both)
    echo "Building APK for Android..."
    build_and_rename_apk $PROJECT_NAME
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "Building IPA for iOS..."
      build_and_rename_ipa $PROJECT_NAME
    else
      echo "Skipping IPA build; not running on macOS."
    fi
    ;;
  *)
    echo "Invalid option: $1"
    show_usage
    exit 1
    ;;
esac
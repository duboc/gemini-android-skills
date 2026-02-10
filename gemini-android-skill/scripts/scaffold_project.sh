#!/usr/bin/env bash
# scaffold_project.sh — Create a new Android project from the CLI
# Usage: ./scaffold_project.sh <project-name> <package-name> [options]
#
# Options:
#   --compose       Use Jetpack Compose (default: Views with ViewBinding)
#   --min-sdk N     Minimum SDK version (default: 24)
#   --target-sdk N  Target SDK version (default: 34)
#   --output DIR    Output directory (default: ./<project-name>)
#
# Example:
#   ./scaffold_project.sh MyApp com.example.myapp --compose --min-sdk 26

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <project-name> <package-name> [--compose] [--min-sdk N] [--target-sdk N] [--output DIR]"
    exit 1
fi

PROJECT_NAME="$1"
PACKAGE_NAME="$2"
shift 2

USE_COMPOSE=false
MIN_SDK=24
TARGET_SDK=34
OUTPUT_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --compose)    USE_COMPOSE=true; shift ;;
        --min-sdk)    MIN_SDK="$2"; shift 2 ;;
        --target-sdk) TARGET_SDK="$2"; shift 2 ;;
        --output)     OUTPUT_DIR="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

OUTPUT_DIR="${OUTPUT_DIR:-$(pwd)/$PROJECT_NAME}"
PACKAGE_PATH=$(echo "$PACKAGE_NAME" | tr '.' '/')

echo "🏗️  Scaffolding: $PROJECT_NAME ($PACKAGE_NAME)"
echo "   Compose=$USE_COMPOSE  MinSDK=$MIN_SDK  TargetSDK=$TARGET_SDK"

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# Create directory structure
for d in \
    "app/src/main/java/$PACKAGE_PATH" \
    "app/src/main/res/layout" \
    "app/src/main/res/values" \
    "app/src/main/res/drawable" \
    "app/src/test/java/$PACKAGE_PATH" \
    "app/src/androidTest/java/$PACKAGE_PATH" \
    "gradle"; do
    mkdir -p "$d"
done

echo "   ✓ Directory structure created"

# Generate files using heredocs (abbreviated for readability)
# Full templates would be generated here — settings.gradle.kts, build files,
# version catalog, AndroidManifest, MainActivity, theme, resources, etc.

echo ""
echo "✅ Project scaffolded at: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "  cd $OUTPUT_DIR"
echo "  # Open in Android Studio:"
echo "  studio ."
echo "  # Or build from CLI:"
echo "  ./gradlew assembleDebug"

#!/usr/bin/env bash
# check_env.sh — Verify Android development environment is properly configured
# Run this before any Android development work

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS=0
WARN=0
FAIL=0

pass() { echo -e "  ${GREEN}✓${NC} $1"; ((PASS++)); }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; ((WARN++)); }
fail() { echo -e "  ${RED}✗${NC} $1"; ((FAIL++)); }
info() { echo -e "  ${BLUE}ℹ${NC} $1"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Android Development Environment Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── ANDROID_HOME / ANDROID_SDK_ROOT ─────────────────────
echo "📁 SDK Location"
if [ -n "${ANDROID_HOME:-}" ]; then
    if [ -d "$ANDROID_HOME" ]; then
        pass "ANDROID_HOME=$ANDROID_HOME"
    else
        fail "ANDROID_HOME=$ANDROID_HOME (directory does not exist)"
    fi
elif [ -n "${ANDROID_SDK_ROOT:-}" ]; then
    if [ -d "$ANDROID_SDK_ROOT" ]; then
        pass "ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
        export ANDROID_HOME="$ANDROID_SDK_ROOT"
    else
        fail "ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT (directory does not exist)"
    fi
else
    # Try common locations
    for dir in "$HOME/Android/Sdk" "$HOME/Library/Android/sdk" "/usr/local/lib/android/sdk"; do
        if [ -d "$dir" ]; then
            warn "ANDROID_HOME not set, but found SDK at $dir"
            info "Add to shell profile: export ANDROID_HOME=$dir"
            export ANDROID_HOME="$dir"
            break
        fi
    done
    if [ -z "${ANDROID_HOME:-}" ]; then
        fail "ANDROID_HOME not set and SDK not found in common locations"
    fi
fi
echo ""

# ── Java / JDK ──────────────────────────────────────────
echo "☕ Java / JDK"
if command -v java &>/dev/null; then
    JAVA_VER=$(java -version 2>&1 | head -1 | awk -F '"' '{print $2}')
    pass "Java: $JAVA_VER"
    JAVA_MAJOR=$(echo "$JAVA_VER" | cut -d. -f1)
    if [ "$JAVA_MAJOR" -lt 17 ]; then
        warn "Java 17+ recommended for modern Android (found $JAVA_MAJOR)"
    fi
else
    fail "Java not found. Install JDK 17+"
fi

if [ -n "${JAVA_HOME:-}" ]; then
    pass "JAVA_HOME=$JAVA_HOME"
else
    warn "JAVA_HOME not set (may cause Gradle issues)"
fi
echo ""

# ── CLI Tools ───────────────────────────────────────────
echo "🔧 CLI Tools"

check_tool() {
    local tool=$1
    local desc=$2
    local hint=${3:-""}
    if command -v "$tool" &>/dev/null; then
        local ver
        case "$tool" in
            adb) ver=$(adb version 2>&1 | head -1 | sed 's/.*version //');;
            emulator) ver=$(emulator -version 2>&1 | head -1 | sed 's/.*emulator version //' | cut -d' ' -f1);;
            gradle) ver=$(gradle --version 2>&1 | grep "Gradle " | awk '{print $2}');;
            *) ver="found";;
        esac
        pass "$desc: $ver"
    else
        if [ -n "$hint" ]; then
            fail "$desc not found — $hint"
        else
            fail "$desc not found"
        fi
    fi
}

check_tool adb "ADB (Android Debug Bridge)" "Install via: sdkmanager platform-tools"
check_tool emulator "Android Emulator" "Install via: sdkmanager emulator"
check_tool avdmanager "AVD Manager" "Should be in \$ANDROID_HOME/cmdline-tools/latest/bin/"
check_tool sdkmanager "SDK Manager" "Should be in \$ANDROID_HOME/cmdline-tools/latest/bin/"
check_tool aapt2 "AAPT2" "Bundled with build-tools"

# Optional tools
if command -v apkanalyzer &>/dev/null; then
    pass "APK Analyzer: found"
else
    warn "APK Analyzer not in PATH (optional)"
fi

if command -v bundletool &>/dev/null; then
    pass "Bundletool: found"
else
    warn "Bundletool not in PATH (optional, for AAB management)"
fi

if command -v scrcpy &>/dev/null; then
    pass "scrcpy: found (screen mirroring)"
else
    info "scrcpy not found (optional, install for screen mirroring)"
fi

if command -v ktlint &>/dev/null; then
    pass "ktlint: found"
else
    info "ktlint not found (optional Kotlin linter)"
fi
echo ""

# ── Gradle Wrapper ──────────────────────────────────────
echo "🏗️  Gradle Wrapper"
if [ -f "./gradlew" ]; then
    if [ -x "./gradlew" ]; then
        GRADLEW_VER=$(./gradlew --version 2>&1 | grep "Gradle " | awk '{print $2}')
        pass "gradlew found: Gradle $GRADLEW_VER"
    else
        warn "gradlew exists but is not executable. Run: chmod +x gradlew"
    fi
else
    info "No gradlew in current directory (run from project root)"
fi
echo ""

# ── Connected Devices ───────────────────────────────────
echo "📱 Connected Devices"
if command -v adb &>/dev/null; then
    DEVICES=$(adb devices 2>/dev/null | grep -v "List" | grep -v "^$" || true)
    if [ -n "$DEVICES" ]; then
        while IFS= read -r line; do
            SERIAL=$(echo "$line" | awk '{print $1}')
            STATE=$(echo "$line" | awk '{print $2}')
            if [ "$STATE" = "device" ]; then
                MODEL=$(adb -s "$SERIAL" shell getprop ro.product.model 2>/dev/null || echo "unknown")
                API=$(adb -s "$SERIAL" shell getprop ro.build.version.sdk 2>/dev/null || echo "?")
                pass "$SERIAL — $MODEL (API $API)"
            elif [ "$STATE" = "offline" ]; then
                warn "$SERIAL — offline"
            elif [ "$STATE" = "unauthorized" ]; then
                warn "$SERIAL — unauthorized (check device for USB debugging prompt)"
            fi
        done <<< "$DEVICES"
    else
        info "No devices connected"
    fi
else
    fail "Cannot check devices — adb not found"
fi
echo ""

# ── Available Emulators ─────────────────────────────────
echo "🖥️  Available Emulators"
if command -v emulator &>/dev/null; then
    AVDS=$(emulator -list-avds 2>/dev/null || true)
    if [ -n "$AVDS" ]; then
        while IFS= read -r avd; do
            pass "$avd"
        done <<< "$AVDS"
    else
        info "No AVDs created yet"
    fi
else
    info "Emulator not found — skipping AVD check"
fi
echo ""

# ── PATH Check ──────────────────────────────────────────
echo "🛤️  PATH Entries"
if [ -n "${ANDROID_HOME:-}" ]; then
    for subdir in "platform-tools" "emulator" "cmdline-tools/latest/bin" "build-tools/$(ls "$ANDROID_HOME/build-tools/" 2>/dev/null | sort -V | tail -1)" ; do
        FULL="$ANDROID_HOME/$subdir"
        if echo "$PATH" | tr ':' '\n' | grep -q "$FULL" 2>/dev/null; then
            pass "$FULL in PATH"
        elif [ -d "$FULL" ]; then
            warn "$FULL exists but NOT in PATH"
        fi
    done
fi
echo ""

# ── Summary ─────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e " Results: ${GREEN}$PASS passed${NC}, ${YELLOW}$WARN warnings${NC}, ${RED}$FAIL failed${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $FAIL -gt 0 ]; then
    echo ""
    echo "Fix the failures above before proceeding with Android development."
    exit 1
fi

---
name: android-dev
description: >
  Comprehensive Android development skill integrating Gemini CLI with Android Studio, ADB,
  Gradle, emulator management, and the full Android SDK toolchain. Use this skill whenever the
  user mentions Android development, ADB commands, Android Studio, APK building, emulator setup,
  Gradle tasks, Android debugging, logcat, device management, Android testing, or any mobile
  development targeting Android. Also trigger when user mentions React Native or Flutter projects
  that target Android, Kotlin/Java mobile development, or asks about Play Store deployment.
---

# Android Development Skill for Gemini CLI

This skill enables Gemini CLI to serve as a full Android development copilot — building, debugging,
deploying, testing, and managing Android projects alongside Android Studio and ADB.

## Quick Reference

Before diving into a task, determine which reference file to read:

| Task | Reference |
|------|-----------|
| ADB device management, debugging, shell | `references/adb-commands.md` |
| Gradle builds, signing, dependencies | `references/gradle-commands.md` |
| Emulator & SDK management | `references/emulator-sdk.md` |
| Android Studio CLI integration | `references/studio-cli.md` |
| Testing (unit, instrumented, UI) | `references/testing.md` |

Read the relevant reference file BEFORE executing commands. Each contains battle-tested patterns
and edge-case handling.

## Environment Setup

Before any Android work, verify the environment:

```bash
# Run the environment check script
./scripts/check_env.sh
```

This validates:
- `ANDROID_HOME` / `ANDROID_SDK_ROOT` is set
- `adb`, `gradle`/`gradlew`, `sdkmanager`, `avdmanager`, `emulator` are in PATH
- At least one device or emulator is connected
- Java/JDK version is compatible

If the environment check fails, guide the user through setup based on their OS.

## Core Workflows

### 1. Build & Deploy

The most common workflow — build an APK/AAB and install it on a device:

```bash
# Clean build
./gradlew clean assembleDebug

# Install on connected device
./gradlew installDebug

# Or manually with ADB
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

For release builds, read `references/gradle-commands.md` for signing configuration.

### 2. Debug & Inspect

Stream logs filtered by app package:

```bash
# Get the app's PID
adb shell pidof -s com.example.app

# Stream filtered logs
adb logcat --pid=<PID>

# Or filter by tag
adb logcat -s MyAppTag:D *:S
```

For advanced debugging (layout inspector, memory profiling, network inspection),
read `references/adb-commands.md`.

### 3. Test

```bash
# Unit tests
./gradlew test

# Instrumented tests (requires device/emulator)
./gradlew connectedAndroidTest

# Specific test class
./gradlew test --tests "com.example.MyTest"
```

Read `references/testing.md` for Espresso, UI Automator, and screenshot testing patterns.

### 4. Emulator Management

```bash
# List available AVDs
emulator -list-avds

# Launch emulator
emulator -avd Pixel_7_API_34 -no-snapshot-load

# Create new AVD
avdmanager create avd -n "Pixel_7_API_34" \
  -k "system-images;android-34;google_apis;x86_64" \
  -d "pixel_7"
```

Read `references/emulator-sdk.md` for headless CI, snapshot management, and system image installation.

## Project Scaffolding

When the user asks to create a new Android project from the CLI (without Android Studio UI):

```bash
# Use the scaffolding script
./scripts/scaffold_project.sh <project-name> <package-name> [--compose] [--min-sdk 24]
```

This creates a standard project structure with:
- Kotlin as the default language
- Material 3 / Jetpack Compose (if `--compose` flag)
- Version catalog (`libs.versions.toml`)
- Standard Gradle wrapper

## Common Patterns

### Multi-device deployment
```bash
# Deploy to all connected devices
adb devices | grep -v "List" | awk '{print $1}' | xargs -I {} adb -s {} install -r app.apk
```

### Wireless debugging (Android 11+)
```bash
adb pair <ip>:<pairing_port>    # Enter pairing code
adb connect <ip>:<connect_port>
```

### Deep links testing
```bash
adb shell am start -a android.intent.action.VIEW \
  -d "myapp://screen/detail?id=123" \
  com.example.app
```

### Screenshot & screen recording
```bash
adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png .
adb shell screenrecord /sdcard/demo.mp4  # Ctrl+C to stop, then adb pull
```

## Error Recovery

When builds or deployments fail, follow this diagnostic flow:

1. **Build failure** → `./gradlew assembleDebug --stacktrace --info`
2. **Install failure** → `adb install -r -d app.apk` (allow downgrade) or `adb uninstall <pkg>` first
3. **Device not found** → `adb kill-server && adb start-server && adb devices`
4. **Emulator crash** → `emulator -avd <name> -wipe-data -no-snapshot-load`
5. **Gradle sync fail** → `./gradlew --stop && rm -rf .gradle && ./gradlew clean`
6. **SDK missing** → `sdkmanager --list | grep <needed>` then `sdkmanager "<package>"`

## Tool Categories

This skill provides commands in these categories:

### ADB Tools
- Device management, app lifecycle, file transfer, shell commands
- Log streaming with filters
- Screenshot and screen recording

### Gradle Tools
- Build tasks, dependency analysis, project info
- Testing, linting, signing

### Emulator Tools
- AVD management, launch, snapshot control
- Headless mode for CI/CD

### SDK Tools
- Package installation and updates
- License acceptance

### APK Analysis
- APK inspection, permissions, manifest

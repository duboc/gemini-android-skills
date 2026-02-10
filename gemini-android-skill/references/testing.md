# Android Testing Reference

## Table of Contents
- [Test Types Overview](#test-types-overview)
- [Unit Tests (JVM)](#unit-tests-jvm)
- [Instrumented Tests](#instrumented-tests)
- [UI Tests (Espresso)](#ui-tests-espresso)
- [UI Tests (Compose)](#ui-tests-compose)
- [UI Automator](#ui-automator)
- [Screenshot Tests](#screenshot-tests)
- [CLI Test Execution](#cli-test-execution)
- [Coverage](#coverage)
- [CI Integration](#ci-integration)

---

## Test Types Overview

| Type | Location | Runs on | Speed | Use for |
|------|----------|---------|-------|---------|
| Unit (JVM) | `src/test/` | JVM | Fast | Business logic, ViewModels, repos |
| Instrumented | `src/androidTest/` | Device/Emulator | Slow | DB, SharedPrefs, Context-dependent |
| UI (Espresso) | `src/androidTest/` | Device/Emulator | Slow | View-based UI interactions |
| UI (Compose) | `src/androidTest/` | Device/Emulator | Slow | Compose UI interactions |
| UI Automator | `src/androidTest/` | Device/Emulator | Slow | Cross-app, system-level testing |
| Screenshot | `src/test/` or `androidTest/` | Varies | Medium | Visual regression |

## Unit Tests (JVM)

Located in `app/src/test/java/` or `app/src/test/kotlin/`.

```bash
# Run all unit tests
./gradlew test

# Specific variant
./gradlew testDebugUnitTest

# Specific class
./gradlew test --tests "com.example.MyViewModelTest"

# Specific method
./gradlew test --tests "com.example.MyViewModelTest.testLoadData"

# Pattern matching
./gradlew test --tests "*ViewModel*"

# Multiple filters
./gradlew test --tests "*ViewModel*" --tests "*Repository*"

# With logging output
./gradlew test --info

# Rerun failures only
./gradlew test --rerun
```

**Test report:** `app/build/reports/tests/testDebugUnitTest/index.html`

## Instrumented Tests

Located in `app/src/androidTest/java/` or `app/src/androidTest/kotlin/`.
Requires a connected device or running emulator.

```bash
# Run all instrumented tests
./gradlew connectedAndroidTest

# Specific variant
./gradlew connectedDebugAndroidTest

# Specific module
./gradlew :app:connectedDebugAndroidTest

# Using adb directly (more control)
adb shell am instrument -w \
  -e class com.example.MyInstrumentedTest \
  com.example.app.test/androidx.test.runner.AndroidJUnitRunner

# Specific method via adb
adb shell am instrument -w \
  -e class com.example.MyInstrumentedTest#testMethod \
  com.example.app.test/androidx.test.runner.AndroidJUnitRunner

# Filter by annotation
adb shell am instrument -w \
  -e annotation androidx.test.filters.LargeTest \
  com.example.app.test/androidx.test.runner.AndroidJUnitRunner

# Clear app data before test
adb shell pm clear com.example.app
./gradlew connectedAndroidTest
```

**Test report:** `app/build/reports/androidTests/connected/index.html`

## UI Tests (Espresso)

```bash
# Run Espresso tests
./gradlew connectedAndroidTest

# Disable animations for reliable tests (run before tests)
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0

# Re-enable after tests
adb shell settings put global window_animation_scale 1
adb shell settings put global transition_animation_scale 1
adb shell settings put global animator_duration_scale 1

# Grant permissions automatically (avoid dialogs)
adb shell pm grant com.example.app android.permission.CAMERA
adb shell pm grant com.example.app android.permission.ACCESS_FINE_LOCATION
```

## UI Tests (Compose)

```bash
# Same execution as instrumented tests
./gradlew connectedAndroidTest

# Compose tests use ComposeTestRule
# Run with specific test runner for better compose support
adb shell am instrument -w \
  -e class com.example.ui.MyComposeTest \
  com.example.app.test/androidx.test.runner.AndroidJUnitRunner
```

## UI Automator

For cross-app testing and system interactions:

```bash
# Dump UI hierarchy (useful for finding selectors)
adb shell uiautomator dump /sdcard/ui_dump.xml
adb pull /sdcard/ui_dump.xml .

# View the hierarchy
cat ui_dump.xml | xmllint --format -

# Run UI Automator tests (same as instrumented)
./gradlew connectedAndroidTest
```

## Screenshot Tests

### Roborazzi (JVM-based, no device needed)
```bash
# Record baseline screenshots
./gradlew recordRoborazziDebug

# Verify screenshots (compare against baseline)
./gradlew verifyRoborazziDebug

# Generate comparison images
./gradlew compareRoborazziDebug
```

### Paparazzi (JVM-based, no device needed)
```bash
# Record golden screenshots
./gradlew recordPaparazziDebug

# Verify against golden
./gradlew verifyPaparazziDebug
```

## CLI Test Execution

### Running tests with filters via Gradle

```bash
# Include/exclude by package
./gradlew test -Pandroid.testInstrumentationRunnerArguments.package=com.example.unit

# With test orchestrator (isolates each test)
# Requires in build.gradle:
# android.testOptions.execution = 'ANDROIDX_TEST_ORCHESTRATOR'
./gradlew connectedAndroidTest

# Output test results as JUnit XML (default)
# Location: app/build/test-results/

# Output test results as HTML
# Location: app/build/reports/tests/
```

### Running tests via adb shell

```bash
# Run with orchestrator via adb
CLASSPATH=$(pm path androidx.test.orchestrator)
app_process / androidx.test.orchestrator.AndroidTestOrchestrator \
  -e targetInstrumentation com.example.app.test/androidx.test.runner.AndroidJUnitRunner

# List test methods
adb shell am instrument -w -e log true \
  com.example.app.test/androidx.test.runner.AndroidJUnitRunner

# Sharding for parallel execution
adb shell am instrument -w \
  -e numShards 4 -e shardIndex 0 \
  com.example.app.test/androidx.test.runner.AndroidJUnitRunner
```

## Coverage

```bash
# Enable coverage in build.gradle.kts
# android {
#     buildTypes {
#         debug {
#             enableAndroidTestCoverage = true
#             enableUnitTestCoverage = true
#         }
#     }
# }

# Generate unit test coverage
./gradlew testDebugUnitTestCoverage

# Generate instrumented test coverage
./gradlew createDebugAndroidTestCoverageReport

# JaCoCo report
./gradlew jacocoTestReport

# Coverage reports at:
# app/build/reports/coverage/androidTest/debug/index.html
# app/build/reports/jacoco/
```

## CI Integration

### Parallel test execution on multiple devices
```bash
# List connected devices
adb devices -l

# Run tests on specific device
adb -s <serial> shell am instrument -w \
  com.example.app.test/androidx.test.runner.AndroidJUnitRunner

# Shard across devices (manual)
adb -s device1 shell am instrument -w -e numShards 2 -e shardIndex 0 ...
adb -s device2 shell am instrument -w -e numShards 2 -e shardIndex 1 ...
```

### Flaky test retry
```bash
# Via Gradle (requires custom config or plugin)
./gradlew connectedAndroidTest -Pandroid.testInstrumentationRunnerArguments.reruns=3

# Or use orchestrator with clearPackageData for isolation
# android.testOptions.execution = 'ANDROIDX_TEST_ORCHESTRATOR'
```

### Test result collection
```bash
# Pull test results from device
adb pull /sdcard/Android/data/com.example.app.test/files/ ./test-outputs/

# JUnit XML results (for CI parsers like JUnit Report)
# app/build/test-results/testDebugUnitTest/*.xml
# app/build/outputs/androidTest-results/connected/*.xml
```

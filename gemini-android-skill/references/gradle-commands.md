# Gradle Commands Reference

## Table of Contents
- [Build Tasks](#build-tasks)
- [Install & Run](#install--run)
- [Dependencies](#dependencies)
- [Testing](#testing)
- [Signing](#signing)
- [Analysis & Lint](#analysis--lint)
- [Module Management](#module-management)
- [Performance & Troubleshooting](#performance--troubleshooting)
- [Version Catalog](#version-catalog)

---

Always prefer `./gradlew` (project wrapper) over system `gradle` to ensure version consistency.

## Build Tasks

```bash
# List all available tasks
./gradlew tasks
./gradlew tasks --all                        # Include sub-tasks

# Assemble
./gradlew assembleDebug                      # Debug APK
./gradlew assembleRelease                    # Release APK
./gradlew assemble                           # All variants

# Bundle (AAB for Play Store)
./gradlew bundleDebug
./gradlew bundleRelease

# Clean
./gradlew clean
./gradlew clean assembleDebug                # Clean + build

# Build specific module
./gradlew :app:assembleDebug
./gradlew :feature:auth:assembleDebug

# Build with options
./gradlew assembleDebug --stacktrace         # Full stacktrace on error
./gradlew assembleDebug --info               # Info-level logging
./gradlew assembleDebug --debug              # Debug-level logging
./gradlew assembleDebug --scan               # Build scan (uploads to gradle.com)
./gradlew assembleDebug --profile            # Generate build profile report
./gradlew assembleDebug --dry-run            # Show tasks without executing
./gradlew assembleDebug -x test             # Skip tests

# Build variants
./gradlew assembleFreeDebug                  # Flavor + build type
./gradlew assemblePaidRelease
```

## Install & Run

```bash
# Install on connected device
./gradlew installDebug
./gradlew installRelease

# Uninstall
./gradlew uninstallDebug
./gradlew uninstallRelease
./gradlew uninstallAll

# Install + run main activity
./gradlew installDebug && \
  adb shell am start -n com.example.app/.MainActivity
```

## Dependencies

```bash
# Show dependency tree
./gradlew dependencies
./gradlew :app:dependencies
./gradlew :app:dependencies --configuration implementationDependenciesMetadata

# Check for dependency updates (requires ben-manes/gradle-versions-plugin)
./gradlew dependencyUpdates

# Resolve a specific dependency
./gradlew dependencyInsight --dependency <group:artifact>
./gradlew :app:dependencyInsight --dependency androidx.core:core-ktx

# Refresh dependencies (bypass cache)
./gradlew build --refresh-dependencies

# Lock dependencies
./gradlew dependencies --write-locks
```

## Testing

```bash
# Unit tests (JVM)
./gradlew test                                # All modules
./gradlew :app:test                          # Specific module
./gradlew :app:testDebugUnitTest             # Specific variant
./gradlew test --tests "*.MyTestClass"       # Specific class
./gradlew test --tests "*.MyTestClass.myMethod"  # Specific method

# Instrumented tests (requires device/emulator)
./gradlew connectedAndroidTest
./gradlew connectedDebugAndroidTest
./gradlew :app:connectedAndroidTest

# Test with coverage (JaCoCo)
./gradlew testDebugUnitTestCoverage
./gradlew jacocoTestReport

# Test reports location
# Unit: app/build/reports/tests/testDebugUnitTest/index.html
# Instrumented: app/build/reports/androidTests/connected/index.html
# Coverage: app/build/reports/jacoco/

# Re-run failed tests only
./gradlew test --rerun

# Continue on failure
./gradlew test --continue
```

## Signing

```bash
# Generate a keystore
keytool -genkey -v \
  -keystore release.keystore \
  -alias myapp \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# View keystore info
keytool -list -v -keystore release.keystore

# Show signing report (SHA-1, SHA-256)
./gradlew signingReport

# Verify APK signature
apksigner verify --verbose app-release.apk
jarsigner -verify -verbose -certs app-release.apk
```

**build.gradle.kts signing config:**
```kotlin
android {
    signingConfigs {
        create("release") {
            storeFile = file("release.keystore")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = "myapp"
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

## Analysis & Lint

```bash
# Android Lint
./gradlew lint
./gradlew :app:lintDebug
./gradlew lintRelease
# Report: app/build/reports/lint-results-debug.html

# Kotlin lint (ktlint, if configured)
./gradlew ktlintCheck
./gradlew ktlintFormat

# Detekt (static analysis for Kotlin)
./gradlew detekt

# APK analysis
./gradlew analyzeDebugBundle    # Bundle analysis

# Using apkanalyzer CLI
apkanalyzer apk summary app-debug.apk
apkanalyzer apk file-size app-debug.apk
apkanalyzer dex references app-debug.apk         # Method count
apkanalyzer manifest print app-debug.apk
apkanalyzer manifest permissions app-debug.apk
apkanalyzer resources packages app-debug.apk
```

## Module Management

```bash
# List all modules/subprojects
./gradlew projects

# Build specific module
./gradlew :feature:login:assembleDebug

# Module dependency graph
./gradlew :app:dependencies --configuration implementation

# Check for unused dependencies (requires dependency-analysis plugin)
./gradlew buildHealth
```

## Performance & Troubleshooting

```bash
# Stop Gradle daemon
./gradlew --stop

# Run without daemon
./gradlew assembleDebug --no-daemon

# Clear Gradle caches
rm -rf ~/.gradle/caches/
rm -rf .gradle/
rm -rf build/
rm -rf app/build/

# Nuclear clean (when nothing else works)
./gradlew --stop
rm -rf .gradle/ build/ app/build/
rm -rf ~/.gradle/caches/transforms-*
./gradlew clean assembleDebug

# Configuration cache (Gradle 8+)
./gradlew assembleDebug --configuration-cache

# Build cache
./gradlew assembleDebug --build-cache

# Parallel execution
./gradlew assembleDebug --parallel

# Max workers
./gradlew assembleDebug --max-workers=4

# Memory settings (gradle.properties)
# org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=512m
# org.gradle.parallel=true
# org.gradle.caching=true
# org.gradle.configuration-cache=true
```

## Version Catalog

Modern Android projects use `gradle/libs.versions.toml`:

```bash
# View the version catalog
cat gradle/libs.versions.toml

# After modifying the catalog, sync:
./gradlew --refresh-dependencies
```

**Example libs.versions.toml:**
```toml
[versions]
agp = "8.7.0"
kotlin = "2.0.21"
compose-bom = "2024.10.00"
core-ktx = "1.13.1"

[libraries]
androidx-core-ktx = { group = "androidx.core", name = "core-ktx", version.ref = "core-ktx" }
compose-bom = { group = "androidx.compose", name = "compose-bom", version.ref = "compose-bom" }

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
compose-compiler = { id = "org.jetbrains.kotlin.plugin.compose", version.ref = "kotlin" }
```

## Useful Gradle Properties

Add to `gradle.properties` for better performance:

```properties
# Performance
org.gradle.jvmargs=-Xmx4g -XX:+HeapDumpOnOutOfMemoryError
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configuration-cache=true
org.gradle.daemon=true

# Android specific
android.useAndroidX=true
android.nonTransitiveRClass=true
android.defaults.buildfeatures.buildconfig=false

# Kotlin
kotlin.code.style=official
kotlin.incremental=true
```

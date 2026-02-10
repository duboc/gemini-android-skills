# GEMINI.md — Android Project Instructions

This is an Android project. Use the android-dev skill for all build, test, deploy, and debug operations.

## Project Setup

- **Build system:** Gradle with Kotlin DSL
- **Language:** Kotlin
- **Min SDK:** 24
- **Target SDK:** 34
- **Architecture:** MVVM with Jetpack Compose / Views

## Common Commands

```bash
# Build
./gradlew assembleDebug

# Test
./gradlew test                        # Unit tests
./gradlew connectedAndroidTest        # Instrumented tests

# Deploy
./gradlew installDebug                # Install to connected device
adb shell am start -n <pkg>/.MainActivity

# Logs
adb logcat --pid=$(adb shell pidof -s <pkg>)

# Clean
./gradlew clean
```

## Project Structure

```
app/
├── src/main/
│   ├── java/<package>/      # Kotlin source files
│   │   ├── data/            # Repositories, data sources
│   │   ├── domain/          # Use cases, models
│   │   ├── ui/              # Screens, ViewModels, composables
│   │   └── di/              # Dependency injection
│   ├── res/                 # Resources (layouts, strings, drawables)
│   └── AndroidManifest.xml
├── src/test/                # Unit tests (JVM)
├── src/androidTest/         # Instrumented tests (device)
└── build.gradle.kts
```

## Conventions

- Follow Kotlin coding conventions
- Use coroutines for async operations
- Use Flow for reactive streams
- Use Hilt for dependency injection
- Write unit tests for ViewModels and Repositories
- Write UI tests for critical user flows

## Before Pushing

1. `./gradlew test` — all unit tests pass
2. `./gradlew lint` — no critical lint issues
3. `./gradlew assembleRelease` — release build succeeds

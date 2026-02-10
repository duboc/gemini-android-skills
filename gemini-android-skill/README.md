# Android Development Skill for Gemini CLI

A comprehensive Android development skill that integrates Gemini CLI with Android Studio, ADB, Gradle, emulator management, and the full Android SDK toolchain.

## Quick Install

```bash
# Clone or download this skill
cd gemini-android-skill

# Run the setup script (installs to ~/.gemini/skills/)
./setup.sh

# Or install to a specific project (workspace scope)
./setup.sh /path/to/your/android-project

# Install to workspace scope only
./setup.sh --skill-only --scope workspace
```

### Alternative: Using Gemini CLI commands

```bash
# Install from local directory
gemini skills install /path/to/gemini-android-skill

# Link from local directory (creates symlink)
gemini skills link /path/to/gemini-android-skill

# Install to workspace scope
gemini skills install /path/to/gemini-android-skill --scope workspace
```

## What Gets Installed

### Skill Files (to `~/.gemini/skills/android-dev/`)

```
android-dev/
├── SKILL.md                          # Main skill entry point
├── references/
│   ├── adb-commands.md               # 200+ ADB commands organized by category
│   ├── gradle-commands.md            # Gradle build, test, signing, lint, deps
│   ├── emulator-sdk.md               # AVD/emulator management, CI headless mode
│   ├── studio-cli.md                 # Android Studio CLI + Gemini CLI integration
│   └── testing.md                    # Unit, instrumented, Espresso, Compose, UI Automator
└── scripts/
    ├── check_env.sh                  # Environment validation (SDK, Java, devices)
    └── scaffold_project.sh           # New project scaffolder (Compose or Views)
```

### Project Files (optional, to your Android project)

```
your-project/
└── GEMINI.md                         # Project instructions template
```

## Setup Options

```bash
# Basic setup - install skill globally
./setup.sh

# Install skill and configure project
./setup.sh /path/to/project

# Interactive mode - prompts for project name, package, SDK version
./setup.sh /path/to/project --interactive

# Force overwrite existing files
./setup.sh /path/to/project --force

# Don't create backups of existing files
./setup.sh /path/to/project --no-backup

# Install skill only (no project configuration)
./setup.sh --skill-only

# Install to workspace scope
./setup.sh --skill-only --scope workspace
```

## Skill Discovery

Gemini CLI discovers skills from three locations (in order of precedence):

1. **Workspace Skills** (`.gemini/skills/`) - Project-specific, committed to version control
2. **User Skills** (`~/.gemini/skills/`) - Personal, available across all projects
3. **Extension Skills** - Bundled within installed extensions

## Managing Skills

### In an Interactive Session

```bash
/skills list              # Show all discovered skills
/skills enable android-dev
/skills disable android-dev
/skills reload            # Refresh skill list
```

### From the Terminal

```bash
gemini skills list
gemini skills enable android-dev
gemini skills disable android-dev
gemini skills uninstall android-dev
```

## How It Works

1. **Discovery**: Gemini CLI scans skill directories and injects skill metadata into the system prompt
2. **Activation**: When you mention Android development, Gemini activates the skill via `activate_skill`
3. **Consent**: You'll see a confirmation prompt with the skill name and purpose
4. **Injection**: The SKILL.md and folder structure are added to the conversation context
5. **Execution**: Gemini proceeds with Android-specific expertise active

## Requirements

- Gemini CLI
- Android SDK
- Java 17+

## Environment Check

After installation, verify your environment:

```bash
~/.gemini/skills/android-dev/scripts/check_env.sh
```

This validates:
- `ANDROID_HOME` / `ANDROID_SDK_ROOT` is set
- Java/JDK version is compatible (17+ recommended)
- ADB, emulator, avdmanager, sdkmanager are in PATH
- Connected devices/emulators

## Usage in Gemini CLI

Once installed, Gemini CLI will automatically detect and use this skill when you work on Android projects. The skill provides:

1. **Build & Deploy**: `./gradlew assembleDebug`, `adb install`
2. **Debug & Inspect**: `adb logcat`, `adb shell dumpsys`
3. **Test**: `./gradlew test`, `./gradlew connectedAndroidTest`
4. **Emulator Management**: `emulator -avd`, `avdmanager create`
5. **Project Scaffolding**: Create new projects from CLI

### Example Prompts

```
"Build the debug APK and install it on my connected device"
"Show me the last 50 error logs from the app"
"Create a Pixel 8 emulator with API 34"
"Run all unit tests"
"What's in the AndroidManifest.xml?"
```

## Skill Triggers

The skill activates when you mention:
- Android development, ADB commands, Android Studio
- APK building, emulator setup, Gradle tasks
- Android debugging, logcat, device management
- Android testing, instrumented tests
- React Native or Flutter projects targeting Android
- Kotlin/Java mobile development
- Play Store deployment

## License

MIT

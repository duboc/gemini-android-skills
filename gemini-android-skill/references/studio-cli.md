# Android Studio CLI Integration Reference

## Table of Contents
- [Launching & Opening Projects](#launching--opening-projects)
- [Command-Line Inspections](#command-line-inspections)
- [Diff & Merge](#diff--merge)
- [Code Formatting](#code-formatting)
- [IDE Scripting](#ide-scripting)
- [Integration with Gemini CLI](#integration-with-gemini-cli)

---

## Setup

Add Android Studio to your PATH:

**macOS:**
```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="$PATH:/Applications/Android Studio.app/Contents/MacOS"
# Also useful:
alias studio="open -a 'Android Studio'"
```

**Linux:**
```bash
export PATH="$PATH:$HOME/android-studio/bin"
```

**Windows (PowerShell):**
```powershell
$env:PATH += ";C:\Program Files\Android\Android Studio\bin"
```

## Launching & Opening Projects

```bash
# Open project directory in Android Studio
studio <project-path>
studio .                          # Current directory

# Open specific file
studio <file-path>

# Open file at specific line
studio --line <line_number> <file-path>

# Open file at line and column
studio --line <line> --column <col> <file-path>

# Open in a new window (don't reuse existing)
studio --new-window <project-path>

# Wait for Studio to close before returning to terminal
studio --wait <project-path>

# Disable splash screen
studio nosplash <project-path>
```

## Command-Line Inspections

Run Android Studio inspections from the CLI (great for CI/CD):

```bash
# Run all inspections
studio inspect <project-path> <inspection-profile> <output-dir>

# Example
studio inspect ./MyApp .idea/inspectionProfiles/Project_Default.xml ./inspection-results

# With specific scope
studio inspect ./MyApp .idea/inspectionProfiles/Project_Default.xml ./inspection-results \
  -d <scope-name>

# The output directory will contain XML files with inspection results
# Parse them for CI integration
```

**Inspection profiles are located at:**
- Project-level: `<project>/.idea/inspectionProfiles/`
- IDE-level: `~/Library/Application Support/Google/AndroidStudio*/config/inspection/` (macOS)

## Diff & Merge

```bash
# Compare two files
studio diff <file1> <file2>

# Three-way merge
studio merge <file1> <file2> <base> <output>
```

## Code Formatting

```bash
# Format code using Android Studio formatter
studio format <file-or-dir>

# Format with specific style
studio format -s <code-style-config> <file-or-dir>

# Note: For Kotlin, prefer ktlint or ktfmt from CLI:
ktlint --format "**/*.kt"
# Or via Gradle if configured:
./gradlew ktlintFormat
```

## IDE Scripting

Android Studio supports running scripts through its built-in scripting console.
You can automate IDE actions:

```bash
# Run a Groovy/Kotlin script in the IDE
# First, enable: Help -> Edit Custom Properties -> idea.script.enabled=true
# Then use IDE Scripting Console (Tools -> IDE Scripting Console)
```

## Integration with Gemini CLI

### Workflow: Gemini CLI + Android Studio Side-by-Side

The ideal workflow uses Gemini CLI for file manipulation, builds, and ADB operations,
while Android Studio handles visual tasks (layout editor, profiler, debugger).

**Gemini CLI handles:**
- File creation, editing, refactoring
- `./gradlew` builds and test execution
- ADB commands (deploy, debug, logcat)
- Emulator management
- Git operations
- Dependency management
- Code generation (data classes, ViewModels, Compose components)

**Android Studio handles:**
- Layout Editor / Compose Preview
- Android Profiler (CPU, Memory, Network, Energy)
- Layout Inspector
- Database Inspector
- APK Analyzer (GUI)
- Device File Explorer
- Logcat with visual filters
- Debugger with breakpoints

### Opening Studio from Gemini CLI

```bash
# Open the current project in Studio
studio .

# Open a specific file for visual editing
studio app/src/main/res/layout/activity_main.xml

# Open after making changes (Studio will hot-reload)
# Just edit files - Studio auto-detects changes

# Trigger Gradle sync from CLI (Studio picks it up)
./gradlew prepareKotlinIdeaImport
```

### File Watchers

When Gemini CLI edits files, Android Studio detects changes automatically if:
- "Synchronize files on frame activation" is enabled (default)
- Files are within the project directory

If not syncing, trigger manually in Studio: File -> Synchronize (Cmd+Alt+Y / Ctrl+Alt+Y)

### Launching Profiling from CLI

```bash
# Start app in debug mode for profiler attachment
adb shell am start -D -n com.example.app/.MainActivity

# Then attach Android Studio's profiler to the running process

# Alternatively, capture a method trace from CLI
adb shell am profile start <package> /sdcard/trace.trace
# ... perform actions ...
adb shell am profile stop <package>
adb pull /sdcard/trace.trace .
# Open trace.trace in Android Studio: File -> Open
```

### Layout Inspection from CLI

```bash
# Dump view hierarchy
adb shell uiautomator dump /sdcard/ui_dump.xml
adb pull /sdcard/ui_dump.xml .

# Accessibility check
adb shell dumpsys accessibility
```

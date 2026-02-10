# Emulator & SDK Management Reference

## Table of Contents
- [SDK Manager](#sdk-manager)
- [AVD Manager](#avd-manager)
- [Emulator](#emulator)
- [System Images](#system-images)
- [CI/CD Headless Mode](#cicd-headless-mode)
- [Snapshot Management](#snapshot-management)
- [Troubleshooting](#troubleshooting)

---

## SDK Manager

```bash
# List all available and installed packages
sdkmanager --list

# List installed only
sdkmanager --list_installed

# Install packages
sdkmanager "platform-tools"
sdkmanager "platforms;android-34"
sdkmanager "build-tools;34.0.0"
sdkmanager "system-images;android-34;google_apis;x86_64"
sdkmanager "extras;google;google_play_services"
sdkmanager "ndk;26.1.10909125"
sdkmanager "cmake;3.22.1"

# Install multiple at once
sdkmanager "platforms;android-34" "build-tools;34.0.0" "sources;android-34"

# Update all installed packages
sdkmanager --update

# Uninstall
sdkmanager --uninstall "system-images;android-30;google_apis;x86"

# Accept all licenses (important for CI)
yes | sdkmanager --licenses

# Use specific SDK root
sdkmanager --sdk_root=/path/to/sdk --list

# Common packages to install for a new setup
sdkmanager \
  "platform-tools" \
  "platforms;android-34" \
  "platforms;android-33" \
  "build-tools;34.0.0" \
  "system-images;android-34;google_apis_playstore;x86_64" \
  "emulator" \
  "extras;intel;Hardware_Accelerated_Execution_Manager" \
  "sources;android-34"
```

## AVD Manager

```bash
# List existing AVDs
avdmanager list avd

# List available device profiles
avdmanager list device

# List available targets (API levels)
avdmanager list target

# Create AVD
avdmanager create avd \
  -n "Pixel_7_API_34" \
  -k "system-images;android-34;google_apis_playstore;x86_64" \
  -d "pixel_7"

# Create AVD with specific options
avdmanager create avd \
  -n "Tablet_API_34" \
  -k "system-images;android-34;google_apis;x86_64" \
  -d "pixel_tablet" \
  --sdcard 512M

# Create without prompt
avdmanager create avd \
  -n "CI_Device" \
  -k "system-images;android-34;google_apis;x86_64" \
  -d "pixel_7" \
  --force

# Delete AVD
avdmanager delete avd -n "Pixel_7_API_34"

# Move/rename AVD
avdmanager move avd -n "old_name" -r "new_name"

# Common device definitions
# pixel_7, pixel_7_pro, pixel_8, pixel_8_pro
# pixel_tablet, pixel_fold
# medium_phone, medium_tablet
# automotive_1024p_landscape
# tv_1080p, wear_round
```

## Emulator

```bash
# List available AVDs
emulator -list-avds

# Launch emulator
emulator -avd Pixel_7_API_34

# Launch options
emulator -avd Pixel_7_API_34 -no-snapshot-load    # Fresh boot
emulator -avd Pixel_7_API_34 -no-snapshot-save     # Don't save state
emulator -avd Pixel_7_API_34 -no-snapshot           # No snapshots at all
emulator -avd Pixel_7_API_34 -wipe-data            # Factory reset
emulator -avd Pixel_7_API_34 -no-window            # Headless
emulator -avd Pixel_7_API_34 -no-audio             # No audio
emulator -avd Pixel_7_API_34 -no-boot-anim         # Skip boot animation
emulator -avd Pixel_7_API_34 -gpu swiftshader_indirect  # Software GPU
emulator -avd Pixel_7_API_34 -gpu host             # Hardware GPU
emulator -avd Pixel_7_API_34 -memory 4096          # 4GB RAM
emulator -avd Pixel_7_API_34 -cores 4              # 4 CPU cores
emulator -avd Pixel_7_API_34 -port 5556            # Custom port
emulator -avd Pixel_7_API_34 -dns-server 8.8.8.8   # Custom DNS
emulator -avd Pixel_7_API_34 -http-proxy proxy:8080 # HTTP proxy
emulator -avd Pixel_7_API_34 -read-only            # Read-only system

# Network simulation
emulator -avd Pixel_7_API_34 -netdelay edge        # Edge latency
emulator -avd Pixel_7_API_34 -netspeed lte         # LTE speed
# Options: gsm, hscsd, gprs, edge, umts, hsdpa, lte, evdo, none, full

# Screen size override
emulator -avd Pixel_7_API_34 -skin 1080x2400

# Camera
emulator -avd Pixel_7_API_34 -camera-back virtualscene
emulator -avd Pixel_7_API_34 -camera-front webcam0

# Verbose boot
emulator -avd Pixel_7_API_34 -verbose

# Check version
emulator -version

# Emulator console (via telnet)
telnet localhost 5554
# Console commands: help, kill, rotate, geo fix <lng> <lat>, sms send <phone> <msg>
# power capacity 15, network delay edge
```

## System Images

```bash
# List available system images
sdkmanager --list | grep "system-images"

# Types of system images:
# google_apis          — Google APIs (no Play Store)
# google_apis_playstore — Google APIs + Play Store
# default              — AOSP (no Google services)
# android-wear         — Wear OS
# android-tv           — Android TV
# android-automotive   — Android Automotive

# Architecture:
# x86_64  — Intel/AMD (fastest on x86 hosts, recommended)
# x86     — 32-bit Intel/AMD
# arm64-v8a — ARM (required for Apple Silicon Macs)

# Install recommended images
sdkmanager "system-images;android-34;google_apis_playstore;x86_64"    # Latest
sdkmanager "system-images;android-34;google_apis_playstore;arm64-v8a" # Apple Silicon
sdkmanager "system-images;android-28;google_apis;x86_64"              # Oldest common target
```

## CI/CD Headless Mode

For running emulators in CI environments (GitHub Actions, Jenkins, etc.):

```bash
# Create AVD silently
echo "no" | avdmanager create avd \
  -n "ci_device" \
  -k "system-images;android-34;google_apis;x86_64" \
  -d "pixel_7" \
  --force

# Launch headless
emulator -avd ci_device \
  -no-window \
  -no-audio \
  -no-boot-anim \
  -no-snapshot \
  -gpu swiftshader_indirect &

# Wait for device to be ready
adb wait-for-device
# Wait for boot to complete
adb shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done'

# Disable animations (faster UI tests)
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0

# Run tests
./gradlew connectedAndroidTest

# Kill emulator
adb emu kill
```

**GitHub Actions example snippet:**
```yaml
- name: Start emulator
  run: |
    echo "no" | avdmanager create avd -n test -k "system-images;android-34;google_apis;x86_64" -d pixel_7 --force
    emulator -avd test -no-window -no-audio -no-boot-anim -gpu swiftshader_indirect &
    adb wait-for-device
    adb shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done'
    adb shell settings put global window_animation_scale 0
    adb shell settings put global transition_animation_scale 0
    adb shell settings put global animator_duration_scale 0
```

## Snapshot Management

```bash
# Save snapshot
adb emu avd snapshot save "clean_state"

# Load snapshot
adb emu avd snapshot load "clean_state"

# List snapshots
adb emu avd snapshot list

# Delete snapshot
adb emu avd snapshot delete "clean_state"

# Snapshots are stored in:
# ~/.android/avd/<avd_name>.avd/snapshots/
```

## Troubleshooting

### Emulator won't start
```bash
# Check hardware acceleration
emulator -accel-check

# On Linux: KVM
sudo apt install qemu-kvm
sudo adduser $USER kvm

# On macOS: Hypervisor.framework (automatic)
# On Windows: HAXM or Hyper-V

# Cold boot if snapshot is corrupted
emulator -avd <name> -no-snapshot-load -wipe-data
```

### Emulator is slow
```bash
# Use hardware GPU acceleration
emulator -avd <name> -gpu host

# Increase RAM
emulator -avd <name> -memory 4096

# Use x86_64 images (not ARM) on Intel/AMD hosts
# Use arm64-v8a on Apple Silicon
```

### "INSTALL_FAILED_NO_MATCHING_ABIS"
The APK doesn't support the emulator's architecture. Either:
- Use a system image matching your APK's ABI
- Build with `abiFilters` including the emulator's ABI

### AVD config file location
```bash
# AVD configs are at:
~/.android/avd/<name>.avd/config.ini

# Useful config.ini edits:
# hw.ramSize=4096
# hw.lcd.density=420
# hw.keyboard=yes
# disk.dataPartition.size=8G
```

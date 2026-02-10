# ADB Commands Reference

## Table of Contents
- [Device Management](#device-management)
- [App Management](#app-management)
- [File Transfer](#file-transfer)
- [Shell & Input](#shell--input)
- [Debugging & Inspection](#debugging--inspection)
- [Network](#network)
- [Screen Capture](#screen-capture)
- [Battery & Power](#battery--power)
- [Advanced](#advanced)

---

## Device Management

```bash
# List connected devices with details
adb devices -l

# Target specific device (when multiple connected)
adb -s <serial> <command>

# Restart ADB server (fixes most connection issues)
adb kill-server && adb start-server

# USB debugging
adb usb

# Wireless debugging (Android 11+)
adb pair <ip>:<pairing_port>       # Enter the 6-digit code shown on device
adb connect <ip>:<connect_port>    # Connect after pairing
adb disconnect <ip>:<port>         # Disconnect specific device
adb disconnect                     # Disconnect all

# Legacy wireless (Android 10 and below, requires USB first)
adb tcpip 5555
adb connect <device_ip>:5555

# Device properties
adb shell getprop ro.build.version.release    # Android version
adb shell getprop ro.build.version.sdk        # API level
adb shell getprop ro.product.model            # Device model
adb shell getprop ro.product.manufacturer     # Manufacturer
adb shell getprop ro.serialno                 # Serial number

# Reboot variants
adb reboot
adb reboot bootloader
adb reboot recovery
adb reboot sideload
```

## App Management

```bash
# Install
adb install <path.apk>
adb install -r <path.apk>              # Replace existing (keep data)
adb install -r -d <path.apk>           # Allow version downgrade
adb install -r -t <path.apk>           # Allow test APK
adb install-multiple <split1> <split2>  # Install split APKs

# Uninstall
adb uninstall <package>
adb uninstall -k <package>             # Keep data and cache

# Package listing
adb shell pm list packages                    # All packages
adb shell pm list packages -3                 # Third-party only
adb shell pm list packages -s                 # System only
adb shell pm list packages | grep <filter>    # Search
adb shell pm list packages -f                 # Show APK file paths

# App data
adb shell pm clear <package>            # Clear all app data
adb shell pm path <package>             # Get APK path on device

# Activity management
adb shell am start -n <package>/<activity>
adb shell am start -a android.intent.action.VIEW -d "https://example.com"
adb shell am start -a android.intent.action.VIEW -d "myapp://deeplink"
adb shell am force-stop <package>
adb shell am kill <package>
adb shell am broadcast -a <action>

# Services
adb shell am startservice -n <package>/<service>
adb shell am stopservice -n <package>/<service>

# Permissions
adb shell pm grant <package> <permission>
adb shell pm revoke <package> <permission>
adb shell dumpsys package <package> | grep permission

# Disable/Enable
adb shell pm disable-user --user 0 <package>
adb shell pm enable <package>
```

## File Transfer

```bash
# Push file to device
adb push <local_path> <device_path>
adb push ./config.json /sdcard/Download/

# Pull file from device
adb pull <device_path> <local_path>
adb pull /sdcard/Download/log.txt ./

# Sync directories
adb push <local_dir> <device_dir>

# List files on device
adb shell ls -la /sdcard/
adb shell find /sdcard/ -name "*.log"
```

## Shell & Input

```bash
# Interactive shell
adb shell

# Run a single command
adb shell <command>

# Run as root (if available)
adb root
adb shell su -c "<command>"

# Simulate user input
adb shell input text "hello world"          # Type text
adb shell input tap <x> <y>                 # Tap at coordinates
adb shell input swipe <x1> <y1> <x2> <y2> <duration_ms>
adb shell input keyevent <keycode>

# Common keycodes
adb shell input keyevent 3      # HOME
adb shell input keyevent 4      # BACK
adb shell input keyevent 26     # POWER
adb shell input keyevent 82     # MENU
adb shell input keyevent 187    # APP_SWITCH (Recent apps)
adb shell input keyevent 224    # WAKEUP
adb shell input keyevent 223    # SLEEP
adb shell input keyevent 61     # TAB
adb shell input keyevent 66     # ENTER
adb shell input keyevent 67     # DEL (backspace)

# Settings
adb shell settings put global window_animation_scale 0     # Disable animations
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0
adb shell settings put system screen_brightness 255         # Max brightness
adb shell settings put system screen_off_timeout 600000     # 10min screen timeout
```

## Debugging & Inspection

```bash
# Logcat
adb logcat                                      # All logs
adb logcat -v time                              # With timestamps
adb logcat -v threadtime                        # Thread + timestamps
adb logcat *:E                                  # Errors only
adb logcat -s TAG:D                             # Specific tag, debug+
adb logcat --pid=$(adb shell pidof -s <pkg>)    # Filter by app PID
adb logcat -c                                   # Clear log buffer
adb logcat -d > logcat.txt                      # Dump and exit
adb logcat -b crash                             # Crash buffer only

# System dumps
adb shell dumpsys                               # All services
adb shell dumpsys activity                      # Activity manager
adb shell dumpsys activity activities           # Running activities
adb shell dumpsys activity top                  # Top activity
adb shell dumpsys meminfo <package>             # Memory info
adb shell dumpsys battery                       # Battery info
adb shell dumpsys window displays               # Display info
adb shell dumpsys connectivity                  # Network state
adb shell dumpsys alarm                         # Scheduled alarms
adb shell dumpsys jobscheduler                  # Job scheduler

# Bug report (comprehensive)
adb bugreport ./bugreport.zip

# Process info
adb shell ps -A | grep <package>
adb shell top -n 1                              # CPU usage snapshot
adb shell cat /proc/meminfo                     # System memory

# Database inspection
adb shell run-as <debug_package> cat databases/<db_name> > local.db

# SharedPreferences
adb shell run-as <debug_package> cat shared_prefs/<name>.xml

# Heap dump
adb shell am dumpheap <package> /sdcard/heap.hprof
adb pull /sdcard/heap.hprof .
```

## Network

```bash
# Port forwarding (host -> device)
adb forward tcp:<host_port> tcp:<device_port>
adb forward --list
adb forward --remove tcp:<host_port>
adb forward --remove-all

# Reverse port forwarding (device -> host) — useful for React Native / dev servers
adb reverse tcp:<device_port> tcp:<host_port>
adb reverse --list
adb reverse --remove tcp:<device_port>
adb reverse --remove-all

# Network info
adb shell ifconfig
adb shell ip addr show
adb shell netstat -tulnp
adb shell ping -c 4 google.com

# Wi-Fi
adb shell cmd wifi status
adb shell dumpsys wifi | grep "mNetworkInfo"
```

## Screen Capture

```bash
# Screenshot
adb shell screencap -p /sdcard/screen.png
adb pull /sdcard/screen.png .
# One-liner
adb exec-out screencap -p > screen.png

# Screen recording (max 3 minutes)
adb shell screenrecord /sdcard/demo.mp4
adb shell screenrecord --size 720x1280 /sdcard/demo.mp4
adb shell screenrecord --bit-rate 6000000 /sdcard/demo.mp4
adb shell screenrecord --time-limit 30 /sdcard/demo.mp4
# Stop with Ctrl+C, then:
adb pull /sdcard/demo.mp4 .
```

## Battery & Power

```bash
# Battery info
adb shell dumpsys battery

# Simulate battery states (for testing)
adb shell dumpsys battery set level 15      # Set level to 15%
adb shell dumpsys battery set status 1      # 1=unknown, 2=charging, 3=discharging, 4=not charging, 5=full
adb shell dumpsys battery set ac 0          # Unplug AC
adb shell dumpsys battery set usb 0         # Unplug USB
adb shell dumpsys battery reset             # Reset to actual values

# Doze mode testing
adb shell dumpsys deviceidle force-idle     # Force doze
adb shell dumpsys deviceidle unforce        # Exit doze
adb shell dumpsys deviceidle step           # Step through doze states

# App standby
adb shell am set-inactive <package> true
adb shell am get-inactive <package>
```

## Advanced

```bash
# Sideload OTA update
adb sideload <ota.zip>

# Backup & restore
adb backup -f backup.ab -apk -shared -all
adb restore backup.ab

# Intent extras
adb shell am start -n <pkg>/<activity> \
  --es "key" "string_value" \
  --ei "key" 42 \
  --ez "key" true \
  --eu "key" "content://uri"

# Content providers
adb shell content query --uri content://settings/system
adb shell content query --uri content://contacts/phones

# Monkey stress testing
adb shell monkey -p <package> --throttle 100 -v 5000

# Window manager
adb shell wm size                    # Get screen resolution
adb shell wm size 1080x1920         # Set screen resolution
adb shell wm density                 # Get density
adb shell wm density 420             # Set density
adb shell wm size reset
adb shell wm density reset

# Accessibility
adb shell settings put secure enabled_accessibility_services <pkg>/<service>

# SELinux
adb shell getenforce
```

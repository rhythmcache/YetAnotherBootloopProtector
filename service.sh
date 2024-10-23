#!/system/bin/sh
#AntiBootLoopScriptBy @e1phn

LOGFILE="/data/local/tmp/service.log"
MARKER_DIR="/data/local/tmp"
MAGISK_MODULES_DIR="/data/adb/modules"
BOOT_TIMEOUT=120

# logs
log_event() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# completed boot ?
is_boot_completed() {
    BOOT_COMPLETED=$(getprop sys.boot_completed)
    if [ "$BOOT_COMPLETED" = "1" ]; then
        return 0  # Boot completed
    else
        return 1  # Boot not completed
    fi
}

# Magisk modules
disable_magisk_modules() {
    log_event "Disabling all Magisk modules..."
    for MODULE in "$MAGISK_MODULES_DIR"/*; do
        if [ -d "$MODULE" ]; then
            touch "$MODULE/disable"
            chown 0:0 "$MODULE/disable"
            chmod 644 "$MODULE/disable"
            log_event "Disabled module: $MODULE"
        fi
    done
}

# markers ?
check_marker_files() {
    MARKER1="$MARKER_DIR/marker1"
    MARKER2="$MARKER_DIR/marker2"
    MARKER3="$MARKER_DIR/marker3"

    if [ -f "$MARKER3" ]; then
        log_event "Bootloop detected (3 markers found). Disabling Magisk modules and rebooting..."
        disable_magisk_modules
        rm -f "$MARKER1" "$MARKER2" "$MARKER3"
        log_event "Deleted all marker files. Rebooting..."
        reboot
    elif [ -f "$MARKER2" ]; then
        log_event "Second failed boot detected, creating marker3"
        touch "$MARKER3"
    elif [ -f "$MARKER1" ]; then
        log_event "First failed boot detected, creating marker2"
        touch "$MARKER2"
    else
        log_event "No markers found, creating marker1"
        touch "$MARKER1"
    fi
}

# Mlogic
log_event "Service started. Waiting for boot completion..."

# Create the first marker file if none exists
check_marker_files

# Wait for boot to complete
SECONDS_PASSED=0
while [ $SECONDS_PASSED -lt $BOOT_TIMEOUT ]; do
    if is_boot_completed; then
        log_event "Boot completed successfully. Cleaning up marker files."
        rm -f "$MARKER_DIR/marker1" "$MARKER_DIR/marker2" "$MARKER_DIR/marker3"
        exit 0
    fi
    sleep 5
    SECONDS_PASSED=$((SECONDS_PASSED + 5))
done

# If the boot is not completed within 2 minutes, disable Magisk modules and reboot
log_event "Boot did not complete within $BOOT_TIMEOUT seconds. Disabling Magisk modules and rebooting..."
disable_magisk_modules
rm -f "$MARKER_DIR/marker1" "$MARKER_DIR/marker2" "$MARKER_DIR/marker3"
log_event "Rebooting the device..."
reboot

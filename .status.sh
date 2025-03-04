#!/bin/sh
MODULE_DIR="/data/adb/modules/YetAnotherBootloopProtector"
YABP_DIR="/data/adb/YABP"
SYSTEMUI_MONITOR_DISABLE="/data/adb/systemui.monitor.disable"
MODULE_PROP="$MODULE_DIR/module.prop"
ALLOWED_MODULES_FILE="$YABP_DIR/allowed-modules.txt"

REQUIRED_FILES="\
    $MODULE_DIR/action.sh \
    $MODULE_DIR/service.sh \
    $MODULE_DIR/post-fs-data.sh \
    $MODULE_DIR/uninstall.sh"

# Ensure /data/adb/YABP directory exists
mkdir -p "$YABP_DIR"

# Check if allowed-modules.txt exists in YABP_DIR, copy from MODULE_DIR if available
if [ ! -f "$ALLOWED_MODULES_FILE" ]; then
    if [ -f "$MODULE_DIR/allowed-modules.txt" ]; then
        cp "$MODULE_DIR/allowed-modules.txt" "$ALLOWED_MODULES_FILE"
    else
        touch "$ALLOWED_MODULES_FILE"
    fi
fi

# Check if required module files exist, disable module if missing
for file in $REQUIRED_FILES; do
    if [ ! -f "$file" ]; then
        sed -i'' '/^description=/d' "$MODULE_PROP"
        echo "description= ⚠️ Warning : Module is corrupted. Please reinstall." >> "$MODULE_PROP"
        touch "$MODULE_DIR/disable"
        exit 0
    fi
done

# Update module description based on status
if [ -f "$MODULE_DIR/disable" ]; then
    sed -i'' '/^description=/d' "$MODULE_PROP"
    echo "description= SystemUI Monitor ❌ | Bootloop Monitor ❌ | ⚠️ Module is Disabled " >> "$MODULE_PROP"
elif [ -f "$SYSTEMUI_MONITOR_DISABLE" ]; then
    sed -i'' '/^description=/d' "$MODULE_PROP"
    echo "description= SystemUI Monitor ❌ | Bootloop Monitor ✅ | Module is Working ✨" >> "$MODULE_PROP"
else
    sed -i'' '/^description=/d' "$MODULE_PROP"
    echo "description= SystemUI Monitor ✅ | Bootloop Monitor ✅ | Module is Working ✨" >> "$MODULE_PROP"
fi
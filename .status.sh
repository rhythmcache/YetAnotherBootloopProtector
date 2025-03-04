#!/bin/sh
MODULE_DIR="/data/adb/modules/YetAnotherBootloopProtector"
YABP_DIR="/data/adb/YABP"
SYSTEMUI_MONITOR_DISABLE="/data/adb/systemui.monitor.disable"
MODULE_PROP="$MODULE_DIR/module.prop"

REQUIRED_FILES="\
    $MODULE_DIR/action.sh \
    $MODULE_DIR/service.sh \
    $MODULE_DIR/post-fs-data.sh \
    $MODULE_DIR/uninstall.sh"

    

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

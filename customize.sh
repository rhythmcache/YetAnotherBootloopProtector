ui_print "*******************************"
ui_print " Yet Another Bootloop Protector"
ui_print "*******************************"
ui_print " => Choose SystemUI Monitor"
ui_print "Press VOLUME UP to enable :"
ui_print "Press VOLUME DOWN to disable :"
ui_print "Waiting for your choice..."
while true; do
    event=$(getevent -qlc 1 2>/dev/null)
    if echo "$event" | grep -q "KEY_VOLUMEUP"; then
        ui_print "SystemUI Monitor enabled."
        if [ -f /data/adb/systemui.monitor.disable ]; then
            rm -f /data/adb/systemui.monitor.disable
        fi
        break
    fi
    if echo "$event" | grep -q "KEY_VOLUMEDOWN"; then
        ui_print " => SystemUI Monitor disabled."
        touch /data/adb/systemui.monitor.disable
        break
    fi
done
set_perm_recursive $MODPATH 0 0 0755 0644
ui_print " "
ui_print "- Installation complete!"

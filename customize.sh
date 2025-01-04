ui_print "*******************************"
ui_print " Yet Another Bootloop Protector"
ui_print "*******************************"
ui_print " => Choose SystemUI Monitor"
ui_print "Press VOLUME UP to enable :"
ui_print "Press VOLUME DOWN to disable :"
getevent -qlc 1 | while read line; do
    if echo "$line" | grep -q "KEY_VOLUMEUP"; then
        ui_print "SystemUI Monitor enabled."
        if [ -f /data/adb/systemui.monitor.disable ]; then
            rm -f /data/adb/systemui.monitor.disable
        fi
        break
    elif echo "$line" | grep -q "KEY_VOLUMEDOWN"; then
        ui_print " => SystemUI Monitor disabled."
        touch /data/adb/systemui.monitor.disable
        break
    fi
done
set_perm_recursive $MODPATH 0 0 0755 0644
ui_print " "
ui_print "- Installation complete!"


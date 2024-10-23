#!/system/bin/sh
ui_print "*******************************"
ui_print "     BootLoop Rescue          "
ui_print "*******************************"
ui_print " "
cp $MODPATH/service.sh $MODPATH/service.sh
cp $MODPATH/module.prop $MODPATH/module.prop
ui_print " "
ui_print "- Installation complete!"
set_perm_recursive $MODPATH 0 0 0755 0644
rm $MODPATH/customize.sh
exit 0

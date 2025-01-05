DIR="${0%/*}"
if [ -f "$DIR/s1" ] && [ -f "$DIR/s2" ] && [ -f "$DIR/s3" ]; then
    rm -f "$DIR/s1" "$DIR/s2" "$DIR/s3"
    for module_dir in /data/adb/modules/*/; do
        touch "$module_dir/disable"
    done
    reboot
elif [ -f "$DIR/s2" ]; then
    touch "$DIR/s3"
elif [ -f "$DIR/s1" ]; then
    touch "$DIR/s2"
else
    touch "$DIR/s1"
fi

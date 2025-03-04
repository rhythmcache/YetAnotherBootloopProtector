#!/bin/sh
DIR="${0%/*}"
file=/data/adb/YABP/allowed-modules.txt
file2=/data/adb/YABP/allowed-scripts.txt
allowed_modules=""
if [ -f "$file" ]; then
	while IFS= read -r line; do
		case "$line" in
		\#* | "") continue ;; # Ignore lines starting with # and empty lines
		*) allowed_modules="$allowed_modules $line" ;;
		esac
	done <"$file"
fi
allowed_scripts=""
if [ -f "$file2" ]; then
	while IFS= read -r line; do
		case "$line" in
		\#* | "") continue ;;
		*) allowed_scripts="$allowed_scripts $line" ;;
		esac
	done <"$file2"
fi
permissions() {
	for dir in /data/adb/post-fs-data.d /data/adb/service.d /data/adb/post-mount.d /data/adb/boot-completed.d; do
		if [ -d "$dir" ]; then
			for script in "$dir"/*; do
				script_name=$(basename "$script")
				case "$script_name" in
				".status.sh") continue ;;
				*)
					case " $allowed_scripts " in
					*" $script_name "*) continue ;;
					*) chmod 644 "$script" ;;
					esac
					;;
				esac
			done
		fi
	done
}
if [ -f "$DIR/s1" ] && [ -f "$DIR/s2" ] && [ -f "$DIR/s3" ]; then
	rm -f "$DIR/s1" "$DIR/s2" "$DIR/s3"
	for module_dir in /data/adb/modules/*/; do
		module_name=$(basename "$module_dir")
		case " $allowed_modules " in
		*" $module_name "*) continue ;;
		*) [ -d "$module_dir" ] && touch "$module_dir/disable" ;;
		esac
	done
	permissions
	reboot
elif [ -f "$DIR/s2" ]; then
	touch "$DIR/s3"
elif [ -f "$DIR/s1" ]; then
	touch "$DIR/s2"
else
	touch "$DIR/s1"
fi

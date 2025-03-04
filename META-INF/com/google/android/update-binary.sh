#!/sbin/sh

#################
# Initialization
#################

#rhythmcache.t.me
#github.com/rhythmcache

umask 022

#########
OUTFD=$2
ZIPFILE=$3
MOUNT_POINT="/data/local/mount_modules"
file=/data/adb/YABP/allowed-modules.txt
file2=/data/adb/YABP/allowed-scripts.txt

ui_print() {
  if [ "$BOOTMODE" != "true" ]; then
    if [ -n "$OUTFD" ] && [ -e "/proc/self/fd/$OUTFD" ]; then
      echo "ui_print $*" >> "/proc/self/fd/$OUTFD"
      echo "ui_print" >> "/proc/self/fd/$OUTFD"
    else
      echo "Error: OUTFD not set or invalid, cannot print to recovery."
    fi
  else
    echo "$*"
  fi
}

# change permission of scripts 
change_permissions() {
  DIRS="/data/adb/service.d /data/adb/post-fs-data.d /data/adb/post-mount.d /data/adb/boot-completed.d"

  # Read allowed scripts from $file2
  allowed_scripts=""
  if [ -f "$file2" ]; then
    while IFS= read -r line; do
      if [ "${line#\#}" != "$line" ] || [ -z "$line" ]; then
        continue  # Ignore comments and empty lines
      else
        allowed_scripts="$allowed_scripts $line"
      fi
    done < "$file2"
  fi

  for DIR in $DIRS; do
    if [ -d "$DIR" ]; then
      # Use find to locate all files in the directory (not just .sh files)
      find "$DIR" -type f | while read -r SCRIPT; do
        SCRIPT_NAME=$(basename "$SCRIPT")

        # Skip .status.sh
        if [ "$SCRIPT_NAME" = ".status.sh" ]; then
          continue
        fi

        skip=false
        for allowed_script in $allowed_scripts; do
          if [ "$SCRIPT_NAME" = "$allowed_script" ]; then
            skip=true
            break
          fi
        done

        if $skip; then
          continue
        fi

        # Change permissions for non-allowed files
        chmod 644 "$SCRIPT"
      done
    fi
  done
}


check_encryption() {
  if [ ! -d "/data/adb" ]; then
    ui_print "Error: Can't Access /data/adb, Data is encrypted?"
    exit 1
  fi
}

# Disable Modules

create_disable_files() {
  local base_dir="$1"

  # Read allowed modules from $file
  allowed_modules=""
  if [ -f "$file" ]; then
    while IFS= read -r line; do
      if [ "${line#\#}" != "$line" ] || [ -z "$line" ]; then
        continue  # Ignore comments and empty lines
      else
        allowed_modules="$allowed_modules $line"
      fi
    done < "$file"
  fi

  for module_dir in "$base_dir"/*; do
    if [ -d "$module_dir" ] && [ "$(basename "$module_dir")" != "lost+found" ]; then
      local module_name
      module_name=$(basename "$module_dir")

      # Skip disabling if the module is in the allowlist
      if [ -n "$(echo " $allowed_modules " | grep " $module_name ")" ]; then
        continue
      else
        ui_print "- Disabling: $module_name"
        touch "$module_dir/disable" || exit 1
        chown 0:0 "$module_dir/disable"
        chmod 644 "$module_dir/disable"
      fi
    fi
  done
}


# Mount modules.img

process_modules_img() {
  local img_path="$1"
  mkdir -p "$MOUNT_POINT"
  ui_print "- Mounting modules.img"
  mount -t ext4 -o loop "$img_path" "$MOUNT_POINT"
  if [ $? -eq 0 ]; then
    ui_print "- Successfully mounted modules.img"
    create_disable_files "$MOUNT_POINT"
    ui_print "- Unmounting modules.img"
    umount "$MOUNT_POINT"
    rm -rf "$MOUNT_POINT"
    return 0
  else
    # Try mounting without explicit options as fallback
    ui_print "- Retrying mount without explicit options"
    mount "$img_path" "$MOUNT_POINT"
    if [ $? -eq 0 ]; then
      ui_print "- Successfully mounted modules.img (fallback method)"
      create_disable_files "$MOUNT_POINT"
      ui_print "- Unmounting modules.img"
      umount "$MOUNT_POINT"
      rm -rf "$MOUNT_POINT"
      return 0
    fi
    ui_print "! Failed to mount modules.img"
    rm -rf "$MOUNT_POINT"
    return 1
  fi
}

# multiple modules
process_all_modules() {
  local found_modules=false

  # Check KernelSU modules.img
  if [ -f "/data/adb/ksu/modules.img" ]; then
    ui_print "- Found KernelSU modules.img"
    process_modules_img "/data/adb/ksu/modules.img"
    found_modules=true
  fi

  # Check APatch modules.img
  if [ -f "/data/adb/ap/modules.img" ]; then
    ui_print "- Found APatch modules.img"
    process_modules_img "/data/adb/ap/modules.img"
    found_modules=true
  fi

#MagiskModules
  if [ -d "/data/adb/modules" ] && find "/data/adb/modules" -mindepth 1 -maxdepth 1 -type d | grep -q .; then
    ui_print "- Found Magisk modules"
    create_disable_files "/data/adb/modules"
    found_modules=true
fi

  if ! $found_modules; then
    ui_print "! No modules found in any location"
    return 1
  fi

  return 0
}

# if Recovery detected
recovery_install() {
  ui_print "- Running in Recovery environment"
  check_encryption
  ui_print "- Data partition is decrypted, proceeding..."
  change_permissions
  process_all_modules
  exit $?
}

#################
# Main
#################
mount /data 2>/dev/null

# Check environment 
if [ "$BOOTMODE" = "true" ]; then
    ui_print " => Running in Magisk"
    [ -f /data/adb/magisk/util_functions.sh ] || require_new_magisk
    . /data/adb/magisk/util_functions.sh
    [ "$MAGISK_VER_CODE" -lt 20400 ] && require_new_magisk
    install_module
else
    ui_print "[*] Recovery environment detected"
    recovery_install
fi
exit 0

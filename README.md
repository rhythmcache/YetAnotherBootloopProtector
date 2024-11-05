## Logic

• Each time the device fails to complete the boot, the script creates a "marker" file in a specific folder (/data/local/tmp).
## If the script finds:
- No marker files: it creates the first marker (marker1).
- One marker file: it creates a second marker (marker2).
- Two marker files: it creates a third marker (marker3).
- When three markers are present, the script considers the device to be in a boot loop.

## Checking Boot Completion:

The script checks whether the system has fully booted by looking at the sys.boot_completed property.

When three markers are present, the script disables all Magisk modules by creating a disable file in each module's folder. This action prevents those modules from loading during the next boot, which may help the device boot correctly.
After disabling the modules, the script deletes all marker files and reboots the device.

The script waits for the boot to complete, checking every 5 seconds.
If the boot does not complete within a set timeout period (2 minutes by default), the script assumes there is a boot problem, disables all Magisk modules, and reboots the device to attempt a clean boot.

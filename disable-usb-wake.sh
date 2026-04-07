#!/bin/bash
# Check status of XHCI and TXHC. If enabled, toggle to disabled.
# We use a loop to ensure they stay disabled if the BIOS tries to flip them.

for device in XHCI TXHC; do
    if grep -q "$device.*enabled" /proc/acpi/wakeup; then
        echo "$device" > /proc/acpi/wakeup
    fi
done

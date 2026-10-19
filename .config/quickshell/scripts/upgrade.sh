#!/bin/bash
# Run from the updates button in its own ghostty: system packages, then flatpaks
# (flatpak update also pulls the NVIDIA GL runtime matching the loaded driver)
sudo dnf upgrade --refresh
echo
flatpak update
echo

# The NVIDIA module is compiled by akmods, which can still be busy in the background after dnf
# finishes; rebooting into a kernel without it means no graphics. Build it for the newest kernel
# now (no-op if it already exists) and check it matches the installed driver before rebooting.
kernel=$(rpm -q kernel-core --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' | sort -V | tail -1)
driver=$(rpm -q --qf '%{VERSION}' xorg-x11-drv-nvidia)
sudo akmods --kernels "$kernel" >/dev/null
module=$(modinfo -k "$kernel" -F version nvidia 2>/dev/null)

if [[ $module != "$driver" ]]; then
    echo "✗ NVIDIA driver $driver is NOT built for kernel $kernel (found: ${module:-nothing})."
    echo "  Don't reboot yet: retry with 'sudo akmods --force --kernels $kernel',"
    echo "  or pick the previous kernel in rEFInd if you already rebooted."
elif [[ $kernel != "$(uname -r)" || $driver != "$(cat /sys/module/nvidia/version 2>/dev/null)" ]]; then
    echo "✓ NVIDIA driver $driver ready for kernel $kernel. Reboot to use the update."
else
    echo "✓ NVIDIA driver $driver matches the running kernel. No reboot needed for it."
fi
echo
read -n 1 -s -r -p "Done. Press any key to close."

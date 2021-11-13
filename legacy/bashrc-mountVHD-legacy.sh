# The following section mounts additional Virtual Hard Disk (VHD) files into ALL WSL distributions.
# These files can be located on different physical Drives, for example.
# NOTE: Before running this, run 'lsblk' to see which Block Devices are already registered in Linux. 
#       mounted VHDs should(?) be added as the same block device every time. 
# Mounting is done on the Windows side with this method using a Powershell script 'WSL_mount-VHDs.ps1'.
# Ensure that it is included in Windows PATH variable, Powershell script execution is enabled in Windows, 
# and HyperV powershell cmdlets are installed. (see Windows Features, not available on Windows 10 HOME Edition)
declare -A VHD_blkDevs
# --- Declare the block devices and their name here. Name can be anything.
# For example if you already have /dev/sda and /dev/sdb, the next devices should be as follows:
VHD_blkDevs["/dev/sdc"]="VHD_T"
VHD_blkDevs["/dev/sdd"]="VHD_C"
for dev in "${!VHD_blkDevs[@]}"; do
    if [[ ! -e $dev ]]; then
        powershell.exe WSL_mount-VHDs.ps1
        # now all VHDs should be mounted. Check if they are:
        for dev in "${!VHD_blkDevs[@]}"; do
            if [[ ! -e $dev ]]; then
                 echo Unable to mount ${VHD_blkDevs[${dev}]}: to WSL. "$dev" will not be available.
            else echo successfully mounted VHD ${VHD_blkDevs[${dev}]} as "$dev"; fi
        done
        break
    fi
done

# The following section mounts additional Virtual Hard Disk (VHD) files into ALL WSL distributions.
# These files can be located on different physical Drives, for example.
declare -A VHD_mounts
# --- Declare the Name of VHDs and their windows paths here. Name can be anything.
VHD_mounts["BulkStorage"]="T:\WSL_BulkStorage.vhdx"
VHD_mounts["FastStorage"]="C:\WSL_FastStorage.vhdx"

for dev in "${!VHD_mounts[@]}"; do
	tput setaf 6; echo "attempting to mount $dev - ${VHD_mounts[${dev}]}"
	wsl.exe --mount --vhd --name "$dev" "${VHD_mounts[${dev}]}"
done
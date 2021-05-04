# make Windows CMD usable without .exe extension within WSL. 
alias cmd='cmd.exe'

# make Windows CMD's /C option usable from any Directory without it complaining about
# not supporting UNC-paths. Not suitable for all Commands because of this missing support.
alias ccmd='f(){ cwd=$(pwd); cd /mnt/c; cmd.exe /c "$@"; cd $cwd; unset -f f; }; f'

# outputs a String that can be used in other Shellscripts. Does NOT add a Newline after it.
alias echo%='f(){ ccmd \<NUL set /p="$@"; unset -f f; }; f'

# evaluates a Windows style path "the CMD way" and then converts it into a Linux path.
alias path%='f(){ wslpath -a $(echo% "$@"); unset -f f; }; f'

# changes directory to a path parsed by the path% command above.
# Example: 'cd% %appdata%' will go to Windows user's appdata folder.
alias cd%='f(){ cd $(path% "$@"); unset -f f; }; f'

# makes the current Windows user's home directory available as an environment variable.
export WinHOME="$(path% %userprofile%)"

# allows quickly navigating to the Windows user's home directory.
alias home='cd% %userprofile%'

# opens Windows Explorer in the current directory.
alias explorer='explorer.exe .'

# shuts down the current WSL distribution.
alias shutdown='wsl.exe --terminate $WSL_DISTRO_NAME'
# shuts down ALL WSL distributions AND the WSL engine.
alias shutdown-all='wsl.exe --shutdown'

# The following commands all REBOOT the WSL machine from within. For explanation of ONE of them, see: 
# https://stackoverflow.com/questions/66375364/shutdown-or-reboot-a-wsl-session-from-inside-the-wsl-session/67090137#67090137
# Variant 1: reboot the current WSL distribution AND launch a new Window of it that starts out at C:\
alias reboot='cd /mnt/c/ && cmd.exe /c start "rebooting WSL" cmd /c "timeout 6 && wsl -d $WSL_DISTRO_NAME" && wsl.exe --terminate $WSL_DISTRO_NAME'
# Variant 2: reboot the current WSL distribution, but close the new session's terminal. Useful for users of the new 'Windows Terminal', or similar apps which are not set up as the default terminal to start in this case. 
alias reboot='cd /mnt/c/ && cmd.exe /c start /min "rebooting WSL" cmd /c "timeout 3 && wsl -d $WSL_DISTRO_NAME -e exit" && wsl.exe --terminate $WSL_DISTRO_NAME'
# Variant 3: reboots ALL WSL distributions AND the WSL engine.
alias reboot-all='cd /mnt/c/ && cmd.exe /c start /min "rebooting WSL" cmd /c "timeout 3 && wsl -d $WSL_DISTRO_NAME -e exit" && wsl.exe --shutdown'

# A typical alias for ls
alias lsa='ls -la'

# runs gedit as separate process and ignore any console output (such as warnings)
alias gedit='f(){ gedit "$@" &>/dev/null & unset -f f; }; f'

# runs the 3rd party Git GUI 'GitExtensions' on the windows side, in the current directory.
# GitExtensions needs to be included in the Windows %PATH% variable. 
gitex(){
    if [[ $# -eq 0 || $* == . ]]; then
         GitExtensions.exe browse . &
    else GitExtensions.exe $@; fi
}

# setup connections to Host machine for XServer and PulseAudio. 
export HOST_IP="$(ip route |awk '/^default/{print $3}')"
export DISPLAY="$HOST_IP:0.0"
export PULSE_SERVER="tcp:$HOST_IP"

# Automatically start dbus for GUI windows
sudo /etc/init.d/dbus start &> /dev/null

# enable OpenGL graphics to work properly with remote Xserver
export LIBGL_ALWAYS_INDIRECT=0

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



VHD_blkDev_T=/dev/sdc
VHD_blkDev_C=/dev/sdd
if [[ ! -e $VHD_blkDev_T || ! -e $VHD_blkDev_C ]]; then
    powershell.exe WSL_mount-VHDs.ps1
    if [ ! -e $VHD_blkDev_T ]; then
         echo Unable to mount VHD at T: to WSL. $VHD_blkDev_T will not be available.
    else echo successfully mounted VHD as $VHD_blkDev_T; fi
    if [ ! -e $VHD_blkDev_C ]; then
         echo Unable to mount VHD at C: to WSL. $VHD_blkDev_C will not be available.
    else echo successfully mounted VHD as $VHD_blkDev_C; fi
fi
# For some command explanations, see: 
# https://stackoverflow.com/questions/66375364/shutdown-or-reboot-a-wsl-session-from-inside-the-wsl-session/67090137#67090137

# shuts down the current WSL distribution.
alias shutdown='wsl.exe --terminate $WSL_DISTRO_NAME'
# shuts down ALL WSL distributions AND the WSL engine.
alias shutdown-all='wsl.exe --shutdown'

# The following commands all REBOOT the WSL machine from within. 

# Variant 1: reboot the current WSL distribution, launch a new Window of it that starts out at C:\
alias reboot='cd /mnt/c/ && cmd.exe /c start "rebooting WSL" cmd /c "timeout 3 && wsl -d $WSL_DISTRO_NAME" && wsl.exe --terminate $WSL_DISTRO_NAME'
# Variant 2: reboot the current WSL distribution, but close the new session's terminal. The Distro will be ready to work when you open a new terminal.
alias reboot='cd /mnt/c/ && cmd.exe /c start /min "rebooting WSL" cmd /c "timeout 3 && wsl -d $WSL_DISTRO_NAME -e exit" && wsl.exe --terminate $WSL_DISTRO_NAME'
# Variant 3: reboot the CURRENT WSL distribution, SHUT DOWN all other Distributions AND the WSL engine, launch a new Window that starts out at C:\ 
alias reboot-all='cd /mnt/c/ && cmd.exe /c start /min "rebooting WSL" cmd /c "timeout 3 && wsl -d $WSL_DISTRO_NAME" && wsl.exe --shutdown'
# Variant 4: reboot the CURRENT WSL distribution, but close the new session's terminal, SHUT DOWN all other Distributions AND the WSL engine.
alias reboot-all='cd /mnt/c/ && cmd.exe /c start /min "rebooting WSL" cmd /c "timeout 3 && wsl -d $WSL_DISTRO_NAME -e exit" && wsl.exe --shutdown'

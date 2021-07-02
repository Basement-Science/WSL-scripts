# make Windows CMD usable without .exe extension within WSL. 
alias cmd='cmd.exe'

# make Windows CMD's /C option usable from any Directory without it complaining about
# not supporting UNC-paths. Not suitable for all Commands because of this missing support.
alias ccmd='f(){ cwd=$(pwd); cd /mnt/c; cmd.exe /c "$@"; cd "$cwd"; unset -f f; }; f'

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

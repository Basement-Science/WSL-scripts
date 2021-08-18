# opens Windows Explorer in the current directory.
alias explorer='explorer.exe .'

# A typical alias for ls
alias lsa='ls -la'

# command to reload the .bashrc file from any directory
alias reload-bashrc='source $HOME/.bashrc; echo "$HOME/.bashrc reloaded!"'

# runs gedit as separate process and ignores any console output (such as warnings)
alias gedit='f(){ gedit "$@" &>/dev/null & unset -f f; }; f'

# runs the 3rd party Git GUI 'GitExtensions' on the windows side, in the current directory.
# GitExtensions needs to be included in the Windows %PATH% variable. 
gitex(){
    if [[ $# -eq 0 || $* == . ]]; then
         GitExtensions.exe browse . &
    else GitExtensions.exe $@; fi
}

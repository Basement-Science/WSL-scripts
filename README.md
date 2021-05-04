# WSL-scripts
A collection of Windows and Linux Script files and snippets to make the Windows Subsystem for Linux (WSL) easier to use and more capable.
---
*Before using anything in this repository, make sure to at least read the relevant chapter in this readme first!*

What can these do?
- make `cmd` and its integrated tools more usable, including parsing `%WindowsVariables%`
- mount additional `Virtual Hard Disks` (VHDs) in WSL (automatically if you want)
- add `shutdown` and `reboot` commands that can be used from inside WSL
- includes necessary Linux-side configuration for using GUI applications
- And a bunch more. Additional tools will be added here in the future.

## CMD improvements
`cmd.exe` is an ancient tool with many problems. Still it often provides simple solutions that are not otherwise easily available. 
For example, `cmd` is able to start additional windows, such as terminals, easily, and perhaps most importantly, it is able to access Windows environment variables using the `%variable%` syntax. This is a prerequisite for certain other tasks one may want to do in a WSL system.

### To add the improvements, open your ~/.bashrc file in a text editor and add the lines that define the following commands:
| Line           | Description                                                      |
| -----------    | ---------------------------------------------------------------- |
| `alias cmd`    | makes it possible to call cmd without the .exe extension in WSL. *Optional.* |
| `alias ccmd`   | Executes whatever comes next as a cmd command.<br>**Example:** `ccmd start cmd &` --> opens a separate cmd window.<br>***Caveats:***<br><ul><li>*this will change directory to `C:\Windows` during execution<br>because cmd does not support UNC-Paths such as those used by WSL.*</li><li>*some characters may need to be escaped using `\`, such as `>`*</li></ul>  |
| `echo%`        | Outputs a string as parsed by cmd. Useful for debugging or passing it to other commands. Does not output a newline.<br>**Example:** `echo% %appdata%` --> E:\Users\USERNAME\AppData\Roaming            |
| `path%`        | Outputs a Linux-formatted path parsed from `echo%`. Does not output a newline.<br>**Example:** `path% %appdata%` --> /mnt/e/Users/USERNAME/AppData/Roaming |
| `cd  %`        | changes directory to a path as parsed by `path%`.<br>**Example:** `cd% %appdata%` |
<br>

### More *optional* Additions that depend on these:
| Line             | Description                                                      |
| -----------      | ---------------------------------------------------------------- |
| `export WinHOME` | makes the current Windows user's home directory available as an environment variable in Linux. |
| `alias home`     | changes directory to the Windows user's home directory.          |
| `alias explorer` | opens Windows Explorer in the current directory.                 |


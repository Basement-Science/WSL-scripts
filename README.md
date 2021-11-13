# WSL-scripts
### A collection of Windows and Linux Script files and snippets to make the Windows Subsystem for Linux (WSL) easier to use and more capable.
***
*Before using anything in this repository, make sure to at least read the relevant chapter in this readme first!*

What can these do?
- make `cmd` and its integrated tools more usable, including parsing `%WindowsVariables%`
- add `shutdown` and `reboot` commands that can be used from inside WSL
- mount additional `Virtual Hard Disks` (VHDs) in WSL (automatically if you want)
- includes necessary Linux-side configuration for using GUI applications
- And a bunch more. Additional tools will be added here in the future.

<br>

# CMD improvements
`cmd.exe` is an ancient tool with many problems. Still it often provides simple solutions that are not otherwise easily available. 
For example, `cmd` is able to start additional windows, such as terminals, easily, and perhaps most importantly, it is able to access Windows environment variables using the `%variable%` syntax. This is a prerequisite for certain other tasks one may want to do in a WSL system.

### To add the improvements, open your ~/.bashrc file in a text editor and add the lines from `bashrc-cmd.sh` that define the following commands:
| Line           | Description                                                      |
| -----------    | ---------------------------------------------------------------- |
| `alias cmd`    | makes it possible to call cmd without the .exe extension in WSL. *Optional.* |
| `alias ccmd`   | Executes whatever comes next as a cmd command.<br>**Example:** `ccmd start cmd &` --> opens a separate cmd window.<br>***Caveats:***<br><ul style="padding-left:1.2em"><li>*this will change directory to `C:\Windows` during execution<br>because cmd does not support UNC-Paths such as those used by WSL.*</li><li>*some characters may need to be escaped using `\`, such as `>`*</li></ul>  |
| `echo%`        | Outputs a string as parsed by cmd. Useful for debugging or passing it to other commands. Does not output a newline.<br>**Example:** `echo% %appdata%` --> E:\Users\USERNAME\AppData\Roaming            |
| `path%`        | Outputs a Linux-formatted path parsed from `echo%`. Does not output a newline.<br>**Example:** `path% %appdata%` --> /mnt/e/Users/USERNAME/AppData/Roaming |
| `cd%`          | changes directory to a path as parsed by `path%`.<br>**Example:** `cd% %appdata%` |
<br>

## More ***optional*** Additions that depend on the above:
| Line             | Description                                                      |
| -----------      | ---------------------------------------------------------------- |
| `export WinHOME` | makes the current Windows user's home directory available as an environment variable in Linux. |
| `alias home`     | changes directory to the Windows user's home directory.          |
<br><br>

# Shutdown and Reboot commands
*For more details about this, also see [this Stackoverflow post](https://stackoverflow.com/questions/66375364/shutdown-or-reboot-a-wsl-session-from-inside-the-wsl-session/67090137#67090137)*

By default there is no way to shutdown or reboot a WSL machine from within itself with a simple command. The existing commands called `shutdown` and `reboot` are not usable. 

Shutting down is relatively straightforward, however one has to decide whether to shutdown only the current WSL distribution, or ALL systems running on WSL including the Backend. This is necessary for example when updating the Linux Kernel.

Rebooting is more complex, and so far I am not aware of a way to do this while preserving the existing terminal window.<br>Therefore there are more Variants of it available. ***You must choose which variant you want to use. DO NOT add multiple definitions of the same command!***

To add working commands for `shutdown` and `reboot`, open your `~/.bashrc` file in a text editor and add **those lines you want to use** from `bashrc-shutdownReboot.sh`. You can also add all lines and ***comment out using `#`*** those lines you do not want to use.
| Line                 | Description                                                                          |
| -----------          | ------------------------------------------------------------------------------------ |
| `alias shutdown`     | shuts down the current distribution only.                                            |
| `alias shutdown-all` | shuts ALL distributions AND the WSL engine.                                          |
| `alias reboot`       | <ul style="padding-left:1.2em"><li>**Variant 1:** reboot the current WSL distribution, launch a new Window of it that starts out at C:\ </li><li>**Variant 2:** reboot the current WSL distribution, but close the new session's terminal.<br>The Distro will be ready to work when you open a new terminal.</li></ul> |
| `alias reboot`       | <ul style="padding-left:1.2em"><li>**Variant 3:** reboot the CURRENT WSL distribution, SHUT DOWN all other Distributions AND the WSL engine, launch a new Window that starts out at C:\ </li><li>**Variant 4:** reboot the CURRENT WSL distribution, but close the new session's terminal, SHUT DOWN all other Distributions AND the WSL engine.</li></ul> |
<br>

# Mount VHD files in WSL
### <span style="color:Yellow">***Note:*** This Feature is new and only available in the latest versions of WSL. So far WSL versions have been tied to your installed Build of Windows. You can check your Windows Build by running `Winver`. For Windows versions prior to build **20211**, it is not possible to mount Virtual Hard Drives. For versions from build **20211** to below **22000**, you can only use the method found in the `legacy` folder. _This_ section will describe the newest and simplest method of mounting VHDs. If you obtained WSL from the Windows Store, which is currently in preview, you should also be able to use this new method.</span>
WSL systems are stored as single `VHDX` virtual disk images. However sometimes it is preferrable to split a VM's storage into several files, for example to make use of fast SSDs and large HDDs. This can be accomplished using the new `WSL --mount --vhd` option. 
## How to add a VHD to WSL
### Creating a new VHD file:
1. On Windows, open Diskmgmt.msc (Disk Management)
2. Go to Actions -> Create VHD
3. Enter a location, size, and type and click OK. <br>*(Note: if you specify the size as a non-integer number, you must use "," or "." according to your Windows Culture. 'Incorrect' characters will be ignored. For english, use ".")*
4. It should show up in Disk Manager. Do **NOT** initialize or partition the VHD in Windows.
---
### Mounting the VHD
When first mounting a VHD, `wsl` may throw a `code 22` at you if the VHD is not formatted in ext4 yet. This is fine. See the section below.

You can mount VHDs **manually and temporarily.** In any terminal, run:
```
wsl.exe --mount --vhd "C:\path\to\VHD File.vhdx"
```
Or you can add a few lines to your `.bashrc` file to automate mounting and make it **permanent.** The file `bashrc-mountVHD.sh` contains a convenient way to do this. Simply add those lines to your .bashrc file and change the Name in [Brackets] and the Windows Path of the VHD file.

---
### Formatting the VHD
1. open up WSL and run `lsblk` or `df -h` 
2. If you've mounted the VHD, you should see a new block device, for example `/dev/sdc` that wasn't there before.<br>
If you are not sure, `df -h` has more information that should make it easier to tell.<br>
You can also unmount the VHD again: `wsl --unmount` to unmount all ***added*** VHDs or Physical Drives.
3. Now you can format the VHD in linux, for example using `mkfs.ext4 /dev/sdc`, then mount it again and start using it.
---
### You can add or remove VHDs at any time later. Simply edit the `~/.bashrc` file as before and reboot WSL or run `source ~/.bashrc`. However note that the scripts do not unmount anything, you may need to do that manually.
<br>

# Linux-side configuration for using GUI applications
*This section is not a tutorial. It only includes the necessary additions to the `~/.bashrc` file.*
- Open your `~/.bashrc`file in a text editor and add the contents of `bashrc-GUI.sh`
<br><br>

# Independent .bashrc additions
The lines from `bashrc-misc.sh` can be added optionally to your `~/.bashrc` file with a text editor. Each line is independent of the rest.
| Line             | Description                                                                          |
| -----------      | ------------------------------------------------------------------------------------ |
| `alias explorer` | opens Windows Explorer in the current directory.                                     |
| `alias lsa`      | A typical alias for the ls command. Everyone has their favorite format of ls, right? |
| `alias reload-bashrc`      | command to reload the `.bashrc` file from any directory |
| `alias gedit`    | runs gedit as separate process and ignores any console output (such as warnings)     |
| `gitex()`        | runs the 3rd party Git GUI 'GitExtensions' on the windows side.<br>*Note: this is a function. It is intended more as an example addition.* |
<br>

# Contributions
If you have created other ***general-purpose*** scripts or tools **specific to WSL** that you think would fit into this collection, feel free to start a pull request.<br>
Any other improvements are of course also welcome as long as they work.
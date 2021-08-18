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
<br><br>

# Mount VHD files in WSL
### <span style="color:Yellow">***Note:*** This section uses Features that are currently only available in Windows Insider preview builds. This will NOT work in builds before **20211**. You can check your Windows Build by running `Winver`.</span>
WSL systems are stored as single `VHDX` virtual disk images. However sometimes it is preferrable to split a VM's storage into several files, for example to make use of fast SSDs and large HDDs. One way to accomplish this is by using the brand-new `WSL --mount` option. However this option is really just intended to mount entire physical drives temporarily, not to mount virtual disks permanently. Using additional Windows Features however, the latter is also possible. 
## How to add a VHD to WSL
1. On Windows, open Diskmgmt.msc (Disk Management)
2. Go to Actions -> Create VHD
3. Enter a location, size, and type and click OK. <br>*(Note: if you specify the size as a non-integer number, you must use "," or "." according to your Windows Culture. 'Incorrect' characters will be ignored. For english, use ".")*
4. It should show up in Disk Manager. Do **NOT** initialize or partition the VHD in Windows.
5. Mount the VDisk(s). You can do it manually ***(temporary only)***, or with the Powershell script `WSL_mount-VHDs.ps1`
    - **manually and temporary:** 
        1. Find out the Physical Disk Number.
            1. In Disk Manager: The number on the left.

            ![Diskmgmt-LeftSide](/auxFiles/Diskmgmt-DiskNr.PNG "Diskmgmt-LeftSide")

            2. In Powershell: Run `$((Get-VHD C:\path\to\VHD.vhdx | Get-Disk).Number)`
        2. Run `wsl --mount \\.\PhysicalDrive9` and replace `9` with the number you got above.
    - **automated and temporary**
        1. run `powershell WSL_mount-VHDs.ps1 "C:\path\to\VHD.vhdx"`
    - **automated and permanent**
        1. copy `WSL_mount-VHDs.ps1` to a location that is included in the Windows PATH variable.
        2. Open `WSL_mount-VHDs.ps1` in a Text Editor
        3. Scroll down to Line 37 where it says `<--- ADD YOUR VHD FILE PATHS TO BE MOUNTED HERE --->`
        4. In the line below, add the file location of each VHD you want to add between the brackets.<br>
        Each path must be surrounded by `""` and paths have to be separated by a "`,`"
6. In all these cases, `wsl` should throw a `code 22` at you because the VHD is not formatted in ext4 yet. This is fine.
7. open up WSL and run `lsblk` or `df -h` 
8. You should see a new block device, for example `/dev/sdc` that wasn't there before.<br>
If you are not sure, `df -h` has more information that should make it easier to tell.<br>
You can also unmount the VHD again: `wsl --unmount \\.\PhysicalDrive9` and replace `9` with the Disk number.
9. Now you can format the VHD in linux, for example using `mkfs.ext4 /dev/sdc`, then mount it and start using it.
---
10. ***To finally make it permanently available, after reboots of WSL and Windows itself, continue with the next steps.***
11. If you did not mount the VHD like in the **automated and permanent** section, you can do those steps now. 
12. In WSL, open your ~/.bashrc file in a text editor and add the lines from `bashrc-mountVHD.sh`.
13. Edit the lines that look like `VHD_blkDevs["/dev/sdc"]="VHD_T"`
    - For each VHD you want to mount, you need **ONE(!)** such line in this position.<br>To mount only one VHD, delete the second such line.
    - Replace `"/dev/sdc"` with the correct block device you identified in step `7/8`.
    - Replace `"VHD_T"` with a Name you want to give this device. This Name is only used to output the success of mounting the VHDs.
14. Save and exit the file and run `source ~/.bashrc`. This will try to mount the VHDs if any are not mounted yet. 

The last command does exactly the same as what will run whenever you reboot the WSL machine or open another terminal from now on.

---
### You can add or remove VHDs at any time later. Simply edit the `~/.bashrc` file and `WSL_mount-VHDs.ps1` as before and reboot WSL or run `source ~/.bashrc`. However note that the scripts do not unmount anything, you may need to do that manually.
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
<br><br>

# Contributions
If you have created other ***general-purpose*** scripts or tools **specific to WSL** that you think would fit into this collection, feel free to start a pull request.<br>
Any other improvements are of course also welcome as long as they work.
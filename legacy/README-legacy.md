# WSL-scripts - legacy
### A collection of Windows and Linux Script files and snippets to make the Windows Subsystem for Linux (WSL) easier to use and more capable.
**This is the legacy Secion that offers solutions for older versions of WSL or Windows.**
***

# Mount VHD files in WSL
### <span style="color:Yellow">***Note:*** This section uses Features that are only available from Windows Insider preview build **20211** and onward. You can check your Windows Build by running `Winver`.</span>
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
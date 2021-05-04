# this mounts a single VHD.
function WSL_mount-VHD($VHDpath) {
	[Int32]$DriveNumber = $null
	# A subfunction!
	function Get-Vdisk-Number {
		Write-Host -ForegroundColor DarkYellow "The VHD seems to be already mounted. You can check Diskmgmt.msc"
		[string]$cmdOutput = $((Get-VHD $VHDpath | Get-Disk).Number)
		if (![string]::IsNullOrWhiteSpace($cmdOutput)) {
			if ([Int32]::TryParse($cmdOutput,[ref]$DriveNumber)){
				return
			} 
		}
		Write-Host -ForegroundColor Red "Failed to get disk number of VHD. Value:'$DriveNumber'"
		exit
	}
	
	[string]$cmdOutput = $((Mount-VHD -Path $VHDpath -PassThru | Get-Disk).Number)
	if (![string]::IsNullOrWhiteSpace($cmdOutput)) {
		if ([Int32]::TryParse($cmdOutput,[ref]$DriveNumber)){
			Write-Host -ForegroundColor blue "mounted VHD as \\.\PhysicalDrive$DriveNumber"
		} else {
			Get-Vdisk-Number
		}
	} else {
		Get-Vdisk-Number
	}
	
	[string]$DiskPath = "\\.\PhysicalDrive$DriveNumber"
	Write-Host -ForegroundColor blue "attempting to mount $DiskPath into WSL"
	wsl --mount $DiskPath
}

# Execution STARTS HERE
# you can also pass VHD paths as arguments to this script, however this is not recommended for permanent mounts.
$paths = @()
if (@($args).length -eq 0) { 
	# use default paths to VHD files   <--- ADD YOUR VHD FILE PATHS TO BE MOUNTED HERE --->
	$paths = @("T:\WSL_bulk_ext4.vhdx","C:\WSL_fast_ext4.vhdx")
} else {
	# parse input parameters into paths
	foreach ($arg in $args) {
		if (!(Test-Path -Path $arg)) {
			Write-Host -ForegroundColor Red "an invalid path was supplied: $arg"
			Write-Host -ForegroundColor Red "aborting..."
			exit
		} else {
			#Write-Host -ForegroundColor yellow "recognized path: $arg"
			$paths += $arg
		}
	}
}

# try to mount the VHDs
foreach ($path in $paths) {
  Write-Host -ForegroundColor yellow "processing VHD $path"
  WSL_mount-VHD($path)
  Write-Host #newline
}
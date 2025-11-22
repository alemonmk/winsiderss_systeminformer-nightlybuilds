$PackageParams = @{
  PackageName    = "systeminformer-nightlybuilds"
  UnzipLocation  = "$(Split-Path $MyInvocation.MyCommand.Definition)\SystemInformer"
  Url            = "https://github.com/winsiderss/si-builds/releases/download/3.2.25324.532/systeminformer-build-win32-bin.zip"
  Url64bit       = "https://github.com/winsiderss/si-builds/releases/download/3.2.25324.532/systeminformer-build-win64-bin.zip"
  Checksum       = "85209032835ef59c14c1b7ac467242a94ccec953b3ce270a1ecab953eb7cff1d"
  ChecksumType   = "sha256"
  Checksum64     = "b34582e3c7e227231efc7dfae1ddc8d097493046bb85b6be3735b26e5e809b4e"
  Checksum64Type = "sha256"
}

$InstallDirectory = Install-ChocolateyZipPackage @PackageParams
if (Get-OSArchitectureWidth 64) { Remove-Item "$InstallDirectory\x86" -Recurse | Out-Null }

# Restore backed up setting file
$SettingFile = "$Env:TEMP\SystemInformer.exe.settings.xml"
if (Test-Path $SettingFile) {
  Copy-Item -Path $SettingFile -Destination "$InstallDirectory" | Out-Null
}

# Grant access to install folder and setting file to builtin users
$ModifyRight = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
$Acl = Get-Acl -Path $InstallDirectory
$Acl.SetAccessRule($ModifyRight)
Set-Acl -Path $InstallDirectory -AclObject $Acl

$PackageParams = Get-PackageParameters

if ($PackageParams["shortcut"]) {
  $ShortcutParams = @{
    ShortcutFilePath = "$Env:PUBLIC\Desktop\System Informer.lnk"
    TargetPath       = "$InstallDirectory\SystemInformer.exe"
    IconLocation     = "$InstallDirectory\SystemInformer.exe"
  }
  Install-ChocolateyShortcut @ShortcutParams
}
if ($PackageParams["defaultTaskMgr"]) {
  $RegPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe"
  if (-not $(Test-Path $RegPath)) { New-Item $RegPath | Out-Null }
  New-ItemProperty -Path $RegPath -Name "Debugger" -PropertyType "String" -Value "$InstallDirectory\SystemInformer.exe" -Force | Out-Null
}

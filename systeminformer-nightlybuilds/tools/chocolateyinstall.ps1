$PackageParams = @{
  PackageName    = "systeminformer-nightlybuilds"
  UnzipLocation  = "$(Split-Path $MyInvocation.MyCommand.Definition)\SystemInformer"
  Url            = "https://github.com/winsiderss/si-builds/releases/download/4.0.26060.1607/systeminformer-build-win32-bin.zip"
  Url64bit       = "https://github.com/winsiderss/si-builds/releases/download/4.0.26060.1607/systeminformer-build-win64-bin.zip"
  Checksum       = "61397a26cb64a4f0ed9080ea14b4470df5d2fe6ff0ee3c795908f823d8f4fbef"
  ChecksumType   = "sha256"
  Checksum64     = "de946fa09d7cfd8954f969cc3b392653471bc2147489e2f2f1c7a39d2ff402c8"
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

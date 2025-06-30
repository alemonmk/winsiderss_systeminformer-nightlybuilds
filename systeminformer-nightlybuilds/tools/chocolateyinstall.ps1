$PackageSourceUrl = "https://github.com/winsiderss/si-builds/releases/download/3.2.25180.1655/systeminformer-3.2.25180.1655-bin.zip"
$Architecture = if (Get-OSArchitectureWidth 32) { "i386" } else { "amd64" }
$InstallDirectory = "$(if (Get-OSArchitectureWidth 64) { $Env:ProgramW6432 } else { $Env:ProgramFiles })\SystemInformer"

$PackageParams = @{
  PackageName    = "systeminformer-nightlybuilds"
  UnzipLocation  = $InstallDirectory
  Url            = $PackageSourceUrl
  Checksum       = "65f336ca5c9e7001449ea34f035bc9263f997112f1e87bfc59a44ae8cd5bceae"
  ChecksumType   = "sha256"
  SpecificFolder = $Architecture
}

Install-ChocolateyZipPackage @PackageParams

# Restore backed up setting file
$SettingFile = "$Env:TEMP\SystemInformer.exe.settings.xml"
if (Test-Path $SettingFile) {
  Copy-Item -Path $SettingFile -Destination "$InstallDirectory\$Architecture" | Out-Null
}

$PackageParams = Get-PackageParameters

switch ($PackageParams) {
  "shortcut" {
    $ShortcutParams = @{
      ShortcutFilePath = "$Env:PUBLIC\Desktop\System Informer.lnk"
      TargetPath       = "$InstallDirectory\$Architecture\SystemInformer.exe"
      IconLocation     = "$InstallDirectory\$Architecture\SystemInformer.exe"
    }
    Install-ChocolateyShortcut @ShortcutParams
  }
  "defaultTaskMgr" {
    $RegPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe"
    if (-not $(Test-Path $RegPath)) { New-Item $RegPath }
    New-ItemProperty -Path $RegPath -Name "Debugger" -PropertyType "String" -Value "$InstallDirectory\$Architecture\SystemInformer.exe"
  }
}

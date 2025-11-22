$InstallDirectory = Split-Path $MyInvocation.MyCommand.Definition
$SettingFilePath = "$InstallDirectory\SystemInformer\SystemInformer.exe.settings.xml"

Copy-Item -Path $SettingFilePath -Destination $Env:TEMP

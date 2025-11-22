$RegPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe"
if (Test-Path $RegPath) { Remove-Item $RegPath -Recurse }

$ShortcutPath = "$Env:PUBLIC\Desktop\System Informer.lnk"
if (Test-Path $ShortcutPath) { Remove-Item $ShortcutPath }

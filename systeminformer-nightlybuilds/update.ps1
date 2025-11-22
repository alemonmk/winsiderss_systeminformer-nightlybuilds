Import-Module chocolatey-au

function global:au_SearchReplace {
    @{
        'tools\chocolateyinstall.ps1' = @{
            "(\t*Url\s*=\s*)(`".*`")"        = "`$1`"$($Latest.Url32)`""
            "(\t*Url64bit\s*=\s*)(`".*`")"   = "`$1`"$($Latest.Url64)`""
            "(\t*Checksum\s*=\s*)(`".*`")"   = "`$1`"$($Latest.Checksum32)`""
            "(\t*Checksum64\s*=\s*)(`".*`")" = "`$1`"$($Latest.Checksum64)`""
        }
    }
}

function global:au_GetLatest {
    $releaseInfo = Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/winsiderss/si-builds/releases/latest"

    $win32asset = $releaseInfo.assets | Where-Object { $_.name -eq "systeminformer-build-win32-bin.zip" }
    $win64asset = $releaseInfo.assets | Where-Object { $_.name -eq "systeminformer-build-win64-bin.zip" }

    $Latest = @{
        Filename = $asset.name
        Version  = $releaseInfo.tag_name
        Url32    = $win32asset.browser_download_url
        Url64    = $win64asset.browser_download_url
    }
    return $Latest
}

update -ChecksumFor all

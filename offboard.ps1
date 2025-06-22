$logFolder = ".\logs"
$archiveName = "offboarding-logs.zip"
$appList = Get-Content ".\app-list.json" | ConvertFrom-Json

foreach ($app in $appList) {
    Write-Host "Attempting to uninstall $($app.name)..."
    $uninstallKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    $uninstallKeyWow = "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    $keys = Get-ChildItem $uninstallKey, $uninstallKeyWow | Where-Object {
        (Get-ItemProperty $_.PSPath).DisplayName -like "*$($app.name)*"
    }

    foreach ($key in $keys) {
        $uninstallString = (Get-ItemProperty $key.PSPath).UninstallString
        if ($uninstallString) {
            try {
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "$uninstallString /quiet" -Wait
                Add-Content "$logFolder\setup-log.txt" "$($app.name) uninstalled."
            } catch {
                Add-Content "$logFolder\setup-log.txt" "Failed to uninstall $($app.name). $_"
            }
        }
    }
}

$profiles = Get-CimInstance Win32_UserProfile | Where-Object {
    $_.Special -eq $false -and $_.LocalPath -notlike "*\Administrator" -and $_.LocalPath -notlike "*\Default*"
}

foreach ($profile in $profiles) {
    try {
        Remove-CimInstance -InputObject $profile
        Add-Content "$logFolder\setup-log.txt" "User profile removed: $($profile.LocalPath)"
    } catch {
        Add-Content "$logFolder\setup-log.txt" "Failed to remove profile: $($profile.LocalPath). $_"
    }
}

if (Test-Path $archiveName) {
    Remove-Item $archiveName
}
Compress-Archive -Path "$logFolder\*" -DestinationPath $archiveName
Write-Host "Offboarding complete. Logs archived as $archiveName"

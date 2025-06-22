# Paths
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logSessionDir = ".\logs\$timestamp"
New-Item -ItemType Directory -Path $logSessionDir -Force | Out-Null
$logPath = "$logSessionDir\setup-log.txt"
$csvLogPath = "$logSessionDir\install-log.csv"
$ticketsPath = "$logSessionDir\tickets.json"

# Event Log Setup
$logName = "ZeroTouchSetup"
if (-not (Get-EventLog -List | Where-Object { $_.LogDisplayName -eq $logName })) {
    New-EventLog -LogName $logName -Source "ZTInstaller"
}

# CSV Header
"Timestamp,AppName,Status,Message" | Out-File $csvLogPath

# Read app list
$apps = Get-Content ".\app-list.json" | ConvertFrom-Json

Add-Content $logPath "---- Setup Log - $(Get-Date) ----`n"

foreach ($app in $apps) {
    try {
        $appName = $app.name
        $installer = "$env:TEMP\$($appName).exe"
        Write-Host "Downloading $appName..."
        Invoke-WebRequest -Uri $app.url -OutFile $installer
        Start-Process -FilePath $installer -ArgumentList $app.silentArgs -Wait

        Add-Content $logPath "$appName installed successfully."
        "$((Get-Date)), $appName, Success, Installed successfully." | Out-File $csvLogPath -Append
        Write-EventLog -LogName $logName -Source "ZTInstaller" -EventId 1000 -EntryType Information -Message "$appName installed successfully"
    } catch {
        Add-Content $logPath "$appName failed to install. $_"
        "$((Get-Date)), $appName, Failure, $($_.Exception.Message)" | Out-File $csvLogPath -Append
        Write-EventLog -LogName $logName -Source "ZTInstaller" -EventId 1001 -EntryType Error -Message "$appName failed: $($_.Exception.Message)"
    }
}

# Summary markdown
$successCount = (Select-String -Path $csvLogPath -Pattern "Success").Count
$failCount = (Select-String -Path $csvLogPath -Pattern "Failure").Count
$summary = @"
# Installation Summary - $timestamp

- Successful Installs: $successCount
- Failed Installs: $failCount

Log file: install-log.csv
"@
$summary | Out-File "$logSessionDir\summary.md"

# Simulated Ticket Logging
$ticket = [PSCustomObject]@{
    TicketID = "HELP-" + (Get-Random -Minimum 1000 -Maximum 9999)
    User = $env:USERNAME
    Issue = "Initial setup automation"
    Status = "Resolved"
    Time = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}
$ticketJson = $ticket | ConvertTo-Json -Depth 2
@($ticket) | ConvertTo-Json -Depth 2 | Out-File $ticketsPath

# User feedback prompt
$feedback = Read-Host "Rate this setup experience from 1-5 (5 = excellent)"
$comments = Read-Host "Any comments or issues?"
$survey = @{
    User = $env:USERNAME
    Rating = $feedback
    Comments = $comments
    Time = (Get-Date)
}
$survey | ConvertTo-Json | Out-File "$logSessionDir\user-feedback.json"

# Archive logs
Compress-Archive -Path "$logSessionDir\*" -DestinationPath ".\logs\install-$timestamp.zip"

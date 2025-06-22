![PowerShell](https://img.shields.io/badge/Built%20With-PowerShell-5391FE?logo=powershell)
![Windows](https://img.shields.io/badge/Platform-Windows-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-Simulated--Demo-yellow)
# Zero-Touch Endpoint Setup (Simulated Onboarding Project)
This project simulates a zero-touch onboarding workflow for Windows endpoints using PowerShell, JSON-driven app configs, structured logging, and offboarding without needing Intune or enterprise MDMs(for now).

The goal of this project is to demonstrate how any IT team can automate application deployment, security configuration, and audit logging in a locally testable but enterprise-adaptable way... MDM or not.
```                                
       __        __   _                            _          _   _            ____  _____    _    ____  __  __ _____ 
       \ \      / /__| | ___ ___  _ __ ___   ___  | |_ ___   | |_| |__   ___  |  _ \| ____|  / \  |  _ \|  \/  | ____|
        \ \ /\ / / _ \ |/ __/ _ \| '_ ` _ \ / _ \ | __/ _ \  | __| '_ \ / _ \ | |_) |  _|   / _ \ | | | | |\/| |  _|  
         \ V  V /  __/ | (_| (_) | | | | | |  __/ | || (_) | | |_| | | |  __/ |  _ <| |___ / ___ \| |_| | |  | | |___ 
          \_/\_/ \___|_|\___\___/|_| |_| |_|\___|  \__\___/   \__|_| |_|\___| |_| \_\_____/_/   \_\____/|_|  |_|_____|
                                                                                                                                                                              
                                                                                                
```

## Why This Project Exists
Manual endpoint provisioning is time-consuming, inconsistent, and error-prone.

### This project solves that with:

- Automated silent software installs

- Configurable app list via JSON

- Structured logs in .txt, .csv, .json, and Event Viewer

- Ticket simulation and user feedback collection

- Security configuration (Defender + Firewall)

- Offboarding with uninstalls, profile cleanup, and log archiving

- Intune/Autopilot-ready architecture

## File Structure
```
zero-touch-endpoint-setup/
├── install.ps1            # Main automation script
├── app-list.json          # App metadata (names, URLs, silent switches)
├── firewall-rules.ps1     # Security configuration
├── offboard.ps1           # App uninstall and profile cleanup
├── logs/                  # Timestamped logs and archives
└── README.md              # This file
```

## Features  

- JSON-driven app list for scalable installs

- Session-based log rotation

- Event Viewer integration (ZeroTouchSetup source)

- CSV logging for compliance and analytics

- Helpdesk ticket simulation (JSON)

- User feedback prompt at end of install

- Archive logs as .zip after each session

- Offboarding script to uninstall apps and wipe user profiles

## Application List: `app-list.json`
This JSON file defines all apps to be silently installed. Example:

```json
[
  {
    "name": "7-Zip",
    "url": "https://www.7-zip.org/a/7z2301-x64.exe",
    "silentArgs": "/S"
  },
  {
    "name": "Google Chrome",
    "url": "https://dl.google.com/chrome/install/375.126/chrome_installer.exe",
    "silentArgs": "/silent /install"
  },
  {
    "name": "Zoom",
    "url": "https://zoom.us/client/latest/ZoomInstaller.exe",
    "silentArgs": "/quiet"
  }
]
```
## Main Install Script: `install.ps1`

```powershell
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

# Summary
$successCount = (Select-String -Path $csvLogPath -Pattern "Success").Count
$failCount = (Select-String -Path $csvLogPath -Pattern "Failure").Count
$summary = @"
# Installation Summary - $timestamp

- Successful Installs: $successCount
- Failed Installs: $failCount

Log file: install-log.csv
"@
$summary | Out-File "$logSessionDir\summary.md"

# Ticket simulation
$ticket = [PSCustomObject]@{
    TicketID = "HELP-" + (Get-Random -Minimum 1000 -Maximum 9999)
    User = $env:USERNAME
    Issue = "Initial setup automation"
    Status = "Resolved"
    Time = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}
@($ticket) | ConvertTo-Json -Depth 2 | Out-File $ticketsPath

# Feedback
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
```

## Security Script: `firewall-rules.ps1`
```powershell
Set-MpPreference -DisableRealtimeMonitoring $false
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Add-Content .\logs\setup-log.txt "Security policies applied: Firewall and Defender enabled.`n"
```
## Offboarding Script: `offboard.ps1`
```powershell
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
```

# How to Run

1. Open PowerShell as Administrator  
2. Navigate to the script directory
`cd "C:\Path\To\zero-touch-endpoint-setup"`  

3. Run the main installer
`.\install.ps1`  

4. (Optional) Apply security settings
`.\firewall-rules.ps1`  

5. (Optional) Run offboarding
`.\offboard.ps1`

# Tips for First-Time Execution

Temporarily bypass script policy if needed  

```Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass ```

### To scale this project into a Microsoft Intune deployment:

- Use IntuneWinAppUtil.exe to package the folder

- Define install/uninstall commands in the Win32 app settings

- Create custom detection rules via PowerShell

- Assign to user or device groups during Autopilot enrollment

- Forward logs to Azure Monitor or Log Analytics

### Future Posssible Enhancements
- Version detection and update automation

- Teams webhook for ticket/feedback forwarding

- GUI using Windows Forms or WPF

- Cloud-hosted JSON config + Azure log storage

```                                        
             |  _ \ _____      _____ _ __ ___  __| | | |__  _   _    ___ _   _ _ __(_) ___  ___(_) |_ _   _ 
             | |_) / _ \ \ /\ / / _ \ '__/ _ \/ _` | | '_ \| | | |  / __| | | | '__| |/ _ \/ __| | __| | | |
             |  __/ (_) \ V  V /  __/ | |  __/ (_| | | |_) | |_| | | (__| |_| | |  | | (_) \__ \ | |_| |_| |
             |_|   \___/_\_/\_/ \___|_|  \___|\__,_| |_.__/ \__, |  \___|\__,_|_|  |_|\___/|___/_|\__|\__, |
                   | ____| (_)                              |___/                                     |___/ 
              _____|  _| | | |                                                                              
             |_____| |___| | |                                                                              
                   |_____|_|_|                                                                              
```

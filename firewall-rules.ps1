Set-MpPreference -DisableRealtimeMonitoring $false
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Add-Content .\logs\setup-log.txt "Security policies applied: Firewall and Defender enabled.`n"

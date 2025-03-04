# AfterhoursLogin
Base for powershell alerts on unusual login attempts for Windows system. 
How to Use This Script:

Save the Script: Save it as Monitor-Login.ps1 (or any name you prefer).



Run with Administrative Privileges: 

Open PowerShell as Administrator (right-click Start > Windows PowerShell (Admin)).



Navigate to the script's directory and run it:

powershell


.\Monitor-Login.ps1


Create Log Directory: The script attempts to log to C:\SecurityLogs. Create this directory first:

powershell


New-Item -Path "C:\SecurityLogs" -ItemType Directory -Force


Execution Policy: If you get an execution policy error, you may need to allow scripts:

powershell


Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned


What the Script Does:

Checks Time: Runs continuously and only processes events between 8 PM and 6 AM.



Monitors Logs: Looks for Event ID 4624 (successful logins) in the Security log every 5 minutes.



Filters Events: Ignores system accounts (SYSTEM, NETWORK SERVICE, etc.).



Shows Popup: Displays a Windows message box with login details if an unusual login is detected.



Logs to File: Writes details to C:\SecurityLogs\AfterHoursLogins.txt for record-keeping.



Error Handling: Includes basic error handling for log access issues.


Notes:

This script requires administrative privileges to read the Security event log.



It checks the last 5 minutes of events to avoid duplicate alerts (adjust Start-Sleep and .AddMinutes(-5) if needed).



The popup uses the Windows Forms library, which is built into Windows 11.



To stop the script, press Ctrl+C in the PowerShell window.


Explain event IDs



Network security monitoring



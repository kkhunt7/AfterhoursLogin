# Requires running with administrative privileges to access Security logs

# Function to display popup message
function Show-PopupAlert {
    param (
        [string]$Message
    )
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($Message, "Security Alert", 
        [System.Windows.Forms.MessageBoxButtons]::OK, 
        [System.Windows.Forms.MessageBoxIcon]::Warning)
}

# Main monitoring loop
while ($true) {
    # Get current time
    $currentTime = Get-Date
    $currentHour = $currentTime.Hour
    
    # Check if current time is between 8 PM (20:00) and 6 AM (06:00)
    $isAfterHours = ($currentHour -ge 20 -or $currentHour -lt 6)
    
    if ($isAfterHours) {
        # Get the last 5 minutes of security events
        $timeSpan = $currentTime.AddMinutes(-5)
        
        try {
            # Query Security log for successful logins (Event ID 4624)
            $loginEvents = Get-WinEvent -LogName "Security" -FilterXPath "*[System[EventID=4624] and System[TimeCreated[@SystemTime>='$timeSpan']]]" -ErrorAction Stop
            
            foreach ($event in $loginEvents) {
                # Extract event details
                $eventTime = $event.TimeCreated
                $xmlEvent = [xml]$event.ToXml()
                $accountName = $xmlEvent.Event.EventData.Data |
                    Where-Object { $_.Name -eq "TargetUserName" } |
                    Select-Object -ExpandProperty "#text"
                $computerName = $xmlEvent.Event.EventData.Data |
                    Where-Object { $_.Name -eq "WorkstationName" } |
                    Select-Object -ExpandProperty "#text"
                
                # Skip system accounts
                if ($accountName -notmatch "SYSTEM|NETWORK SERVICE|LOCAL SERVICE") {
                    # Prepare alert message
                    $alertMessage = "Unusual login detected!`n" +
                                  "Time: $eventTime`n" +
                                  "User: $accountName`n" +
                                  "Computer: $computerName`n" +
                                  "This login occurred after hours (8 PM - 6 AM)"
                    
                    # Show popup alert
                    Show-PopupAlert -Message $alertMessage
                    
                    # Log to file
                    $logEntry = "$eventTime - Unusual login: $accountName from $computerName"
                    Add-Content -Path "C:\SecurityLogs\AfterHoursLogins.txt" -Value $logEntry
                }
            }
        }
        catch {
            Write-Warning "Error accessing Security log: $_"
        }
    }
    
    # Wait 5 minutes before checking again
    Start-Sleep -Seconds 300
}

$Log = "$PSScriptRoot\Lane_Profiles.csv"

Add-Type -AssemblyName PresentationCore,PresentationFramework

$Query = " SET NOCOUNT ON
    SELECT etc.term_id, etc.terminal_name, etc.lane_prof, files.timestamp, filename, result
    FROM (
	    SELECT term_id, terminal_name, lane_prof
	    FROM esp_term_config
	    WHERE timestamp = (
		    SELECT MAX(timestamp)
		    FROM esp_term_config
	    ) AND terminal_name NOT LIKE '%admin%'
    ) etc

    FULL JOIN (
	    SELECT *
	    FROM (
			    SELECT
				    CONVERT(DATETIME, STUFF(STUFF(STUFF(STUFF(upp.timestamp,15,0,'.'),13,0,':'),11,0,':'),9,0,' ')) as timestamp,
				    upp.term_id,
				    tc.terminal_name,
				    tc.lane_prof,
				    upp.filename,
				    upp.result
			    FROM upp_files upp
				    JOIN (
					    SELECT term_id, terminal_name, lane_prof
					    FROM esp_term_config
					    WHERE timestamp = (
						    SELECT MAX(timestamp)
						    FROM esp_term_config
					    )
				    )as tc
					    ON tc.term_id = upp.term_id
			    GROUP BY upp.timestamp,upp.term_id,tc.terminal_name,tc.lane_prof,upp.filename,upp.result
			    UNION ALL
			    SELECT
				    CONVERT(DATETIME, STUFF(STUFF(STUFF(STUFF(rba.timestamp,15,0,'.'),13,0,':'),11,0,':'),9,0,' ')) as timestamp,
				    rba.term_id,
				    tc.terminal_name,
				    tc.lane_prof,
				    rba.filename,
				    rba.result
			    FROM rba_files rba
				    JOIN (
					    SELECT term_id, terminal_name, lane_prof
					    FROM esp_term_config
					    WHERE timestamp = (
						    SELECT MAX(timestamp)
						    FROM esp_term_config
					    )
				    )as tc
					    ON tc.term_id = rba.term_id
			    GROUP BY rba.timestamp,rba.term_id,tc.terminal_name,tc.lane_prof,rba.filename,rba.result
	    ) as data
	    WHERE timestamp >= DATEADD(DAY,DATEDIFF(DAY,1,GETDATE()),0) and filename NOT LIKE '%xml%'
    ) files ON etc.term_id = files.term_id
"

$Query2 = "SET NOCOUNT ON
    SELECT 
	    CONVERT(DATETIME, STUFF(STUFF(STUFF(timestamp,11,0,':'),9,0,':'),7,0,' ')) as timestamp
    FROM esp_timestamp 
    WHERE status = 'active' 
    GROUP BY timestamp,status
"

$ConfigServerDownload = sqlcmd -E -d "esocketpos" -Q $Query2 -s"," -h -1 -w 700 -W

if([datetime]$ConfigServerDownload -lt (Get-Date).AddDays(-1)){
    $MsgBox = [System.Windows.MessageBox]::Show("Latest download from ConfigServer $ConfigServerDownload.`n`nRestarting eSocket.POS Config Agent to get the latest configurations.",'WARNING!','OK','Error')
    Remove-Item "C:\postilion\eSocket.POS\remote_properties.txt" -Force -ErrorAction SilentlyContinue
    Restart-Service EspConfigAgent -Force

    [int]$Time = 90
    $Lenght = $Time / 100
    for ($Time; $Time -gt 0; $Time--) {
        $min = [int](([string]($Time/60)).split('.')[0])
        $text = " " + $min + " minutes " + ($Time % 60) + " seconds left"
        Write-Progress -Activity "Watiting for config to download..." -Status $Text -PercentComplete ($Time / $Lenght)
        Start-Sleep 1
    }
}else{
    $FirmwareUpdates = sqlcmd -E -d "esocketpos" -Q $Query -s"," -w 700 -W
    $FirmwareUpdates | ForEach-Object{if($_ -notlike "*----*"){$_}} | ConvertFrom-Csv | Out-GridView -Wait -Title "Latest download from ConfigServer $ConfigServerDownload"
}

$FirmwareUpdates | ForEach-Object{if($_ -notlike "*----*"){$_}} | Out-File $Log

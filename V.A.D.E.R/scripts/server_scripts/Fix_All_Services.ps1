Write-Host ""

$services = Get-Service

$skipList = @("MapsBroker", "gupdate", "CDPSvc", "sppsvc", "RemoteRegistry", "WbioSrvc", "OneSyncSvc_8fad8050", "BITS", "edgeupdate")
$fixedList = @()
$failedList = @()

foreach ($service in $services) {
    $serviceName = $service.Name
    $displayName = $service.DisplayName
    $status = $service.Status
    $startType = $service.StartType

    if ($startType -eq "Automatic" -and $status -ne "Running" -and $skipList -notcontains $serviceName) {
        Write-Host "The $displayName service is not running"
        Write-Host "Attempting to start $displayName"
        Write-Host " "
        Start-Service -Name $serviceName

        $elapsedTime = 0
        while ($status -ne "Running") {
            Start-Sleep -s 10
            $elapsedTime += 10
            $service = Get-Service -Name $serviceName
            $status = $service.Status
            if ($elapsedTime -gt 20) {
                Write-Host "The $displayName service failed to start after 30 seconds"
                Write-Host " "
                break
            }
        }

        if ($status -eq "Running") {
            $fixedList += "$displayName"
            Write-Host "The $displayName service was started successfully"
            Write-Host " "
        } else {
            $failedList += "$displayName"
            Write-Host "The $displayName service failed to start"
            Write-Host " "
        }
    }
}

if ($($fixedList.Count) -gt 0) {
    Write-Host "$($fixedList.Count) services were successfully started: $($fixedList -join ', ')"
} if ($($failedList.Count) -gt 0) {
    Write-Host "$($failedList.Count) services failed to start: $($failedList -join ', ')"
} if ($($failedList.Count) -lt 1) {
    Write-Host " "
    Write-Host "All services are healthy"
}

Write-Host ""

Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
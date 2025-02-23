Write-Host ""

$serviceName = "EspConfigAgent"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
$displayName = $service.DisplayName

Remove-Item "C:\postilion\eSocket.POS\remote_properties.txt" -Force -ErrorAction SilentlyContinue

if ($service -eq $null) {
    Write-Host "The $displayName service is not installed on this computer."
} elseif ($service.Status -ne "Running") {
    Write-Host "The $displayName service is not running. Starting $displayName..."
    Start-Service -Name $serviceName
    Start-Sleep -s 10
    Write-Host "The $displayName service has been started."
} elseif ($service.Status -eq "Running") {
    Write-Host "The $displayName service is already running. Restarting $displayName..."
    Restart-Service -Name $serviceName -Force
    Start-Sleep -s 10
    Write-Host "The $displayName service has been restarted."
} else {
    Write-Host "An error has occured. This should not have happened."
}

Write-Host ""

Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
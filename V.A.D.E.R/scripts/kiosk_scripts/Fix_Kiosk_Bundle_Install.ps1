do{
    Clear-Host
    $Option = 0
    Write-Host "******** Fix Kiosk Bundle Installation Errors *******"
    Write-Host "*        Select step where KioskBundle failed       *"
    Write-Host "*                                                   *"
    Write-Host "* 1. 002_creditconnectorId                          *"
    Write-Host "* 2. 004_deviceserviceId                            *"
    Write-Host "* 3. Missing Prerequisites (Install-TerminalPackage)*"
    Write-Host "* 4. Exit                                           *"
    Write-Host "*****************************************************"
    Write-Host ""
    $Option = Read-Host "Enter choice"

    switch($Option){
        "1"{
            & "C:\Staging\_UUUUconfig_PRIVATE\Remove-CreditConnector.ps1"
        }
        "2"{
            & "C:\Staging\_UUUUconfig_PRIVATE\Remove-OPOSDevices.ps1"
        }
        "3"{
            & "C:\Staging\Install-TerminalPackage\Install-TerminalPackage.ps1"
        }
    }
}While($Option -ne 4)
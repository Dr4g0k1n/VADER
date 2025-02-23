Clear-Host

$POSAdminUser   = "Admin"
$POSAdminPass   = "Redacted"
$KioskAdminUser = "Administrator"
$KioskAdminPass = "Redacted"

$Terminals = "$PSScriptRoot\..\..\terminal_list.txt"

If($env:USERNAME -ne "$env:COMPUTERNAME`$"){
    $Terminals | Out-File $Terminals -Encoding ascii
    Write-Output "************* Reboot POS Terminals **************"
    Write-Output "*    Enter the terminal IP address or hostname  *"
    Write-Output "*        in the window that will appear.        *"
    Write-Output "*       All POS's will be auto-populated.       *"
    Write-Output "*        Enter in the following format:         *"
    Write-Output "*                  BOXUUUU-001                  *"
    Write-Output "*                  192.168.1.1                  *"
    Write-Output "*                                               *"
    Write-Output "*      then save and close Notepad window       *"
    Write-Output "*************************************************"

    Write-Output ""
    Write-Output "POS's listed in the notepad window will reboot."
    Write-Output ""
            
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    & "$PSScriptRoot\Get_POS_Terminals.ps1"
    Notepad.exe $Terminals | out-null
        
    $Terminals = Get-Content $Terminals
}

foreach ($Terminal in $Terminals) {
    Write-Host "Testing connection to $Terminal"
    $TerminalOnline = Test-Connection -Computername $Terminal -BufferSize 16 -Count 1 -Quiet
    
    if ($TerminalOnline -eq $True -and $Terminal -match '^[a-zA-Z0-9\-]+$'){
        if($Terminal -like "*KIOSK*"){
            $Creds = New-Object System.Management.Automation.PSCredential("$Terminal\$KioskAdminUser", $($KioskAdminPass | ConvertTo-SecureString -AsPlainText -Force))
            New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\$Terminal\C$" -Credential $Creds | Out-Null
        }else{
            $Creds = New-Object System.Management.Automation.PSCredential("$Terminal\$POSAdminUser", $($POSAdminPass | ConvertTo-SecureString -AsPlainText -Force))
            New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\$Terminal\C$" -Credential $Creds | Out-Null
        }
        Write-Host "$Terminal is rebooting" -ForegroundColor Green
        shutdown /r /m \\$Terminal /t 0

        Remove-PSDrive -Name "Z"
    }else{
        Write-Host "$Terminal is offline" -ForegroundColor Red
    }
}

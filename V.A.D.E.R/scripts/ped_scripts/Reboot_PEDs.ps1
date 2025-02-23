function Get-PEDPorts {
    param (
        $Terminals
    )

    foreach ($Terminal in $Terminals) {
        $SQLTemplate += "'$Terminal',"
    }
    $SQLTemplate = $SQLTemplate.Substring(0,$SQLTemplate.Length-1)

    $Query = "
        SET NOCOUNT ON
        SELECT remote_ip_address, remote_port
        FROM esp_device_config
        WHERE timestamp = (
            SELECT MAX(timestamp) 
            FROM esp_term_config
        )
        AND remote_ip_address NOT LIKE '%admin%'
        AND remote_ip_address IN ($SQLTemplate)
    "
    Write-Host "Getting PED ports for $Terminals"
    $TerminalPorts = Invoke-Sqlcmd -Query $Query -Database "esocketpos"

    return $TerminalPorts
}

function Get-PEDResponse {
    # Get-PEDResponse "DUAL9991-151" "12001" "07.*"
    param( 
        [string] $Hostname, 
        [int] $PEDPort,
        $Message
    )
    
    $Socket = New-Object System.Net.Sockets.TcpClient($Hostname, $PEDport) 
    if ($null -eq $Socket) { return; }

    $Stream = $Socket.GetStream() 
    $Writer = New-Object System.IO.StreamWriter($stream) 

    $Buffer = New-Object System.Byte[] 1024 
    $Encoding = New-Object System.Text.AsciiEncoding 
    $Writer.WriteLine($message) 
    $Writer.Flush()

    Start-Sleep -Seconds 1
 
    while ($Stream.DataAvailable) {  
        $Read = $Stream.Read($Buffer, 0, 1024)    
        $Response = ($Encoding.GetString($Buffer, 0, $Read))  
    }

    $Writer.WriteLine("")
    $Writer.Flush()

    $Writer.Close()
    $Stream.Close()
    $Socket.Close()

    $Response = $Response -replace "","" -replace "",""

    return $Response
}

function Restart-PED {
    param( 
        [string] $Hostname, 
        [int] $PEDPort
    )
    
    Get-PEDResponse $Hostname $PEDPort "97.#" | Out-Null
}

Clear-Host

$Terminals = "$PSScriptRoot\..\..\terminal_list.txt"
& "$PSScriptRoot\..\Get_All_Terminals.ps1"

if($env:USERNAME -ne "$env:COMPUTERNAME`$"){
    Write-Output "**************** Reboot Pin Pads ****************"
    Write-Output "*     Enter the computer hostnames in the       *"
    Write-Output "*            window that will appear.           *"
    Write-Output "*  Available terminals will be auto-populated   *"
    Write-Output "*        Enter in the following format:         *"
    Write-Output "*                  BOXUUUU-001                  *"
    Write-Output "*                 UUUUKIOSK-083                 *"
    Write-Output "*                  192.168.1.1                  *"
    Write-Output "*                                               *"
    Write-Output "*    then save and close the Notepad window     *"
    Write-Output "*************************************************"
            
    Write-Output ""
    Write-Output "Nodes listed in the notepad window will reboot their PEDs."
    Write-Output ""

    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    Notepad.exe $Terminals | out-null
        
    $Terminals = Get-Content $Terminals
}

Clear-Host

$Terminals = Get-PEDPorts $Terminals

foreach ($Terminal in $Terminals) {
    $Hostname = $Terminal.remote_ip_address
    $PEDPort = $Terminal.remote_port

    Write-Host "Testing connection to $Hostname"
    $TerminalOnline = Test-Connection -Computername $Hostname -BufferSize 16 -Count 1 -Quiet

    if ($TerminalOnline -eq $True) {
        Write-Host "$Hostname is online. Rebooting PED" -ForegroundColor Green
        Restart-PED $Hostname $PEDPort
    }
    else {
        Write-Host "$Hostname is offline" -ForegroundColor Red
    }
}

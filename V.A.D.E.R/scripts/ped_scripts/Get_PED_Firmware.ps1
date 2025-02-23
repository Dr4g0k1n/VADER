$Log = "$PSScriptRoot\PED_Firmware.csv"

$Versions = @()
[DateTime]$Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm'

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
    Write-Host "Getting PED ports for..."
    Write-Host $Terminals
    Write-Host " "
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

function Get-PEDHealthStat {
    param( 
        [string] $Hostname, 
        [int] $PEDPort
    ) 

    $Offset = 4
    $Response = Get-PEDResponse $Hostname $PEDPort "08.0"

    if($Response.Length -gt $Offset){
        $RawPEDData = $Response.Substring($Offset) -split ""

        $PEDData = [PSCustomObject]@{
            "Timestamp"                    = $Timestamp
            "SiteID"                       = $env:COMPUTERNAME.Substring(4, 4)
            "Hostname"                     = $Hostname
            "Online"                       = [bool]$TerminalOnline
            "Number of MSR Swipes"         = $RawPEDData[0]
            #"MSR info"                     = $RawPEDData[]
            "Number of bad Track 1 reads"  = $RawPEDData[1]
            "Number of bad Track 2 reads"  = $RawPEDData[2]
            "Number of bad Track 3 reads"  = $RawPEDData[3]
            "Number of signature totals"   = $RawPEDData[4]
            #"Contactless info"             = ""
            "Number of reboots"            = $RawPEDData[5]
            "Device name"                  = $RawPEDData[6]
            #"Smart card info"              = ""
            #"Barcode info"                 = ""
            #"Bluetooth search info"        = ""
            #"Bluetooth connection info"    = ""
            #"Display backlight info"       = ""
            "Unit injected serial number"  = $RawPEDData[7]
            "OS version"                   = $RawPEDData[8]
            "Application version"          = $RawPEDData[9]
            "Security library version"     = $RawPEDData[10]
            "TDA version"                  = $RawPEDData[11]
            "EFTL version"                 = $RawPEDData[12]
            "EFTP version"                 = $RawPEDData[13]
            "Free RAM size in KB"          = $RawPEDData[14]
            "Free Flash memory size in KB" = $RawPEDData[15]
            "Manufacture date"             = $RawPEDData[16]
            "CPEM type"                    = $RawPEDData[17]
            "Pen Status"                   = $RawPEDData[18]
            "Application name"             = $RawPEDData[19]
            "Manufacture ID"               = $RawPEDData[20]
            "Digitizer version"            = $RawPEDData[21]
            "Manufacturer serial number"   = $RawPEDData[22]
            "PCI version"                  = $RawPEDData[23]
            "Camera support"               = $RawPEDData[24]
        }
    }else{
        $PEDData = [PSCustomObject]@{
            "Timestamp"                    = $Timestamp
            "SiteID"                       = $env:COMPUTERNAME.Substring(4, 4)
            "Hostname"                     = $Hostname
            "Online"                       = [bool]$TerminalOnline
        }
    }
    return $PEDData
}

function Get-ArrayNoteProperties {
    param(
        $Array
    )
    $NoteProperties = $Array | ForEach-Object { $_ | Get-Member | Where-Object { $_.MemberType -ne "Method" } | Select-Object -ExpandProperty Name } | Sort-Object -Unique

    $SortedProperties = @("Timestamp", "SiteID", "Hostname", "Online","Device name","Application version")
    $SortedProperties = $SortedProperties + $($NoteProperties | Where-Object { $_ -notin $SortedProperties })

    return $SortedProperties
}

Clear-Host

$Terminals = "$PSScriptRoot\..\..\terminal_list.txt"
& "$PSScriptRoot\..\Get_All_Terminals.ps1"

If($env:USERNAME -ne "$env:COMPUTERNAME`$"){
    Write-Output "*********** Get PED Firmware Versions ***********"
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
    Write-Output "Nodes listed in the notepad window will display their PED firmware version."
    Write-Output "The firmware version will be listed under the 'Application version' column."
    Write-Output ""

    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            
    Notepad.exe $Terminals | Out-Null
        
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
        Write-Host "$Hostname is online. Gathering PED data" -ForegroundColor Green
        $PEDData  = Get-PEDHealthStat $Hostname $PEDPort

        [array]$Versions += $PEDData
    }
    else {
        Write-Host "$Hostname is offline" -ForegroundColor Red
        $PEDData = [PSCustomObject]@{
            Timestamp = $Timestamp
            SiteID    = $env:COMPUTERNAME.Substring(4, 4)
            Hostname  = $Hostname
            Online    = [bool]$TerminalOnline
        }
        [array]$Versions += $PEDData
    }
    $PEDData  = $null
}

$Versions = $Versions | Select-Object -Property (Get-ArrayNoteProperties $Versions) | Sort-Object -Property "Hostname"

$Versions | Export-Csv $Log -NoTypeInformation

if($env:USERNAME -ne "$env:COMPUTERNAME`$"){
    $Versions | Out-GridView -Wait
}

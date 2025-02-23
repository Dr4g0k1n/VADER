Clear-Host

#Import-Module -Name "SqlServer"

Get-PSDrive | ForEach-Object{if($_.Name -eq 'Z'){Remove-PSDrive -Name $_.Name}}

  $POSAdminUser       = "Admin"
  $POSAdminPass       = "Redacted"
  $KioskAdminUser     = "Administrator"
  $KioskAdminPass     = "Redacted"
  $Log                = "$PSScriptRoot\Get_POS_Terminal_Versions.csv"
 [DateTime]$Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
  $Versions           = @()
  $SQLServerInstance  = $env:COMPUTERNAME
  $DatabaseName       = "TOS"
  #$TableName          = "Terminals"

function Read-RemoteNCRSoftware{
    param(
        $Terminal
    )

    Get-Service -ComputerName $Terminal -Name RemoteRegistry | Set-Service -StartupType Manual -PassThru| Start-Service
    $RemoteRegistry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Terminal)

    $UninstallKeys = @("SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
                       "SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall")

    foreach($Key in $UninstallKeys){
        $Uninstalls = $RemoteRegistry.OpenSubKey($Key)
        if($null -ne $Uninstalls){
            foreach($Uninstall in $Uninstalls.GetSubKeyNames()){
                $ComputerName   = $RemoteRegistry.OpenSubKey("SYSTEM\ControlSet001\Control\ComputerName\ActiveComputerName")
                $Software       = $RemoteRegistry.OpenSubKey("$Key\$Uninstall")
                $Hostname       = $ComputerName.GetValue("ComputerName")
                $Publisher      = $Software.GetValue("Publisher")
                [string]$DisplayName    = $Software.GetValue("DisplayName")
                [string]$DisplayVersion = $Software.GetValue("DisplayVersion")

                if(($null -ne $DisplayName) -and ($null -ne $DisplayVersion)){

                    $SoftwareData = [PSCustomObject]@{
                        Hostname       = $Hostname
                        Publisher      = $Publisher
                        DisplayName    = $DisplayName
                        DisplayVersion = $DisplayVersion
                    }
                }

                [array]$SoftwareVersions += $SoftwareData
            }
        }
    }
    $SoftwareVersions = $SoftwareVersions | Where-Object{$_.Publisher -eq "NCR"} | Sort-Object -Property "DisplayName"

    $TerminalData = [PSCustomObject]@{
        Timestamp = $Timestamp
        SiteID    = $env:COMPUTERNAME.Substring(4,4)
        Hostname  = $Hostname
        Online    = [bool]$TerminalOnline
    } 

    foreach($SoftwareVersion in $SoftwareVersions){
        Add-Member -InputObject $TerminalData -MemberType NoteProperty -Name $SoftwareVersion.DisplayName -Value $SoftwareVersion.DisplayVersion -Force
    }

    return $TerminalData
}

function Get-ArrayNoteProperties{
    param(
        $Array
    )
    $NoteProperties = $Array | ForEach-Object{$_ | Get-Member | Where-Object{$_.MemberType -ne "Method"} | Select-Object -ExpandProperty Name} | Sort-Object -Unique

    $SortedProperties = @("Timestamp", "SiteID", "Hostname", "Online")
    $SortedProperties = $SortedProperties + $($NoteProperties | Where-Object {$_ -notin $SortedProperties})

    return $SortedProperties
}

function Add-MissingColumns{
    param(
        $DatabaseName,
        $SourceColumns,
        $DestinationTable
    )
    
    $Database = Get-SqlDatabase -ServerInstance $SQLServerInstance -Name $DatabaseName
    if($null -ne $Database){
        $Table = $Database.Tables[$DestinationTable]

        if($null -ne $Table){
            $MissingColumns = (Compare-Object -ReferenceObject $SourceColumns -DifferenceObject $Table.Columns.Name | Where-Object {$_.SideIndicator -eq "<="}).InputObject
        
            if($MissingColumns){
                $Type = [Microsoft.SqlServer.Management.SMO.DataType]::NVarCharMax
                
                foreach($Column in $MissingColumns){
                    $NewColumn =  New-Object -TypeName Microsoft.SqlServer.Management.SMO.Column -argumentlist $Table, $Column, $Type  
                    $Table.Columns.Add($NewColumn)
                    $Table.Alter()
                }
            }
        }
    }
}


$Terminals = "$PSScriptRoot\..\..\terminal_list.txt"

Write-Output "*********** Get POS Terminal Versions ***********"
Write-Output "*    Enter the terminal IP address or hostname  *"
Write-Output "*        in the window that will appear.        *"
Write-Output "*       All POS's will be auto-populated.       *"
Write-Output "*        Enter in the following format:         *"
Write-Output "*                  BOXUUUU-001                  *"
Write-Output "*                  192.168.1.1                  *"
Write-Output "*                                               *"
Write-Output "*      then save and close Notepad window       *"
Write-Output "*************************************************"

Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

& "$PSScriptRoot\Get_POS_Terminals.ps1"
Notepad.exe $Terminals | out-null

$Terminals = Get-Content $Terminals

foreach($Terminal in $Terminals){
    Write-Host "Testing connection to $Terminal"
    $TerminalOnline = Test-Connection -Computername $Terminal -BufferSize 16 -Count 1 -Quiet

    If ($TerminalOnline -eq $True){
        Write-Host "$Terminal is online. Gathering version data" -ForegroundColor Green
        
        if($Terminal -like "*KIOSK*"){
            $Creds = New-Object System.Management.Automation.PSCredential("$Terminal\$KioskAdminUser", $($KioskAdminPass | ConvertTo-SecureString -AsPlainText -Force))
            New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\$Terminal\C$" -Credential $Creds | Out-Null
        }else{
            $Creds = New-Object System.Management.Automation.PSCredential("$Terminal\$POSAdminUser", $($POSAdminPass | ConvertTo-SecureString -AsPlainText -Force))
            New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\$Terminal\C$" -Credential $Creds | Out-Null
        }
        
        $RemoteNCRSoftware = Read-RemoteNCRSoftware $Terminal

        [array]$Versions += $RemoteNCRSoftware

        Remove-PSDrive -Name "Z"
    }else{
        Write-Host "$Terminal is offline" -ForegroundColor Red
        $RemoteNCRSoftware = [PSCustomObject]@{
            Timestamp              = $Timestamp
            SiteID                 = $env:COMPUTERNAME.Substring(4,4)
            Hostname               = $Terminal
            Online                 = [bool]$TerminalOnline
        }
        [array]$Versions += $RemoteNCRSoftware
    }
}

#$VersionsColumns = Get-ArrayNoteProperties $Versions

#Add-MissingColumns $DatabaseName $VersionsColumns $TableName

$Versions = $Versions | Select-Object -Property (Get-ArrayNoteProperties $Versions) | Sort-Object -Property "Hostname"
$Versions | Export-Csv $Log -NoTypeInformation #Write-SqlTableData -ServerInstance $SQLServerInstance -DatabaseName $DatabaseName -SchemaName "dbo" -TableName $TableName -Force

if($env:USERNAME -ne "$env:COMPUTERNAME`$"){
    $Versions | Out-GridView -Wait
}

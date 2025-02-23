Clear-Host

Get-PSDrive | ForEach-Object{if($_.Name -eq 'Z'){Remove-PSDrive -Name $_.Name}}

$MasterCSV      = "C:\Staging\_UUUUconfig_PRIVATE\Deploy-Marquees\MarqueeAssignments.csv"
$SheetName      = "Sheet1"
$POSAdminUser   = "Admin"
$POSAdminPass   = "Redacted"
$KioskAdminUser = "Administrator"
$KioskAdminPass = "Redacted"
$ScriptName     = ($MyInvocation.MyCommand.Name).Split(".")[0]
$Log1           = "C:\Staging\_UUUUconfig_PRIVATE\Deploy-Marquees\Deploy-Marquees.log"
$Log2           = "$PSScriptRoot\$ScriptName.log"

function New-MediaJSON {
    param (
        $Unit
    )

    $Site = $CSV | Where-Object { $_.Unit -eq $Unit }

    $JSONdata = @()

    foreach ($Media in $Site.PSObject.Properties) {
        if ($null -ne $Media.Value) {
            switch ($Media.Value) {
                "C"   { $JSONData  += @{url = "http://192.168.1.123/RSM/marquee/$($Media.Name)" ; type = "gecko_main_header"     }; break }
                "T"   { $JSONData  += @{url = "http://192.168.1.123/RSM/marquee/$($Media.Name)" ; type = "image"                 }; break }
                "GMB" { $JSONData  += @{url = "http://192.168.1.123/RSM/marquee/$($Media.Name)" ; type = "gecko_main_background" }; break }
                "GMH" { $JSONData  += @{url = "http://192.168.1.123/RSM/marquee/$($Media.Name)" ; type = "gecko_category_header" }; break }
            }
        }
    }

    $JSONData += @{url = "http://192.168.1.123/RSM/marquee/portrait.jpg"  ; type = "marketing_image" ; orientation = "portrait" }
    $JSONData += @{url = "http://192.168.1.123/RSM/marquee/landscape.jpg" ; type = "marketing_image" ; orientation = "landscape"}
    
    "Creating $JSONFile" | Out-File $Log1 -Append -Encoding ascii
    "Creating $JSONFile" | Out-File $Log2 -Append -Encoding ascii
    ConvertTo-Json $JSONData | Out-File $JSONFile -Encoding ascii
}

function Copy-JSON {
    param (
        $JSON,
        $Terminal
    )

    if($Terminal -like "*KIOSK*"){
        $Creds = New-Object System.Management.Automation.PSCredential("$Terminal\$KioskAdminUser", $($KioskAdminPass | ConvertTo-SecureString -AsPlainText -Force))
        New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\$Terminal\C$" -Credential $Creds
    }else{
        $Creds = New-Object System.Management.Automation.PSCredential("$Terminal\$POSAdminUser", $($POSAdminPass | ConvertTo-SecureString -AsPlainText -Force))
        New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\$Terminal\C$" -Credential $Creds
    }

    $JSON = $(Split-Path $JSON -Leaf)

    Write-Host "Copying $JSON to $Terminal"
    "Copying $JSON to $Terminal" | Out-File $Log1 -Append -Encoding ascii
    "Copying $JSON to $Terminal" | Out-File $Log2 -Append -Encoding ascii

    ROBOCOPY $PSScriptRoot "\\$Terminal\c$\inetpub\wwwroot\NCRKioskApp" $JSON /Z /R:2
    if(Test-Path "\\$Terminal\c$\inetpub\wwwroot\NCRKioskApp\marquee.old"){Remove-Item "\\$Terminal\c$\inetpub\wwwroot\NCRKioskApp\marquee.old"}
    Rename-Item "\\$Terminal\c$\inetpub\wwwroot\NCRKioskApp\marquee.json" -NewName "marquee.old" -Force
    Rename-Item "\\$Terminal\c$\inetpub\wwwroot\NCRKioskApp\$JSON" -NewName "marquee.json" -Force

    Write-Host "Rebooting $Terminal"
    "Rebooting $Terminal" | Out-File $Log1 -Append -Encoding ascii
    "Rebooting $Terminal" | Out-File $Log2 -Append -Encoding ascii
    
    shutdown /r /m \\$Terminal /t 0

    Remove-PSDrive -Name "Z"
}

switch ($env:COMPUTERNAME.Substring(0, 4)) {
    "MAIN" {
        "##########################################" | Out-File $Log1 -Append -Encoding ascii
        "##########################################" | Out-File $Log2 -Append -Encoding ascii
        "$ScriptName started at $(Get-Date) by $env:USERNAME" | Out-File $Log1 -Append -Encoding ascii
        "$ScriptName started at $(Get-Date) by $env:USERNAME" | Out-File $Log2 -Append -Encoding ascii
        "##########################################" | Out-File $Log1 -Append -Encoding ascii
        "##########################################" | Out-File $Log2 -Append -Encoding ascii

        $Unit = $env:COMPUTERNAME.Substring(4, 4)
        $CSV = Import-Csv $MasterCSV

        $JSONFile = "$PSScriptRoot\$Unit`.marquee.json"

        New-MediaJSON $Unit

        $Terminals = "$PSScriptRoot\..\..\terminal_list.txt"
        & "$PSScriptRoot\Get_Kiosk_Terminals.ps1"

        If($env:USERNAME -ne "$env:COMPUTERNAME`$"){
            Write-Output "************** Update Kiosk Banners *************"
            Write-Output "*    Enter the terminal IP address or hostname  *"
            Write-Output "*        in the window that will appear.        *"
            Write-Output "*       All kiosks will be auto-populated.      *"
            Write-Output "*        Enter in the following format:         *"
            Write-Output "*                 UUUUKIOSK-083                 *"
            Write-Output "*                 192.168.1.183                 *"
            Write-Output "*                                               *"
            Write-Output "*      then save and close Notepad window       *"
            Write-Output "*************************************************"

            Write-Output ""
            Write-Output "Kiosks listed in the notepad window will reboot and have the kiosk banner updated."
            Write-Output ""

            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

            Notepad.exe $Terminals | out-null
        
            $Terminals = Get-Content $Terminals
        }

        foreach ($Terminal in $Terminals) {
            Write-Host "Testing connection to $Terminal"
            $TerminalOnline = Test-Connection -Computername $Terminal -BufferSize 16 -Count 1 -Quiet
        
            If ($TerminalOnline -eq $True){
                Copy-JSON $JSONFile $Terminal
            }else{
                Write-Host "$Terminal is offline" -ForegroundColor Red
            }
        }

        "##########################################" | Out-File $Log1 -Append -Encoding ascii
        "##########################################" | Out-File $Log2 -Append -Encoding ascii
        "$ScriptName completed at $(Get-Date)" | Out-File $Log1 -Append -Encoding ascii
        "$ScriptName completed at $(Get-Date)" | Out-File $Log2 -Append -Encoding ascii
        "##########################################" | Out-File $Log1 -Append -Encoding ascii
        "##########################################" | Out-File $Log2 -Append -Encoding ascii
        
        break
    }
    default {
        do {
            Clear-Host
            $Option = 0
            Write-Host "Please choose an option."
            Write-Host "1. Convert XLSX to CSV"
            Write-Host "2. Generate JSONs for 1 site"
            Write-Host "3. Generate JSONs for all sites"
            Write-Host "4. Exit script"
            $Option = Read-Host "Enter choice"
        
            switch ($Option) {
                "1" {
                    #Convert xlsx to csv
                    Import-Module -Name ImportExcel
                    $MasterXLSX = Get-ChildItem "$PSScriptRoot\*.*" -include *.xlsx | Out-GridView -OutputMode Single -Title "Choose file to process and click OK"
                    Write-Host "Converting $(Split-Path $MasterXLSX -Leaf) to $(Split-Path $MasterCSV -Leaf)"
                    $Master = Import-Excel -Path $MasterXLSX -WorksheetName $SheetName
                    $Master | Export-Csv -Path $MasterCSV -NoTypeInformation
                }
                "2" {
                    $CSV = Import-Csv $MasterCSV
                    $Unit = Read-Host "Enter unit#"
                    $JSONFile = "$PSScriptRoot\$Unit`.marquee.json"
                    New-MediaJSON $Unit
                }
                "3" {
                    $CSV = Import-Csv $MasterCSV
                    foreach ($Site in $CSV) {
                        $Unit = $Site.Unit
                        $JSONFile = "$PSScriptRoot\$Unit`.marquee.json"
                        New-MediaJSON $Unit
                    }
                }
            }
        }While ($Option -ne 4)
        break
    }
}

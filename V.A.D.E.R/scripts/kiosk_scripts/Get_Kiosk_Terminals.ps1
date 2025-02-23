$Terminal_List = "$PSScriptRoot\..\..\terminal_list.txt"

function Get-TerminalByType {
    param (
        $Type
    )
    <#
    Available types
    -------------------
    ALL
    BAR
    BOX
    CONC
    DUAL
    KIOSK
    #>

    $Query = "
        SET NOCOUNT ON
        SELECT terminal_name
        FROM esp_term_config 
        WHERE timestamp = (
            SELECT MAX(timestamp) 
            FROM esp_term_config
        )
        AND terminal_name NOT LIKE '%admin%'
    "

    $AllTerminals = sqlcmd -E -d "esocketpos" -Q $Query -h-1
    $AllTerminals = $AllTerminals.Trim()

    switch ($Type) {
        "ALL"   {$FilteredTerminals = $AllTerminals                                    }
        "BAR"   {$FilteredTerminals = $AllTerminals | Where-Object{$_ -like "*BAR*"}   }
        "BOX"   {$FilteredTerminals = $AllTerminals | Where-Object{$_ -like "*BOX*"}   }
        "CONC"  {$FilteredTerminals = $AllTerminals | Where-Object{$_ -like "*CONC*"}  }
        "DUAL"  {$FilteredTerminals = $AllTerminals | Where-Object{$_ -like "*DUAL*"}  }
        "KIOSK" {$FilteredTerminals = $AllTerminals | Where-Object{$_ -like "*KIOSK*"} }
        Default {$FilteredTerminals = $AllTerminals                                    }
    }

    return $FilteredTerminals
}

Clear-Host

$Terminals = Get-TerminalByType "KIOSK"
$Terminals | Out-File $Terminal_List -Encoding ascii
$PEDs = (
    "IPP320",
    "IPP320V23",
    "ISC250",
    "ISC250V23",
    "IUP250",
    "IWL250",
    "IWL250V23",
    "LANE3000",
    "MOVE5000"
)

Get-ChildItem (Get-ChildItem "C:\postilion\eSocket.POS\" -Directory -Recurse -Include $PEDs) -File -Recurse | Remove-Item -Force

"PED Media Files removed on $(Get-Date) $(Get-Date -Format 'HH:mm:ss'): " | Out-File -Append -FilePath "$PSScriptRoot\PED_Files.log"

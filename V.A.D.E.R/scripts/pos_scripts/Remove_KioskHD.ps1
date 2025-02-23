Stop-Process -name NExRmCL -force

$NCRapps = 'NCRCreditConnector',
'NCR.CreditConnector',
'NCR.Templating.Engine',
'NCR Templating Engine',
'NcrKioskService',
'NCRKioskApp',
'NcrCashMachineService',
'AmcKioskElectron',
'KioskWebApiService',
'AmcKioskBundle*'

$UninstallKeys = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
                   'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall')
$uninstallKeys = foreach ($key in (Get-ChildItem $UninstallKeys) ) {

    foreach ($product in $NCRapps) {
        if ($key.GetValue("DisplayName") -like "$product") {
            [pscustomobject]@{
                KeyName = $key.Name.split('\')[-1];
                DisplayName = $key.GetValue("DisplayName");
                UninstallString = $key.GetValue("UninstallString");
                Publisher = $key.GetValue("Publisher");
            }
        }
    }
}

Get-Process -Name NcrKiosk.Service -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

foreach ($key in $uninstallkeys) {
    $uninstallString = $key.UninstallString
        if ($uninstallString.StartsWith('MsiExec.exe')) {
            $uninstallString = $uninstallString.replace('/I','/X') + ' /qb- /quiet /passive /norestart'
        } else {
            $uninstallString += ' /quiet /silent'
        }
    Write-Output "Uninstalling $($key.DisplayName)"
    & cmd /c $uninstallString
}

Remove-Item "C:\Program Files\NCR\AmcKioskElectron" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files\NCR\NCR Templating Engine" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files\NCR\NCRCreditConnector" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files\NCR\NcrCashMachineService" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files\NCR\NcrCashMachineServiceProxy" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files\NCR\NcrKioskService" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files\NCR\AMCKioskMonitorService" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files\NCR\AMCKioskMonitorServiceProxy" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files\NCR\KioskWebApiService" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\inetpub\wwwroot\NCRKioskApp" -Recurse -Force -ErrorAction SilentlyContinue

Remove-Item "C:\Program Files (x86)\NCR\AmcKioskElectron" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files (x86)\NCR\NCR Templating Engine" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files (x86)\NCR\NCRCreditConnector" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files (x86)\NCR\NcrCashMachineService" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files (x86)\NCR\NcrCashMachineServiceProxy" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files (x86)\NCR\NcrKioskService" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files (x86)\NCR\AMCKioskMonitorService" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files (x86)\NCR\AMCKioskMonitorServiceProxy" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files (x86)\NCR\KioskWebApiService" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\inetpub\wwwroot\NCRKioskApp" -Recurse -Force -ErrorAction SilentlyContinue

Remove-Item "C:\ProgramData\NCR\AmcKiosk" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\ProgramData\NCR\CashMachineService" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\ProgramData\NCR\KioskBundleInstallation" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\ProgramData\NCR\NcrKioskService" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\ProgramData\NCR\NcrTemplatingEngineImages" -Recurse -Force -ErrorAction SilentlyContinue

Remove-Item "C:\CreditConnector" -Recurse -Force -ErrorAction SilentlyContinue

$path = "C:\ProgramData\Package Cache"
$folder = Get-ChildItem -Path $path -filter "AmcKioskBundle*" -Recurse -ErrorAction SilentlyContinue -Force | Select-Object -First 1
if ($folder) {$folder.PSParentPath | Remove-Item -Recurse}

try {(Get-WmiObject -Class Win32_Service -Filter "Name='NCRCreditConnector'").delete()} catch{}

$prod = Get-ChildItem HKLM:\SOFTWARE\Classes\Installer\Products | % {$key = $_.Name; Get-ItemProperty -Path Registry::$($Key) | Where-Object {$_.ProductName -like 'NCRCreditConnector'} | Select-Object -ExpandProperty PSChildName}

if($prod) {
    Get-Item Registry::HKEY_CLASSES_ROOT\Installer\Products\$prod -ErrorAction SilentlyContinue | Remove-Item -Recurse
    Get-Item Registry::HKEY_CLASSES_ROOT\Installer\Features\$prod -ErrorAction SilentlyContinue | Remove-Item -Recurse
    Get-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$prod -ErrorAction SilentlyContinue | Remove-Item -Recurse
    Get-Item HKLM:\SOFTWARE\Classes\Installer\Products\$prod -ErrorAction SilentlyContinue | Remove-Item -Recurse
}

$prod = "39D79F47A758CDC4694D3CF170F864D2"
if($prod) {
    Get-Item Registry::HKEY_CLASSES_ROOT\Installer\Products\$prod -ErrorAction SilentlyContinue | Remove-Item -Recurse
    Get-Item Registry::HKEY_CLASSES_ROOT\Installer\Features\$prod -ErrorAction SilentlyContinue | Remove-Item -Recurse
    Get-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$prod -ErrorAction SilentlyContinue | Remove-Item -Recurse
    Get-Item HKLM:\SOFTWARE\Classes\Installer\Products\$prod -ErrorAction SilentlyContinue | Remove-Item -Recurse
}

$dep = Get-ChildItem HKLM:\SOFTWARE\Classes\Installer\Dependencies | % {$key = $_.Name; Get-ItemProperty -Path Registry::$($Key) | Where-Object {$_.DisplayName -like 'creditconnector'} | Select-Object -ExpandProperty PSChildName}

if($dep) {
    Get-Item HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$dep -ErrorAction SilentlyContinue | Remove-Item -Recurse
    Get-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$dep -ErrorAction SilentlyContinue | Remove-Item -Recurse
}

$nm = 'NCRCreditConnector'

Get-Item HKLM:\SYSTEM\ControlSet001\Services\EventLog\Application\$nm -ErrorAction SilentlyContinue | Remove-Item -Recurse
Get-Item HKLM:\SYSTEM\ControlSet001\Services\$nm -ErrorAction SilentlyContinue | Remove-Item -Recurse
Get-Item HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application\$nm -ErrorAction SilentlyContinue | Remove-Item -Recurse
Get-Item HKLM:\SYSTEM\CurrentControlSet\Services\$nm -ErrorAction SilentlyContinue | Remove-Item -Recurse
Get-Item HKLM:\SYSTEM\Setup\FirstBoot\Services\$nm -ErrorAction SilentlyContinue | Remove-Item -Recurse

$bundle = Get-ChildItem HKLM:\SOFTWARE\Classes\Installer\Dependencies | % {$key = $_.Name; Get-ItemProperty -Path Registry::$($Key) | Where-Object {$_.DisplayName -like 'AmcKioskBundle*'} | Select-Object -ExpandProperty PSChildName}

if($bundle) {
    Get-Item Registry::HKEY_CLASSES_ROOT\Installer\Products\$bundle -ErrorAction SilentlyContinue | Remove-Item -Recurse
    Get-Item HKLM:\SOFTWARE\Classes\Installer\Dependencies\$bundle -ErrorAction SilentlyContinue | Remove-Item -Recurse
    Get-Item HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$bundle -ErrorAction SilentlyContinue | Remove-Item -Recurse
    Get-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$bundle -ErrorAction SilentlyContinue | Remove-Item -Recurse
}
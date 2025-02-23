@echo off

setlocal EnableExtensions 
setlocal EnableDelayedExpansion

cls

echo *** Restart Bridge ^& Credit Connector On POS  ***
echo *    Enter the terminal IP address or hostname  *
echo *        in the window that will appear.        *
echo *       All POS's will be auto-populated.       *
echo *        Enter in the following format:         *
echo *                  BOXUUUU-001                  *
echo *                  192.168.1.1                  *
echo *                                               *
echo *      then save and close Notepad window       *
echo *************************************************
echo.

echo POS's listed in the notepad window will restart the Ingenico Bridge & Credit Connector services.
echo.

pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\Get_POS_Terminals.ps1"
notepad terminal_list.txt

for /f %%i in (terminal_list.txt) do (
    echo.
    echo Restarting the Ingenico Bridge service on %%i ...
    psexec \\%%i /accepteula /u admin /p Redacted Powershell -ExecutionPolicy Bypass Restart-Service -Name IngenicoBridge -Force
    echo.
    echo Restarting the Credit Connector service on %%i ...
    psexec \\%%i /accepteula /u admin /p Redacted Powershell -ExecutionPolicy Bypass Restart-Service -Name NCRCreditConnector -Force
    echo.
)

pause

:EOF
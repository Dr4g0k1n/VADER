@echo off

setlocal EnableExtensions 
setlocal EnableDelayedExpansion

cls

echo ********** Toggle Kiosk Service On POS **********
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

echo POS's listed in the notepad window will toggle the Kiosk Service on or off.
echo.

pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\Get_POS_Terminals.ps1"
notepad terminal_list.txt

for /f %%i in (terminal_list.txt) do (
    psexec \\%%i /accepteula /u admin /p Redacted cmd /c sc query NcrKioskService | find "RUNNING" > nul
    if !errorlevel! equ 0 (
        psexec \\%%i /accepteula /u admin /p Redacted cmd /c net stop NcrKioskService
        echo NCR Kiosk Service has been stopped on %%i
    ) else (
        psexec \\%%i /accepteula /u admin /p Redacted cmd /c net start NcrKioskService
        echo NCR Kiosk Service has been started on %%i
    )
)

pause

:EOF
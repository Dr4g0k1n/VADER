@echo off
setlocal EnableExtensions 
setlocal EnableDelayedExpansion

cls

echo ************* Open Crewlink Error Logs ************
echo *     Enter the terminal IP address or hostname   *
echo *         in the window that will appear.         *
echo *        All POS's will be auto-populated.        *
echo *         Enter in the following format:          *
echo *                   BOXUUUU-001                   *
echo *                   192.168.1.1                   *
echo *                                                 *
echo *       then save and close Notepad window        *
echo ***************************************************
echo.

echo File explorer will open the log directory on the POS's listed in the notepad window.
echo.
echo Log files ending in 000 through 005 should be present.  Where you see a roll back is where the error will be.
echo Presence of a rollback file will tell you where the kioskbundle failed to install. 
echo.

pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\Get_POS_Terminals.ps1"
set "terminals=%~dp0\..\..\terminal_list.txt"
notepad "%terminals%"

for /f %%i in (%terminals%) do (
    net use \\%%i\c$ /user:admin Redacted
    if exist "\\%%i\c$\ProgramData\NCR\KioskBundleInstallation" (
        explorer "\\%%i\c$\ProgramData\NCR\KioskBundleInstallation"
    ) else (
        echo No log files were found for %%i, there is a deeper issue at play.
        echo It is likely that Kiosk Bundle is not installed.
        echo.
        pause
    )
    timeout /t 2 > nul
    net use \\%%i\c$ /delete
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\Fix_Crewlink_Install.ps1"

pause

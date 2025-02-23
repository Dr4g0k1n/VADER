@echo off

setlocal EnableExtensions 
setlocal EnableDelayedExpansion

cls

echo ************ Open Kiosk File Transfer ***********
echo *    Enter the terminal IP address or hostname  *
echo *        in the window that will appear.        *
echo *       All kiosks will be auto-populated.      *
echo *        Enter in the following format:         *
echo *                 UUUUKIOSK-083                 *
echo *                 192.168.1.183                 *
echo *                                               *
echo *      then save and close Notepad window       *
echo *************************************************
echo.

echo Explorer will open a window to the Kiosks listed in the notepad window.
echo.

pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\Get_Kiosk_Terminals.ps1"
set "terminals=%~dp0\..\..\terminal_list.txt"
notepad "%terminals%"

for /f %%i in (%terminals%) do (
    net use \\%%i\c$ /user:administrator Redacted
    explorer "\\%%i\c$"
    timeout /t 2 > nul
    net use \\%%i\c$ /delete
)

:EOF
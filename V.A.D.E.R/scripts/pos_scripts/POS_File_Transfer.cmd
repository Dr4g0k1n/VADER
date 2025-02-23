@echo off

setlocal EnableExtensions 
setlocal EnableDelayedExpansion

cls

echo ************* Open POS File Transfer ************
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

echo Explorer will open a window to the POS's listed in the notepad window.
echo.

pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\Get_POS_Terminals.ps1"
set "terminals=%~dp0\..\..\terminal_list.txt"
notepad "%terminals%"

for /f %%i in (%terminals%) do (
    net use \\%%i\c$ /user:admin Redacted
    explorer "\\%%i\c$"
    timeout /t 2 > nul
    net use \\%%i\c$ /delete
)

:EOF
@echo off

setlocal EnableExtensions 
setlocal EnableDelayedExpansion

cls

echo ************ Set POS Extended Display ***********
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

pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\Get_POS_Terminals.ps1"
notepad terminal_list.txt

for /f %%i in (terminal_list.txt) do (
    set "monitorCount=0"
    for /f %%a in ('psexec \\%%i /accepteula /u admin /p Redacted wmic desktopmonitor get DeviceID ^| find /c /v ""') do set "monitorCount=%%a"
    echo Monitor count on %%i: !monitorCount!
    echo.

    if !monitorCount! equ 2 (
        psexec \\%%i /accepteula /u admin /p Redacted DisplaySwitch.exe /extend
        echo Monitors on %%i have been set to extended mode.
    ) else if !monitorCount! equ 3 (
        echo This POS has an external guest-facing monitor. This is currently unsupported, and no action has been taken
    ) else (
        echo %%i has an unsupported monitor configuration. No action taken.
    )
)

echo.
pause

:EOF
@echo off

setlocal EnableExtensions 
setlocal EnableDelayedExpansion
set "terminals=terminal_list.txt"
set "report=%~dp0\..\..\Kiosk_OS_Version_Report.txt"
del %report%

cls

echo ************* Kiosk OS Version Check ************
echo *    Enter the terminal IP address or hostname  *
echo *        in the window that will appear.        *
echo *       All POS's will be auto-populated.       *
echo *        Enter in the following format:         *
echo *                 UUUUKIOSK-083                 *
echo *                  192.168.1.1                  *
echo *                                               *
echo *      then save and close Notepad window       *
echo *************************************************
echo.

echo This script will return the Windows version (Win7/Win10) of KIOSKS ONLY. This will not work on POS.
echo.
echo The scan may take a while to finish. Once complete, a notepad window will pop up with the results of the scan.
echo.
pause

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\Get_KIOSK_Terminals.ps1"
notepad "%terminals%"

rem Get current date and time
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "datetime=%%a"
set "datestamp=!datetime:~4,2!-!datetime:~6,2!-!datetime:~0,4!"
set "timestamp=!datetime:~8,2!:!datetime:~10,2!:!datetime:~12,2!"

rem Write date and time stamp to report file
echo KIOSK OS version report generated on %datestamp% at %timestamp% ^| > "%report%"
echo ------------------------------------------------------------ >> "%report%"
echo. >> "%report%"
echo. >> "%report%"

for /f %%i in (%terminals%) do (
    echo Processing terminal: %%i
    echo Processing terminal: %%i >> %report%
    echo.
    echo. >> %report%
    ping %%i -n 1 | find "TTL=" > nul
    if errorlevel 1 (
        echo %%i is offline
        echo %%i is offline >> %report%
        echo.
        echo. >> %report%
        echo -------------------------------------
        echo ------------------------------------- >> %report%
        echo.
        echo. >> %report%
    )

    (
        for /f "tokens=2 delims==" %%V in ('psexec \\%%i /accepteula /u administrator /p Redacted wmic os get Version /value 2^>nul ^| find "Version"') do (
            set "Ver=%%V"
            if "!Ver:~0,2!" equ "6." (
                echo %%i is running Windows 7
                echo %%i is running Windows 7 >> %report%
                echo Windows Version: !Ver!
                echo Windows Version: !Ver! >> %report%
            ) else if "!Ver:~0,5!" equ "10.0." (
                echo %%i is running Windows 10
                echo %%i is running Windows 10 >> %report%
                echo Windows Version: !Ver!
                echo Windows Version: !Ver! >> %report%
            ) else (
                echo %%i is running an unknown Windows flavor
                echo %%i is running an unknown Windows flavor >> %report%
                echo Windows Version: !Ver!
                echo Windows Version: !Ver! >> %report%
            )
            echo.
            echo. >> %report%
            echo -------------------------------------
            echo ------------------------------------- >> %report%
            echo.
            echo. >> %report%
        )
    )
)

echo Scan complete. The results will be displayed in a notepad window
pause
notepad "%report%"
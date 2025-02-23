@echo off
cls

rem *** Version 2.0, 8/20/2023, Created by DLetts ***

setlocal EnableExtensions 
setlocal EnableDelayedExpansion

rem ************ Determine IP address of POS ************

echo ************ Remove Crewlink From POS ***********
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

echo POS's listed in the notepad window will have KioskHD removed.
echo.

pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\Get_POS_Terminals.ps1"
set "terminals=%~dp0\..\..\terminal_list.txt"
notepad "%terminals%"
cls

echo ******************* Remove Crewlink From POS *****************
echo * Kiosk Bundle                                     - Enter 1 *
echo * Kiosk Bundle (WITH POS REBOOT)                   - Enter 2 *
echo * Kiosk Bundle AND Kiosk Monitor                   - Enter 3 *
echo * Kiosk Bundle AND Kiosk Monitor (WITH POS REBOOT) - Enter 4 *
echo **************************************************************
echo.

:CHOICES
set /p AC=Enter 1, 2, 3, or 4 then press ENTER: 

if %AC% == 1 goto BUNDLE
if %AC% == 2 goto BUNDLE_REBOOT
if %AC% == 3 goto MONITOR
if %AC% == 4 goto MONITOR_REBOOT

echo Please Enter a valid Selection.
goto CHOICES

:BUNDLE
call :CopyAndRunFiles "Remove_KioskHD.ps1"
goto END

:BUNDLE_REBOOT
call :CopyAndRunFiles "Remove_KioskHD.ps1"
for /f %%i in (%terminals%) do (
    echo Rebooting %%i...
    psexec \\%%i /accepteula /u admin /p Redacted cmd /c shutdown /r /t 5
)
goto END

:MONITOR
call :CopyAndRunFiles "Remove_KioskHD_And_Monitor.ps1"
goto END

:MONITOR_REBOOT
call :CopyAndRunFiles "Remove_KioskHD_And_Monitor.ps1"
for /f %%i in (%terminals%) do (
    echo Rebooting %%i...
    psexec \\%%i /accepteula /u admin /p Redacted cmd /c shutdown /r /t 5
)
goto END

:CopyAndRunFiles
set "script=%~1"
rem ************** Copy File To POS ***************
for /f %%i in (%terminals%) do (
    echo Copying %script% to %%i...
    net use \\%%i\c$ /user:admin Redacted
    robocopy "%~dp0\" "\\%%i\C$\Staging" %script% /e /r:0 /w:0 /np

rem ************** Execute Script *****************
    echo Running %script% on %%i...
    psexec \\%%i /accepteula /u admin /p Redacted Powershell -ExecutionPolicy Bypass -File "C:\Staging\%script%"

rem *********** Delete Script From POS ************
    echo Deleting %script% from %%i...
    psexec \\%%i /accepteula /u admin /p Redacted cmd /c del "C:\Staging\%script%"
)

:END
pause
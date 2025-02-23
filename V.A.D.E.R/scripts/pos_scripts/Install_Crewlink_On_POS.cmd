cls

::
:: Script to Copy and Install CrewLink BOX/CONC Monitoring Service onto POS 
::

COLOR 1F
@ECHO OFF
CLS

SETLOCAL EnableExtensions 
SETLOCAL EnableDelayedExpansion

::::::::::::::::::::::::::::::::::::::::::::::::::
:: set up date and time stamp used for folder naming

SET yy=%DATE:~-4,4%
SET mm=%DATE:~-10,2%
SET dd=%DATE:~-7,2%

:: Set the hour stamp; add leading zero before 10am

SET hh=%time:~0,2%
IF "%time:~0,1%"==" " SET hh=0%hh:~1,1%

:: name the folder to store the logs, check to include previous day logs

SET BD=%mm%/%dd%/%yy%
SET LogPath=%yy%%mm%%dd%_%hh%%time:~3,2%

:::::::::::::::::::::::::::::::::::::::::::::::::::
:: define log path

SET logfile=logs\DeployToPOS_%LogPath%.log

SET FOLDER=C:\Staging\_UUUUconfig_PRIVATE

:::::::::::::::::::::::::::::::::::::::::::::::::::
::Set CrewLink Monitoring Service Build Verion

rem Extract CrewLink version number from "C:\Staging\_UUUUconfig_PRIVATE\CrewLink_0.Deploy&InstallOnPOS.cmd" and store the value
for /F "tokens=1,* delims==" %%a in ('findstr /b "set CrewLink=" "C:\Staging\_UUUUconfig_PRIVATE\CrewLink_0.Deploy&InstallOnPOS.cmd"') do set "CrewLink_value=%%b"

set CrewLink=%CrewLink_value%

:::::::::::::::::::::::::::::::::::::::::::::::::::

rem ECHO %date% %time% STARTING SCRIPT... 
ECHO %date% %time% STARTING SCRIPT... >> %FOLDER%\%logfile%

:::::::::::::::::::::::::::::::::::::::::::::::::::
::Determine IP address of POS on site

ECHO ************ Install Crewlink On POS ************
ECHO *    Enter the terminal IP address or hostname  *
ECHO *        in the window that will appear.        *
ECHO *       All POS's will be auto-populated.       *
ECHO *        Enter in the following format:         *
ECHO *                  BOXUUUU-001                  *
ECHO *                  192.168.1.1                  *
ECHO *                                               *
ECHO *      then save and close Notepad window       *
ECHO *************************************************

ECHO.
ECHO Crewlink will be pushed out to the POS listed in the notepad window. This will install %CrewLink%
ECHO.

pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\Get_POS_Terminals.ps1"
set "terminals=%~dp0\..\..\terminal_list.txt"
notepad "%terminals%"
copy /y "%terminals%" "%FOLDER%\manual_pos.txt"

cd\
cd %FOLDER%

:::::::::::::::::::::::::::::::::::::::::::::::::::
:XFER

ECHO %date% %time% Copy files to POS Terminals >> %FOLDER%\%logfile%

net use z: /delete
for /f %%a in (%FOLDER%\manual_pos.txt) do (
	ECHO !date! !time! Connecting to %%a
	ECHO !date! !time! Connecting to %%a >> %FOLDER%\%logfile%

	:: pre-clean incase the script stopped for some reason.
	IF EXIST "C:\Staging\_UUUUconfig_PRIVATE\set_pc_datetime.cmd" (DEL "C:\Staging\_UUUUconfig_PRIVATE\set_pc_datetime.cmd" )

	:: Get the local Timezone
	for /f "tokens=*" %%i in ('TZUTIL /g') do ( set _timezone=%%i )

	:: Get the local Date 
	for /F "tokens=2" %%i in ('date /t') do ( set _date=%%i )

	:: Set the current time as of right now.
	for /f "tokens=*" %%i IN ('TIME /T') do ( set _time=%%i	)
	
	:: Write out our scipt that we will run on the remote machines.
	echo TZUTIL /s "!_timezone!" > %FOLDER%\set_pc_datetime.cmd

	:: Write out the current time.
	echo TIME !_time! >> %FOLDER%\set_pc_datetime.cmd

	:: Write out the current date.
	echo DATE !_date! >> %FOLDER%\set_pc_datetime.cmd

	:: Copy software and shortcuts to desktop
	net use z: \\%%a\c$ /user:admin Redacted
	ECHO F| xcopy /D /E /V /I /Y /F "C:\Staging\_UUUUconfig_PRIVATE\%CrewLink%" "Z:\Staging\%CrewLink%" >> %FOLDER%\%logfile%
	ECHO F| xcopy /D /E /V /I /Y /F "C:\Staging\_UUUUconfig_PRIVATE\POS_Shortcuts\AMC Kiosk Associate.lnk" "Z:\Users\posuser\Desktop\AMC Kiosk Associate.lnk" >> %FOLDER%\%logfile%

	:: Copy the newly created script to the workstation.
	xcopy "C:\Staging\_UUUUconfig_PRIVATE\set_pc_datetime.cmd" "Z:\Staging" /y

	:: Run the script on the workstation (PUSH)
	PSEXEC \\%%a -accepteula -d -u admin -p Redacted C:\Staging\set_pc_datetime.cmd -w C:\Staging

	:: Clean up file
	PSEXEC \\%%a -accepteula -d -u admin -p Redacted cmd /c DEL "C:\Staging\set_pc_datetime.cmd"

	:: Install software
	ECHO.Installing Kiosk Monitoring Service	
	PSEXEC \\%%a -accepteula -d -u admin -p Redacted -s -v -c %FOLDER%\%CrewLink% >> %FOLDER%\%logfile%

	:: Reboot System in 5 minutes, should be enough time for software to install
	ECHO.Rebooting System in 5 Minutes
	PSEXEC \\%%a -accepteula -d -u admin -p Redacted cmd /c shutdown /r /t 300

	net use z: /delete /y
	timeout /t 2	
)

:: Clean up file
DEL "C:\Staging\_UUUUconfig_PRIVATE\set_pc_datetime.cmd"

:::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copy UltraVNC KIOSK Shortcuts to MAINUUUU Desktop
:: DEL /F /Q /S "c:\users\public\Desktop\AMC POS"
:: RMDIR /Q /S "c:\users\public\Desktop\AMC POS"
:: xcopy /S /E /F /Y ".\KioskShortcuts\MAINUUUU" "c:\users\public\Desktop"

:::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copy UltraVNC POS Shortcuts to MAINUUUU Desktop
:: DEL /F /Q /S "c:\users\public\Desktop\AMC POS"
:: RMDIR /Q /S "c:\users\public\Desktop\AMC POS"
:: START /WAIT C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy bypass -File C:\Staging\_UUUUconfig_PRIVATE\CrewLink_Create-VNCShortcuts.ps1

:::::::::::::::::::::::::::::::::::::::::::::::::::
:done

ECHO %date% %time% ENDING SCRIPT... 
ECHO %date% %time% ENDING SCRIPT... >> %FOLDER%\%logfile%
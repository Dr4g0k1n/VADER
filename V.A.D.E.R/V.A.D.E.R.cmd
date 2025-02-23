@ECHO OFF
rem ****** Created by David Letts ******
rem ****** v1.0 12/13/2023 ******
rem ***** v1.1 - 01/26/2024 *****
rem **** v1.1.1 - 01/29/2024 ****
rem **** v1.2 - 05/07/2024 ****

setlocal EnableExtensions 
setlocal EnableDelayedExpansion

COLOR 1F

title V.A.D.E.R. v1.2 - "Virtual Assistant for Deployments, Executions, and Remote support"
rem title A.N.A.K.I.N. v1.2 - "Automated Node Assistance for Key IT Needs"

:MAIN_MENU
cls
title V.A.D.E.R. v1.2 - "Virtual Assistant for Deployments, Executions, and Remote support"

echo Welcome to Your Virtual Assistant for Deployments, Executions, and Remote support
echo V.A.D.E.R. v1.2 - Created by David Letts
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0\Banner_Message.ps1"
echo.

echo ******************** Main Menu **********************
echo * POS Tools                               - Enter 1 *
echo * Kiosk Tools                             - Enter 2 *
echo * Pin Pad Tools                           - Enter 3 *
echo * Server Tools                            - Enter 4 *
echo * Documentation                           - Enter 5 *
echo * Kill V.A.D.E.R.                         - Enter 6 *
echo *****************************************************
echo.

:MAIN_CHOICES
SET /P MC=Enter a number (1, 2, 3...), then press ENTER: 

if %MC% ==1 goto POS_MENU
if %MC% ==2 goto KIOSK_MENU
if %MC% ==3 goto PED_MENU
if %MC% ==4 goto SERVER_MENU
if %MC% ==5 goto DOCUMENTATION
if %MC% ==6 goto END

echo Please Enter a valid Selection.
echo.
goto MAIN_CHOICES

:POS_MENU
cls
title V.A.D.E.R. v1.2 - "Virtual Assistant for Deployments, Executions, and Remote support"

echo Welcome to Your Virtual Assistant for Deployments, Executions, and Remote support
echo V.A.D.E.R. v1.2 - Created by David Letts
echo.

echo ******************** POS Menu ***********************
echo * Launch RSWATCH                          - Enter 1 *
echo * Launch Recursive Ping                   - Enter 2 *
echo * Reboot Terminals                        - Enter 3 *
echo * Reset POS Auto Login                    - Enter 4 *
echo * Install Crewlink on POS                 - Enter 5 *
echo * Remove Crewlink from POS                - Enter 6 *
echo * Fix Crewlink Installation Errors        - Enter 7 *
echo * Get Bundle/Monitor Versions             - Enter 8 *
echo * Get POS OS Version Report               - Enter 9 *
echo * Set POS Extended Display (Unavailable) - Enter 10 *
echo * Open File Transfer to POS              - Enter 11 *
echo * Restart Services on POS                - Enter 12 *
echo * Back to Main Menu                      - Enter 13 *
echo *****************************************************
echo.

:POS_CHOICES
SET /P PC=Enter a number (1, 2, 3...), then press ENTER: 

if %PC% ==1 goto RSWATCH
if %PC% ==2 goto RECURSIVE_PING_POS
if %PC% ==3 goto REBOOT_POS_TERMINALS
if %PC% ==4 goto RESET_POS_AUTO_LOGIN
if %PC% ==5 goto INSTALL_CREWLINK_POS
if %PC% ==6 goto REMOVE_CREWLINK_POS
if %PC% ==7 goto FIX_CREWLINK_ERRORS
if %PC% ==8 goto GET_POS_BUNDLE_VERSIONS
if %PC% ==9 goto GET_POS_OS_REPORT
rem if %PC% ==10 goto SET_POS_DISPLAY
if %PC% ==11 goto POS_FILE_TRANSFER
if %PC% ==12 goto POS_SERVICES_MENU
if %PC% ==13 goto MAIN_MENU

echo Please Enter a valid Selection.
echo.
goto POS_CHOICES

:RSWATCH
start "RSWATCH" cmd /c rswatch
goto POS_MENU

:RECURSIVE_PING_POS
echo.
SET /P RPP=Enter an IP address, then press ENTER to launch the recursive ping: 
start "Recursive Ping to %RPP%" cmd /c ping %RPP% -t
goto POS_MENU

:REBOOT_POS_TERMINALS
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\pos_scripts\Reboot_POS_Terminals.ps1"
goto POS_MENU

:RESET_POS_AUTO_LOGIN
call "%~dp0\scripts\pos_scripts\Reset_POS_Auto_Login.cmd"
goto POS_MENU

:INSTALL_CREWLINK_POS
call "%~dp0\scripts\pos_scripts\Install_Crewlink_On_POS.cmd"
goto POS_MENU

:REMOVE_CREWLINK_POS
call "%~dp0\scripts\pos_scripts\Remove_Crewlink_POS.cmd"
goto POS_MENU

:FIX_CREWLINK_ERRORS
call "%~dp0\scripts\pos_scripts\Open_Crewlink_Error_Log.cmd"
goto POS_MENU

:GET_POS_BUNDLE_VERSIONS
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\pos_scripts\Get_POS_Terminal_Versions.ps1"
goto POS_MENU

:GET_POS_OS_REPORT
call "%~dp0\scripts\pos_scripts\POS_OS_Version_Check.cmd"
goto POS_MENU

:SET_POS_DISPLAY
call "%~dp0\scripts\pos_scripts\Set_POS_Extended_Display.cmd"
goto POS_MENU

:POS_FILE_TRANSFER
call "%~dp0\scripts\pos_scripts\POS_File_Transfer.cmd"
goto POS_MENU

:POS_SERVICES_MENU
cls
title V.A.D.E.R. v1.2 - "Virtual Assistant for Deployments, Executions, and Remote support"

echo Welcome to Your Virtual Assistant for Deployments, Executions, and Remote support
echo V.A.D.E.R. v1.2 - Created by David Letts
echo.

echo ********************* POS Services Menu ***********************
echo * Restart Ingenico Bridge ^& Credit Connector on POS - Enter 1 *
echo * Restart TeleQ ^& Radio Host Services on POS        - Enter 2 *
echo * Toggle Kiosk Service ON/OFF on POS                - Enter 3 *
echo * Back to POS Menu                                  - Enter 4 *
echo * Back to Main Menu                                 - Enter 5 *
echo ***************************************************************
echo.

:POS_SERVICES_CHOICES
SET /P PSC=Enter a number (1, 2, 3...), then press ENTER: 

if %PSC% ==1 goto BRIDGE_CREDIT
if %PSC% ==2 goto TELEQ_RADIO
if %PSC% ==3 goto POS_KIOSK_SERVICE
if %PSC% ==4 goto POS_MENU
if %PSC% ==5 goto MAIN_MENU

echo Please Enter a valid Selection.
echo.
goto POS_SERVICES_CHOICES

:BRIDGE_CREDIT
call "%~dp0\scripts\pos_scripts\Restart_Credit_Bridge_On_POS.cmd"
goto POS_SERVICES_MENU

:TELEQ_RADIO
call "%~dp0\scripts\pos_scripts\Restart_TeleQ_Radio_On_POS.cmd"
goto POS_SERVICES_MENU

:POS_KIOSK_SERVICE
call "%~dp0\scripts\pos_scripts\Toggle_Kiosk_Service_On_POS.cmd"
goto POS_SERVICES_MENU

echo Please Enter a valid Selection.
goto POS_SERVER_CHOICES

:KIOSK_MENU
cls
title V.A.D.E.R. v1.2 - "Virtual Assistant for Deployments, Executions, and Remote support"

echo Welcome to Your Virtual Assistant for Deployments, Executions, and Remote support
echo V.A.D.E.R. v1.2 - Created by David Letts
echo.

echo ******************** KIOSK Menu *********************
echo * Launch Recursive Ping                   - Enter 1 *
echo * Reboot Terminals                        - Enter 2 *
echo * Reset Kiosk Auto Login                  - Enter 3 *
echo * Update Kiosk Banners (Will Reboot)      - Enter 4 *
echo * Remove Kiosk Bundle/Monitor             - Enter 5 *
echo * Fix Kiosk Bundle Installation Errors    - Enter 6 *
echo * Get Bundle/Monitor Versions             - Enter 7 *
echo * Get Kiosk OS Version Report             - Enter 8 *
echo * Open File Transfer to Kiosk             - Enter 9 *
echo * Back to Main Menu                      - Enter 10 *
echo *****************************************************
echo.

:KIOSK_CHOICES
SET /P KC=Enter a number (1, 2, 3...), then press ENTER: 

if %KC% ==1 goto RECURSIVE_PING_KIOSK
if %KC% ==2 goto REBOOT_KIOSK_TERMINALS
if %KC% ==3 goto RESET_KIOSK_AUTO_LOGIN
if %KC% ==4 goto UPDATE_KIOSK_BANNERS
if %KC% ==5 goto REMOVE_CREWLINK_KIOSK
if %KC% ==6 goto FIX_KIOSK_BUNDLE_INSTALLATION
if %KC% ==7 goto GET_KIOSK_BUNDLE_VERSIONS
if %KC% ==8 goto GET_KIOSK_OS_REPORT
if %KC% ==9 goto KIOSK_FILE_TRANSFER
if %KC% ==10 goto MAIN_MENU

echo Please Enter a valid Selection.
echo.
goto KIOSK_CHOICES

:RECURSIVE_PING_KIOSK
echo.
SET /P RPK=Enter an IP address, then press ENTER to launch the recursive ping: 
start "Recursive Ping to %RPK%" cmd /c ping %RPK% -t
goto KIOSK_MENU

:REBOOT_KIOSK_TERMINALS
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\kiosk_scripts\Reboot_Kiosk_Terminals.ps1"
goto KIOSK_MENU

:RESET_KIOSK_AUTO_LOGIN
call "%~dp0\scripts\kiosk_scripts\Reset_Kiosk_Auto_Login.cmd"
goto KIOSK_MENU

:UPDATE_KIOSK_BANNERS
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\kiosk_scripts\Update_Kiosk_Banners.ps1"
goto KIOSK_MENU

:REMOVE_CREWLINK_KIOSK
call "%~dp0\scripts\kiosk_scripts\Remove_Crewlink_Kiosk.cmd"
goto KIOSK_MENU

:FIX_KIOSK_BUNDLE_INSTALLATION
call "%~dp0\scripts\kiosk_scripts\Open_Kiosk_Bundle_Error_Log.cmd"
goto KIOSK_MENU

:GET_KIOSK_BUNDLE_VERSIONS
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\kiosk_scripts\Get_Kiosk_Terminal_Versions.ps1"
goto KIOSK_MENU

:GET_KIOSK_OS_REPORT
call "%~dp0\scripts\kiosk_scripts\Kiosk_OS_Version_Check.cmd"
goto KIOSK_MENU

:KIOSK_FILE_TRANSFER
call "%~dp0\scripts\kiosk_scripts\Kiosk_File_Transfer.cmd"
goto KIOSK_MENU

:PED_MENU
cls
title V.A.D.E.R. v1.2 - "Virtual Assistant for Deployments, Executions, and Remote support"

echo Welcome to Your Virtual Assistant for Deployments, Executions, and Remote support
echo V.A.D.E.R. v1.2 - Created by David Letts
echo.

echo ******************* PED Menu ************************
echo * Open Trace Folder                       - Enter 1 *
echo * Open Ingenicorba Folder                 - Enter 2 *
echo * Load PED Files to eSocket Folder        - Enter 3 *
echo * Remove PED Files from eSocket Folder    - Enter 4 *
echo * Reboot PED's                            - Enter 5 *
echo * Get Lane Profiles                       - Enter 6 *
echo * Get PED Firmware Versions               - Enter 7 *
echo * Back to Main Menu                       - Enter 8 *
echo *****************************************************
echo.

:PED_CHOICES
SET /P XC=Enter a number (1, 2, 3...), then press ENTER: 

if %XC% ==1 goto TRACE
if %XC% ==2 goto INGENICORBA
if %XC% ==3 goto LOAD_PED_FILES
if %XC% ==4 goto REMOVE_PED_FILES
if %XC% ==5 goto REBOOT_PEDS
if %XC% ==6 goto LANE_PROFILES
if %XC% ==7 goto PED_FIRMWARE
if %XC% ==8 goto MAIN_MENU

echo Please Enter a valid Selection.
echo.
goto PED_CHOICES

:TRACE
start "" "C:\postilion\eSocket.POS\trace"
goto PED_MENU

:INGENICORBA
start "" "C:\postilion\eSocket.POS\ingenicorba"
goto PED_MENU

:LOAD_PED_FILES
call "%~dp0\scripts\ped_scripts\Load_PED_Files.bat"
goto PED_MENU

:REMOVE_PED_FILES
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\ped_scripts\Remove_PED_Files.ps1"
goto PED_MENU

:REBOOT_PEDS
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\ped_scripts\Reboot_PEDs.ps1"
goto PED_MENU

:LANE_PROFILES
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\ped_scripts\Get_Lane_Profiles.ps1"
goto PED_MENU

:PED_FIRMWARE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\ped_scripts\Get_PED_Firmware.ps1"
goto PED_MENU

:SERVER_MENU
cls
title V.A.D.E.R. v1.2 - "Virtual Assistant for Deployments, Executions, and Remote support"

echo Welcome to Your Virtual Assistant for Deployments, Executions, and Remote support
echo V.A.D.E.R. v1.2 - Created by David Letts
echo.

echo ******************* Server Menu *********************
echo * Services                                - Enter 1 *
echo * Run Update POS                          - Enter 2 *
echo * Back to Main Menu                       - Enter 3 *
echo *****************************************************
echo.

:SERVER_CHOICES
SET /P SC=Enter a number (1, 2, 3...), then press ENTER: 

if %SC% ==1 goto SERVER_SERVICES_MENU
if %SC% ==2 goto UPDATE_POS
if %SC% ==3 goto MAIN_MENU

echo Please Enter a valid Selection.
echo.
goto SERVER_CHOICES

:UPDATE_POS
echo.
echo Updating POS, this could take a while...
call "%~dp0\scripts\server_scripts\UpdatePOS.exe"
echo Update POS has finished
echo.
pause
goto SERVER_MENU

:SERVER_SERVICES_MENU
cls
title V.A.D.E.R. v1.2 - "Virtual Assistant for Deployments, Executions, and Remote support"

echo Welcome to Your Virtual Assistant for Deployments, Executions, and Remote support
echo V.A.D.E.R. v1.2 - Created by David Letts
echo.

echo *************** Server Services Menu ****************
echo * Fix All Services                        - Enter 1 *
echo * Restart eSocket.POS                     - Enter 2 *
echo * Restart eSocket.POS Config Agent        - Enter 3 *
echo * Restart eSocket.POS Upgrade Manager     - Enter 4 *
echo * Restart Loyalty (ARC ^& Sigma)           - Enter 5 *
echo * Restart UC4 Service ^& Run Update POS    - Enter 6 *
echo * Back to Server Menu                     - Enter 7 *
echo * Back to Main Menu                       - Enter 8 *
echo *****************************************************
echo.

:SERVER_SERVICES_CHOICES
SET /P SSC=Enter a number (1, 2, 3...), then press ENTER: 

if %SSC% ==1 goto FIX_ALL_SERVICES
if %SSC% ==2 goto ESOCKET_POS
if %SSC% ==3 goto ESOCKET_CONFIG_AGENT
if %SSC% ==4 goto ESOCKET_UPGRADE_MANAGER
if %SSC% ==5 goto LOYALTY
if %SSC% ==6 goto UC4_AND_UPDATEPOS
if %SSC% ==7 goto SERVER_MENU
if %SSC% ==8 goto MAIN_MENU

echo Please Enter a valid Selection.
echo.
goto SERVER_SERVICES_CHOICES

:FIX_ALL_SERVICES
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\server_scripts\Fix_All_Services.ps1"
goto SERVER_SERVICES_MENU

:ESOCKET_POS
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\server_scripts\Restart_eSocket_Dot_POS.ps1"
goto SERVER_SERVICES_MENU

:ESOCKET_CONFIG_AGENT
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\server_scripts\Restart_eSocket_Config_Agent.ps1"
goto SERVER_SERVICES_MENU

:ESOCKET_UPGRADE_MANAGER
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\server_scripts\Restart_eSocket_Upgrade_Manager.ps1"
goto SERVER_SERVICES_MENU

:LOYALTY
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\server_scripts\Restart_Alchemy_Remote_Core.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\server_scripts\Restart_Sigma.ps1"
goto SERVER_SERVICES_MENU

:UC4_AND_UPDATEPOS
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\scripts\server_scripts\Restart_UC4.ps1"
echo Updating POS, this could take a while...
call "%~dp0\scripts\server_scripts\UpdatePOS.exe"
echo Update POS has finished
echo.
pause
goto SERVER_SERVICES_MENU

:DOCUMENTATION
start "V.A.D.E.R. Documentation" "Documentation.txt"
goto MAIN_MENU

:END
echo.
echo "NOOOOOOOOOOOOOOOOOOOOOOO"
pause
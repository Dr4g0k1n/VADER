@ECHO OFF

setlocal EnableExtensions 
setlocal EnableDelayedExpansion

cls

echo *************** SET POS AUTOLOGIN ***************
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

echo POS's listed in the notepad window will have their auto-login account changed.
echo.

pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\Get_POS_Terminals.ps1"
notepad terminal_list.txt

echo ************ SET POS AUTOLOGIN **********************
echo * To reset autologin to admin             - Enter 1 *
echo * To reset autologin to posuser           - Enter 2 *	
echo *****************************************************
echo.

echo Select which account to auto-login on previously selected POS's.
echo.

:POS_AUTO_LOGIN
SET /P PAC=Enter a number (1 or 2), then press ENTER: 

if %PAC% ==1 goto ADMIN
if %PAC% ==2 goto POSUSER

echo Please Enter a valid Selection.
goto POS_AUTO_LOGIN

:ADMIN
for /f "tokens=1,2" %%i in (terminal_list.txt) do (
psexec \\%%i /accepteula /u admin /p Redacted REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Radiant\Radio" /f /v ClientNumber /t REG_DWORD /d %%j
psexec \\%%i /accepteula /u admin /p Redacted -f -c "%~dp0\Reset_POS_Admin.cmd"
)
goto EOF

:POSUSER
for /f %%i in (terminal_list.txt) do psexec \\%%i /accepteula /u admin /p Redacted -f -c "%~dp0\Reset_POS_Posuser.cmd"
goto EOF


:EOF
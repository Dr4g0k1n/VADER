@echo off

setlocal EnableExtensions 
setlocal EnableDelayedExpansion

cls

echo ************ SET KIOSK AUTO LOGIN ***************
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

echo Kiosks listed in the notepad window will have their auto-login account changed.
echo.

pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\Get_Kiosk_Terminals.ps1"
notepad terminal_list.txt
cls

echo ************ SET KIOSK AUTO LOGIN *******************
echo * To reset autologin to admin             - Enter 1 *
echo * To reset autologin to administrator     - Enter 2 *
echo * To reset autologin to amcptuser         - Enter 3 *
echo * To reset autologin to kioskuser         - Enter 4 *
echo * Back to KIOSK Menu                      - Enter 5 *
echo *****************************************************
echo.

echo Select which account to auto-login on previously selected Kiosks.
echo.

:CHOICES
set /P KL=Enter a number (1, 2, 3...), then press ENTER: 

if %KL% ==1 goto ADMIN
if %KL% ==2 goto ADMINISTRATOR
if %KL% ==3 goto AMCPTUSER
if %KL% ==4 goto KIOSKUSER
if %KL% ==5 goto END

echo Please Enter a valid selection.
goto CHOICES

:ADMIN
for /f %%i in (terminal_list.txt) do (
    psexec \\%%i /accepteula /u administrator /p Redacted CMD /c REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v DefaultUserName /t REG_SZ /d admin
    psexec \\%%i /accepteula /u administrator /p Redacted CMD /c REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v DefaultPassword /t REG_SZ /d Redacted
    psexec \\%%i /accepteula /u administrator /p Redacted CMD /c REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v AutoAdminLogon /t REG_SZ /d 1
)
goto REBOOT

:ADMINISTRATOR
for /f %%i in (terminal_list.txt) do (
    psexec \\%%i /accepteula /u administrator /p Redacted CMD /c REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v DefaultUserName /t REG_SZ /d administrator
    psexec \\%%i /accepteula /u administrator /p Redacted CMD /c REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v DefaultPassword /t REG_SZ /d Redacted
    psexec \\%%i /accepteula /u administrator /p Redacted CMD /c REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v AutoAdminLogon /t REG_SZ /d 1
)
goto REBOOT

:AMCPTUSER
for /f %%i in (terminal_list.txt) do (
    psexec \\%%i /accepteula /u administrator /p Redacted CMD /c REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v DefaultUserName /t REG_SZ /d amcptuser
    psexec \\%%i /accepteula /u administrator /p Redacted CMD /c REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v DefaultPassword /t REG_SZ /d Redacted
    psexec \\%%i /accepteula /u administrator /p Redacted CMD /c REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v AutoAdminLogon /t REG_SZ /d 1
)
goto REBOOT

:KIOSKUSER
for /f %%i in (terminal_list.txt) do (
    psexec \\%%i /accepteula /u administrator /p Redacted CMD /c REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v DefaultUserName /t REG_SZ /d kioskuser
    psexec \\%%i /accepteula /u administrator /p Redacted CMD /c REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v DefaultPassword /t REG_SZ /d Redacted
    psexec \\%%i /accepteula /u administrator /p Redacted CMD /c REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v AutoAdminLogon /t REG_SZ /d 1
)
goto REBOOT

:REBOOT
for /f %%i in (terminal_list.txt) do (
    psexec \\%%i /accepteula /u administrator /p Redacted CMD /c shutdown /r /t 5
)
goto EOF

:EOF
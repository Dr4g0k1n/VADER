:: 10/28/2022 - revised deployment script to copy both RBA and UPP paths

ROBOCOPY C:\Staging\PED_Files C:\postilion\eSocket.POS /NFL /NDL /NJH /NJS /NC /NS /NP /E /Z /R:2

Echo PED Media Files copied on %DATE% %TIME%: >>C:\Staging\PED_Files\status.txt
Echo PED Media Files copied on %DATE% %TIME%: >>%~dp0\PED_Files.log
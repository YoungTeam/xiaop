@echo off
set UE_LOADER=D:\boltsdk\tools\xluecl.exe


set XAR_SEARH_PATH=%~dp0%\Main\
%UE_LOADER% -xar %XAR_SEARH_PATH%
pause

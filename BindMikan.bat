@echo off
setlocal

:: Records the MikanXR client SDK folder FetchMikan.bat copies from, then runs the fetch.
:: Pass the SDK folder as an argument, or pick it from a folder browser.
if not "%~1"=="" set "MIKAN_DIST_PATH=%~1"
if DEFINED MIKAN_DIST_PATH (goto setup_copy_script)
set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'Please select the MikanXR client SDK folder (ex: C:\MikanXR\dist\ClientSDK\Win64).',0,0).self.path""
for /f "usebackq delims=" %%I in (`powershell %psCommand%`) do set "MIKAN_DIST_PATH=%%I"
if NOT DEFINED MIKAN_DIST_PATH (goto failure)

:setup_copy_script

:: Write out the paths to a batch file
if exist "%~dp0SetMikanVars_x64.bat" del /q "%~dp0SetMikanVars_x64.bat"
echo @echo off >> "%~dp0SetMikanVars_x64.bat"
echo set "MIKAN_DIST_PATH=%MIKAN_DIST_PATH%" >> "%~dp0SetMikanVars_x64.bat"

:: Copy latest Mikan libs
call "%~dp0FetchMikan.bat" || goto failure
EXIT /B 0

:failure
pause
EXIT /B 1
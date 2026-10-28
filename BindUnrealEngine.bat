@echo off
setlocal

:: Records the Unreal Engine install the other scripts build and launch with.
:: Pass the Engine folder as an argument, or pick it from a folder browser.
if not "%~1"=="" set "UNREAL_ENGINE_PATH=%~1"
if DEFINED UNREAL_ENGINE_PATH (goto check_engine)
set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'Please select the Engine folder of an Unreal Engine install (ex: C:\Program Files\Epic Games\UE_5.8\Engine).',0,0).self.path""
for /f "usebackq delims=" %%I in (`powershell %psCommand%`) do set "UNREAL_ENGINE_PATH=%%I"
if NOT DEFINED UNREAL_ENGINE_PATH (goto failure)

:check_engine
if not exist "%UNREAL_ENGINE_PATH%\Build\BatchFiles\Build.bat" (
  echo "%UNREAL_ENGINE_PATH% is not an Unreal Engine folder: no Build\BatchFiles\Build.bat"
  goto failure
)

if exist "%~dp0SetUnrealEngineVars_x64.bat" del /q "%~dp0SetUnrealEngineVars_x64.bat"
echo @echo off >> "%~dp0SetUnrealEngineVars_x64.bat"
echo set "UNREAL_ENGINE_PATH=%UNREAL_ENGINE_PATH%" >> "%~dp0SetUnrealEngineVars_x64.bat"
echo "Bound to %UNREAL_ENGINE_PATH%"
EXIT /B 0

:failure
pause
EXIT /B 1

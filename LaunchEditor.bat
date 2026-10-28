@echo off
if not exist "%~dp0SetUnrealEngineVars_x64.bat" goto failure_unbound
call "%~dp0SetUnrealEngineVars_x64.bat"

start "" "%UNREAL_ENGINE_PATH%\Binaries\Win64\UnrealEditor.exe" "%~dp0MikanXRTestApp.uproject" %*
EXIT /B 0

:failure_unbound
echo "No engine bound. Run BindUnrealEngine.bat first."
pause
EXIT /B 1

@echo off
if not exist "%~dp0SetUnrealEngineVars_x64.bat" goto failure_unbound
call "%~dp0SetUnrealEngineVars_x64.bat"

call "%UNREAL_ENGINE_PATH%\Build\BatchFiles\Build.bat" -projectfiles -project="%~dp0MikanXRTestApp.uproject" -game -rocket -progress
EXIT /B %ERRORLEVEL%

:failure_unbound
echo "No engine bound. Run BindUnrealEngine.bat first."
pause
EXIT /B 1

@echo off
if not exist "%~dp0SetUnrealEngineVars_x64.bat" goto failure_unbound
call "%~dp0SetUnrealEngineVars_x64.bat"

:: The editor must be closed: Unreal Build Tool cannot replace modules a running editor holds
call "%UNREAL_ENGINE_PATH%\Build\BatchFiles\Build.bat" MikanXRTestAppEditor Win64 Development -Project="%~dp0MikanXRTestApp.uproject" -WaitMutex -NoHotReload
EXIT /B %ERRORLEVEL%

:failure_unbound
echo "No engine bound. Run BindUnrealEngine.bat first."
pause
EXIT /B 1

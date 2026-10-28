@echo off
setlocal
if not exist "%~dp0SetUnrealEngineVars_x64.bat" goto failure_unbound
call "%~dp0SetUnrealEngineVars_x64.bat"

:: Builds the plugin on its own, outside the test project, the way a consumer project
:: compiles it. This catches includes the test project's unity build happened to supply.
set "PACKAGE_DIR=%~dp0Saved\BuildPlugin\MikanXR_UE"
if exist "%PACKAGE_DIR%" rmdir /s /q "%PACKAGE_DIR%"

call "%UNREAL_ENGINE_PATH%\Build\BatchFiles\RunUAT.bat" BuildPlugin -Plugin="%~dp0Plugins\MikanXR_UE\MikanXR.uplugin" -Package="%PACKAGE_DIR%" -TargetPlatforms=Win64 -Rocket
EXIT /B %ERRORLEVEL%

:failure_unbound
echo "No engine bound. Run BindUnrealEngine.bat first."
pause
EXIT /B 1

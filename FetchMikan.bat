@echo off
if not exist "%~dp0SetMikanVars_x64.bat" goto failure_unbound
call "%~dp0SetMikanVars_x64.bat"

set "PLUGIN_DIR=%~dp0Plugins\MikanXR_UE"
set "PLUGIN_BIN_DIR=%PLUGIN_DIR%\ThirdParty\MikanXR\bin\win64"
set "PLUGIN_LIB_DIR=%PLUGIN_DIR%\ThirdParty\MikanXR\lib\win64"
set "PLUGIN_INC_DIR=%PLUGIN_DIR%\ThirdParty\MikanXR\include"
set "PLUGIN_OUT_DIR=%PLUGIN_DIR%\Binaries\Win64"
set "PROJECT_OUT_DIR=%~dp0Binaries\Win64"

echo "Clear Output Binaries"
if exist "%PLUGIN_OUT_DIR%\*.dll" del /q "%PLUGIN_OUT_DIR%\*.dll"
if exist "%PLUGIN_OUT_DIR%\*.pdb" del /q "%PLUGIN_OUT_DIR%\*.pdb"
if exist "%PROJECT_OUT_DIR%\*.dll" del /q "%PROJECT_OUT_DIR%\*.dll"
if exist "%PROJECT_OUT_DIR%\*.pdb" del /q "%PROJECT_OUT_DIR%\*.pdb"

REM MIKAN_DIST_PATH names a MikanXR client SDK tree: dist\ClientSDK\Win64 in a
REM MikanXR checkout after its INSTALL_CLIENT_SDK target, or an unpacked release
REM ClientSDK zip. Its include, lib, and bin folders are copied whole.
if not exist "%MIKAN_DIST_PATH%\include\MikanAPI.h" goto failure_sdk

REM Whole replacement, so a header, library, or DLL the SDK dropped drops here too
echo "Clear Old SDK Files"
if exist "%PLUGIN_INC_DIR%\*.h" del /q "%PLUGIN_INC_DIR%\*.h"
if exist "%PLUGIN_LIB_DIR%\*.lib" del /q "%PLUGIN_LIB_DIR%\*.lib"
if exist "%PLUGIN_BIN_DIR%\*.dll" del /q "%PLUGIN_BIN_DIR%\*.dll"

REM copy does not create its destination, and the project and plugin Binaries
REM folders do not exist until the first build.
echo "Ensure Output Folders"
if not exist "%PLUGIN_BIN_DIR%" mkdir "%PLUGIN_BIN_DIR%" || goto failure
if not exist "%PLUGIN_LIB_DIR%" mkdir "%PLUGIN_LIB_DIR%" || goto failure
if not exist "%PLUGIN_INC_DIR%" mkdir "%PLUGIN_INC_DIR%" || goto failure
if not exist "%PROJECT_OUT_DIR%" mkdir "%PROJECT_OUT_DIR%" || goto failure

echo "Copy Mikan DLLs"
copy /y "%MIKAN_DIST_PATH%\bin\*.dll" "%PLUGIN_BIN_DIR%" || goto failure_dll

echo "Copy Mikan DLLs to the project binaries"
REM MikanXR.Build.cs copies these into the project binaries only when Unreal Build
REM Tool re-evaluates the module rules, and a cached makefile skips that step. The
REM clear above removed the previous copies, so restore them here or the build's
REM runtime dependency copy fails with a missing source file.
copy /y "%PLUGIN_BIN_DIR%\*.dll" "%PROJECT_OUT_DIR%" || goto failure_project_dll

echo "Copy Mikan header files"
copy /y "%MIKAN_DIST_PATH%\include\*.h" "%PLUGIN_INC_DIR%" || goto failure_headers

echo "Copy Mikan Libs"
copy /y "%MIKAN_DIST_PATH%\lib\*.lib" "%PLUGIN_LIB_DIR%" || goto failure_lib

EXIT /B 0

:failure_unbound
echo "No client SDK bound. Run BindMikan.bat first."
goto failure

:failure_sdk
echo "No MikanXR client SDK at %MIKAN_DIST_PATH%"
echo "Build MikanXR's INSTALL_CLIENT_SDK target, then run BindMikan.bat naming its dist\ClientSDK\Win64"
goto failure

:failure_dll
echo "Error copying DLLs"
goto failure

:failure_project_dll
echo "Error copying DLLs to the project binaries"
goto failure

:failure_headers
echo "Error copying header files"
goto failure

:failure_lib
echo "Error copying libs"
goto failure

:failure
pause
EXIT /B 1

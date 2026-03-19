@echo off
setlocal EnableExtensions

set "TARGET_DIR=C:\ML CLI\Tools"
if defined MLCLI_TARGET_DIR set "TARGET_DIR=%MLCLI_TARGET_DIR%"

set "UNINSTALL_VERSION=2026.03.19.4"

rem If this script is running from inside TARGET_DIR, copy to TEMP and run there.
rem This avoids locking the folder/script while trying to delete it.
if /I "%~1"=="--from-temp" goto :RUN_UNINSTALL

for %%I in ("%~dp0.") do set "SCRIPT_DIR=%%~fI"
for %%I in ("%TARGET_DIR%\.") do set "TARGET_DIR_NORM=%%~fI"

if /I "%SCRIPT_DIR%"=="%TARGET_DIR_NORM%" (
  set "TMP_RUNNER=%TEMP%\ml_uninstall_runner_%RANDOM%%RANDOM%.bat"
  copy /Y "%~f0" "%TMP_RUNNER%" >nul
  if errorlevel 1 (
    echo [FAIL] Failed to create temporary uninstaller runner.
    exit /b 1
  )
  call "%TMP_RUNNER%" --from-temp
  set "EXIT_CODE=%ERRORLEVEL%"
  del "%TMP_RUNNER%" >nul 2>&1
  exit /b %EXIT_CODE%
)

:RUN_UNINSTALL
cd /d "%TEMP%" >nul 2>&1

echo Uninstalling ML CLI...
echo Version: %UNINSTALL_VERSION%
echo Target: %TARGET_DIR%

powershell -NoProfile -ExecutionPolicy Bypass -Command "$target='%TARGET_DIR%'; $userPath=[Environment]::GetEnvironmentVariable('Path','User'); if(-not $userPath){ Write-Output 'PATH_EMPTY'; exit 0 }; $parts=$userPath -split ';' | Where-Object { $_ -and $_.Trim() -ne '' }; $filtered=@(); foreach($p in $parts){ if($p.TrimEnd('\\') -ine $target.TrimEnd('\\')){ $filtered += $p } }; if($filtered.Count -ne $parts.Count){ [Environment]::SetEnvironmentVariable('Path',($filtered -join ';'),'User'); Write-Output 'PATH_REMOVED'; } else { Write-Output 'PATH_NOT_FOUND'; }" > "%TEMP%\ml_uninstall_path_result.txt"

set "PATH_RESULT="
set /p PATH_RESULT=<"%TEMP%\ml_uninstall_path_result.txt"
del "%TEMP%\ml_uninstall_path_result.txt" >nul 2>&1

if /I "%PATH_RESULT%"=="PATH_REMOVED" (
  echo Removed %TARGET_DIR% from User PATH.
) else if /I "%PATH_RESULT%"=="PATH_NOT_FOUND" (
  echo %TARGET_DIR% was not found in User PATH.
) else (
  echo User PATH is empty or unchanged.
)

if not exist "%TARGET_DIR%" (
  echo [SUCCESS] Uninstall complete. Directory already removed.
  exit /b 0
)

echo Removing %TARGET_DIR%...
attrib -R "%TARGET_DIR%\*" /S /D >nul 2>&1

for /L %%N in (1,1,8) do (
  if not exist "%TARGET_DIR%" goto :REMOVED
  powershell -NoProfile -ExecutionPolicy Bypass -Command "try{ Remove-Item -LiteralPath '%TARGET_DIR%' -Recurse -Force -ErrorAction Stop; exit 0 } catch { exit 2 }" >nul 2>&1
  if not exist "%TARGET_DIR%" goto :REMOVED
  timeout /t 1 /nobreak >nul
)

if exist "%TARGET_DIR%" (
  echo [FAIL] Could not remove %TARGET_DIR%.
  echo Close all terminals/editors using that folder, then run uninstaller again.
  echo Remaining files:
  dir "%TARGET_DIR%" /A /B 2>nul
  exit /b 1
)

:REMOVED
echo Removed %TARGET_DIR%
echo [SUCCESS] Uninstall complete.
echo Open a new terminal so PATH updates are reflected.
exit /b 0

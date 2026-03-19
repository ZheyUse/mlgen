@echo off
setlocal

set "TARGET_DIR=C:\ML CLI\Tools"

echo Uninstalling ML CLI...

powershell -NoProfile -ExecutionPolicy Bypass -Command "$target='C:\ML CLI\Tools'; $userPath=[Environment]::GetEnvironmentVariable('Path','User'); if(-not $userPath){ Write-Output 'PATH_EMPTY'; exit 0 }; $parts=$userPath -split ';' | Where-Object { $_ -and $_.Trim() -ne '' }; $filtered=@(); foreach($p in $parts){ if($p.TrimEnd('\\') -ine $target.TrimEnd('\\')){ $filtered += $p } }; if($filtered.Count -ne $parts.Count){ [Environment]::SetEnvironmentVariable('Path',($filtered -join ';'),'User'); Write-Output 'PATH_REMOVED'; } else { Write-Output 'PATH_NOT_FOUND'; }" > "%TEMP%\ml_uninstall_path_result.txt"

set "PATH_RESULT="
set /p PATH_RESULT=<"%TEMP%\ml_uninstall_path_result.txt"
del "%TEMP%\ml_uninstall_path_result.txt" >nul 2>&1

if /I "%PATH_RESULT%"=="PATH_REMOVED" (
  echo Removed C:\ML CLI\Tools from User PATH.
) else if /I "%PATH_RESULT%"=="PATH_NOT_FOUND" (
  echo C:\ML CLI\Tools was not found in User PATH.
) else (
  echo User PATH is empty or unchanged.
)

if exist "%TARGET_DIR%" (
  echo Removing %TARGET_DIR%...

  rem Clear read-only attributes recursively to reduce delete failures
  attrib -R "%TARGET_DIR%\*" /S /D >nul 2>&1

  set "PS_SCRIPT=%TEMP%\ml_uninstall_script.ps1"
  (echo $t = '%TARGET_DIR%') > "%PS_SCRIPT%"
  (echo try {) >> "%PS_SCRIPT%"
  (echo     Remove-Item -LiteralPath $t -Recurse -Force -ErrorAction Stop;) >> "%PS_SCRIPT%"
  (echo     Write-Output 'RM_OK') >> "%PS_SCRIPT%"
  (echo } catch {) >> "%PS_SCRIPT%"
  (echo     Write-Output 'RM_ERR: ' + $_.Exception.Message) >> "%PS_SCRIPT%"
  (echo     if ($_.Exception.InnerException) { Write-Output $_.Exception.InnerException.Message }) >> "%PS_SCRIPT%"
  (echo     Write-Output 'RM_STACK:') >> "%PS_SCRIPT%"
  (echo     Write-Output $_.ScriptStackTrace) >> "%PS_SCRIPT%"
  (echo     exit 2) >> "%PS_SCRIPT%"
  (echo }) >> "%PS_SCRIPT%"

  powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" > "%TEMP%\ml_rm_result.txt" 2>&1
  del "%PS_SCRIPT%" >nul 2>&1

  set "RM_RESULT="
  set /p RM_RESULT=<"%TEMP%\ml_rm_result.txt"
  del "%TEMP%\ml_rm_result.txt" >nul 2>&1

  if /I "%RM_RESULT%"=="RM_OK" (
    echo Removed %TARGET_DIR%
  ) else (
    echo [ERROR] Failed to remove %TARGET_DIR%:
    echo %RM_RESULT%
    echo.
    echo Additional info: listing folder contents to help debug:
    dir "%TARGET_DIR%" /A /B 2>nul || echo [ERROR] Unable to list contents (folder may be locked)
    echo.
    echo Close terminals/processes using files in that folder and try again, or remove the folder manually.
    exit /b 1
  )
) else (
  echo Directory not found: %TARGET_DIR%
)

echo.
echo Uninstall complete.
echo Open a new terminal so PATH updates are reflected.

exit /b 0

@echo off
setlocal

set "TARGET_DIR=C:\tools\ml"

echo Uninstalling ML CLI...

powershell -NoProfile -ExecutionPolicy Bypass -Command "$target='C:\tools\ml'; $userPath=[Environment]::GetEnvironmentVariable('Path','User'); if(-not $userPath){ Write-Output 'PATH_EMPTY'; exit 0 }; $parts=$userPath -split ';' | Where-Object { $_ -and $_.Trim() -ne '' }; $filtered=@(); foreach($p in $parts){ if($p.TrimEnd('\\') -ine $target.TrimEnd('\\')){ $filtered += $p } }; if($filtered.Count -ne $parts.Count){ [Environment]::SetEnvironmentVariable('Path',($filtered -join ';'),'User'); Write-Output 'PATH_REMOVED'; } else { Write-Output 'PATH_NOT_FOUND'; }" > "%TEMP%\ml_uninstall_path_result.txt"

set "PATH_RESULT="
set /p PATH_RESULT=<"%TEMP%\ml_uninstall_path_result.txt"
del "%TEMP%\ml_uninstall_path_result.txt" >nul 2>&1

if /I "%PATH_RESULT%"=="PATH_REMOVED" (
  echo Removed C:\tools\ml from User PATH.
) else if /I "%PATH_RESULT%"=="PATH_NOT_FOUND" (
  echo C:\tools\ml was not found in User PATH.
) else (
  echo User PATH is empty or unchanged.
)

if exist "%TARGET_DIR%" (
  rmdir /S /Q "%TARGET_DIR%"
  if exist "%TARGET_DIR%" (
    echo [ERROR] Failed to remove %TARGET_DIR%
    echo Close terminals/processes using files in that folder and try again.
    exit /b 1
  )
  echo Removed %TARGET_DIR%
) else (
  echo Directory not found: %TARGET_DIR%
)

echo.
echo Uninstall complete.
echo Open a new terminal so PATH updates are reflected.

exit /b 0

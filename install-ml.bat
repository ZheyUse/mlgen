@echo off
setlocal

set "TARGET_DIR=C:\ML CLI\Tools"
set "SOURCE_DIR=%~dp0"

echo Installing ML CLI...
echo Target: %TARGET_DIR%

if not exist "%SOURCE_DIR%generate-file-remote.php" (
  echo [ERROR] Missing source file: generate-file-remote.php
  exit /b 1
)

if not exist "%SOURCE_DIR%ml.bat" (
  echo [ERROR] Missing source file: ml.bat
  exit /b 1
)

rem If local assets are missing, we'll download them from the repository instead
rem (don't fail the installer just because source assets aren't present).

if not exist "%TARGET_DIR%" (
  mkdir "%TARGET_DIR%" 2>nul
  if errorlevel 1 (
    echo [ERROR] Failed to create %TARGET_DIR%
    echo Try running this installer as Administrator.
    exit /b 1
  )
  echo Created %TARGET_DIR%
) else (
  echo Directory already exists: %TARGET_DIR%
)

rem Install the remote-loader stub as the generator to fetch the real code at runtime
copy /Y "%SOURCE_DIR%generate-file-remote.php" "%TARGET_DIR%\generate-file-structure.php" >nul
if errorlevel 1 (
  echo [ERROR] Failed to copy generate-file-remote.php to %TARGET_DIR%\generate-file-structure.php
  exit /b 1
)

copy /Y "%SOURCE_DIR%ml.bat" "%TARGET_DIR%\ml.bat" >nul
if errorlevel 1 (
  echo [ERROR] Failed to copy ml.bat
  exit /b 1
)

if not exist "%TARGET_DIR%\assets\images" (
  mkdir "%TARGET_DIR%\assets\images" 2>nul
  if errorlevel 1 (
    echo [ERROR] Failed to create %TARGET_DIR%\assets\images
    exit /b 1
  )
)

set "RAW_BASE=https://raw.githubusercontent.com/ZheyUse/mlgen/main/assets/images"

for %%F in (logo1.png logo2.png) do (
  if exist "%SOURCE_DIR%assets\images\%%F" (
    copy /Y "%SOURCE_DIR%assets\images\%%F" "%TARGET_DIR%\assets\images\%%F" >nul
    if errorlevel 1 (
      echo [ERROR] Failed to copy assets\images\%%F
      exit /b 1
    )
  ) else (
    echo Downloading %%F from GitHub...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "try{ (New-Object Net.WebClient).DownloadFile('%RAW_BASE%/%%F', '%TARGET_DIR%\\assets\\images\\%%F'); exit 0 } catch { exit 2 }"
    if errorlevel 1 (
      echo [ERROR] Failed to download %%F
      exit /b 1
    )
  )
)

echo Copied CLI files and assets.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$target='C:\ML CLI\Tools'; $userPath=[Environment]::GetEnvironmentVariable('Path','User'); $parts=@(); if($userPath){$parts=$userPath -split ';' | Where-Object { $_ -and $_.Trim() -ne '' }}; $exists=$false; foreach($p in $parts){ if($p.TrimEnd('\\') -ieq $target.TrimEnd('\\')){ $exists=$true; break } }; if(-not $exists){ $newPath=(($parts + $target) | Select-Object -Unique) -join ';'; [Environment]::SetEnvironmentVariable('Path',$newPath,'User'); Write-Output 'PATH_ADDED'; } else { Write-Output 'PATH_EXISTS'; }" > "%TEMP%\ml_path_result.txt"

set "PATH_RESULT="
set /p PATH_RESULT=<"%TEMP%\ml_path_result.txt"
del "%TEMP%\ml_path_result.txt" >nul 2>&1

if /I "%PATH_RESULT%"=="PATH_ADDED" (
  echo Added C:\ML CLI\Tools to User PATH.
) else (
  echo C:\ML CLI\Tools already exists in User PATH.
)

set "PATH=%PATH%;C:\ML CLI\Tools"

echo.
echo Installation complete.
echo You can now run: ml create banking-system
echo If command is not recognized in this window, open a new terminal.

exit /b 0

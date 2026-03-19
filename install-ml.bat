@echo off
setlocal

set "TARGET_DIR=C:\ML CLI\Tools"
set "SOURCE_DIR=%~dp0"

echo Installing ML CLI...
echo Target: %TARGET_DIR%

rem Display ASCII art intro before installation
powershell -NoProfile -ExecutionPolicy Bypass -Command "@'
\n┏┳┓┏━┓╺┳┓┏━╸   ┏┓ ╻ ╻
┃┃┃┣━┫ ┃┃┣╸    ┣┻┓┗┳┛
╹ ╹╹ ╹╺┻┛┗━╸   ┗━┛ ╹ 
 ██████╗ ██████╗ ██████╗ ███████╗███████╗
██╔════╝██╔═══██╗██╔══██╗██╔════╝╚══███╔╝
██║     ██║   ██║██║  ██║█████╗    ███╔╝ 
██║     ██║   ██║██║  ██║██╔══╝   ███╔╝  
╚██████╗╚██████╔╝██████╔╝███████╗███████╗
 ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝
\nFollow: https://github.com/ZheyUse
\n'@ | Write-Host"


rem Download required CLI files from the GitHub repo if not bundling locally.
set "RAW_BASE=https://raw.githubusercontent.com/ZheyUse/mlgen/main"


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

rem Progress state
set "TOTAL=3"
set /a PROGRESS=0

echo Installing Necessary Files...
echo Progress: %PROGRESS%/%TOTAL%

rem Step 1: download generator stub and CLI batch (grouped)
powershell -NoProfile -ExecutionPolicy Bypass -Command "try{ (New-Object Net.WebClient).DownloadFile('%RAW_BASE%/generate-file-remote.php', '%TARGET_DIR%\\generate-file-structure.php'); (New-Object Net.WebClient).DownloadFile('%RAW_BASE%/ml.bat', '%TARGET_DIR%\\ml.bat'); exit 0 } catch { exit 2 }"
if errorlevel 1 (
  echo [ERROR] Failed to download necessary files
  exit /b 1
)

set /a PROGRESS+=1
echo Progress: %PROGRESS%/%TOTAL%

echo Installing Uninstaller...

rem Step 2: download uninstaller
powershell -NoProfile -ExecutionPolicy Bypass -Command "try{ (New-Object Net.WebClient).DownloadFile('%RAW_BASE%/uninstall-ml.bat', '%TARGET_DIR%\\uninstall-ml.bat'); exit 0 } catch { exit 2 }"
if errorlevel 1 (
  echo [ERROR] Failed to download uninstall-ml.bat
  exit /b 1
)

set /a PROGRESS+=1
echo Progress: %PROGRESS%/%TOTAL%

echo Adding ML CLI to env path...

rem Step 3 will add the target to the user PATH below

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

rem Finalize progress
set /a PROGRESS+=1
echo Progress: %PROGRESS%/%TOTAL%

echo.
echo Installation complete.
echo You can now run: ml create banking-system
echo If command is not recognized in this window, open a new terminal.

rem Write the "Made By" ASCII art into the installed CLI folder and show it
powershell -NoProfile -ExecutionPolicy Bypass -Command "@'
\n┏┳┓┏━┓╺┳┓┏━╸   ┏┓ ╻ ╻
┃┃┃┣━┫ ┃┃┣╸    ┣┻┓┗┳┛
╹ ╹╹ ╹╺┻┛┗━╸   ┗━┛ ╹ 
 ██████╗ ██████╗ ██████╗ ███████╗███████╗
██╔════╝██╔═══██╗██╔══██╗██╔════╝╚══███╔╝
██║     ██║   ██║██║  ██║█████╗    ███╔╝ 
██║     ██║   ██║██║  ██║██╔══╝   ███╔╝  
╚██████╗╚██████╔╝██████╔╝███████╗███████╗
 ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝
\n+Follow: https://github.com/ZheyUse
\n'@ | Out-File -FilePath '%TARGET_DIR%\made-by.txt' -Encoding UTF8"

echo.
type "%TARGET_DIR%\made-by.txt"
echo.

exit /b 0

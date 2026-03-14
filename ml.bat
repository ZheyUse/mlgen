@echo off
setlocal

set "ML_SCRIPT=%~dp0generate-file-structure.php"

if exist "C:\xampp\php\php.exe" (
    "C:\xampp\php\php.exe" "%ML_SCRIPT%" %*
    exit /b %ERRORLEVEL%
)

php "%ML_SCRIPT%" %*
exit /b %ERRORLEVEL%

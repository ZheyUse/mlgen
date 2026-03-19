@echo off
setlocal

set "ML_SCRIPT=%~dp0generate-file-structure.php"

rem Show short ASCII intro when the CLI is invoked interactively
if "%~0"=="%~0" (
    echo.
    rem Print full "Made By" ASCII art as CLI intro
    echo ┏┳┓┏━┓╺┳┓┏━╸   ┏┓ ╻ ╻
    echo ┃┃┃┣━┫ ┃┃┣╸    ┣┻┓┗┳┛
    echo ╹ ╹╹ ╹╺┻┛┗━╸   ┗━┛ ╹ 
    echo  ██████╗ ██████╗ ██████╗ ███████╗███████╗
    echo ██╔════╝██╔═══██╗██╔══██╗██╔════╝╚══███╔╝
    echo ██║     ██║   ██║██║  ██║█████╗    ███╔╝ 
    echo ██║     ██║   ██║██║  ██║██╔══╝   ███╔╝  
    echo ╚██████╗╚██████╔╝██████╔╝███████╗███████╗
    echo  ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝
    echo.
    echo Follow: https://github.com/ZheyUse
    echo.
)

if exist "C:\xampp\php\php.exe" (
        "C:\xampp\php\php.exe" "%ML_SCRIPT%" %*
        exit /b %ERRORLEVEL%
)

php "%ML_SCRIPT%" %*
exit /b %ERRORLEVEL%

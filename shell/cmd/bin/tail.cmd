@echo off
setlocal
if "%~2"=="" (
    powershell -NoProfile -Command "Get-Content -LiteralPath ($args[0]) | Select-Object -Last 10" -args "%~1"
) else (
    powershell -NoProfile -Command "Get-Content -LiteralPath ($args[0]) | Select-Object -Last ([int]$args[1])" -args "%~2" "%~1"
)
endlocal

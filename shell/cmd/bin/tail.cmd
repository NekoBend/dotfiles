@echo off
if "%~2"=="" (powershell -NoProfile -Command "Get-Content '%~1' | Select-Object -Last 10") else (powershell -NoProfile -Command "Get-Content '%~2' | Select-Object -Last %~1")

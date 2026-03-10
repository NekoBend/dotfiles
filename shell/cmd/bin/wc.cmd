@echo off
powershell -NoProfile -Command "Get-Content '%~1' | Measure-Object -Line -Word -Character"

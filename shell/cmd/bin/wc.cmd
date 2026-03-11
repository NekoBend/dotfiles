@echo off
powershell -NoProfile -Command "Get-Content -LiteralPath ($args[0]) | Measure-Object -Line -Word -Character" -args "%~1"

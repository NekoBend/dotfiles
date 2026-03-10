@echo off
where fd >nul 2>&1 && (fd %*) || (%SystemRoot%\System32\find.exe %*)

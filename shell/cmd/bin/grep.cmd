@echo off
where rg >nul 2>&1 && (rg %*) || (findstr %*)

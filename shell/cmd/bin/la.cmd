@echo off
where lsd >nul 2>&1 && (lsd -a %*) || (dir /a %*)

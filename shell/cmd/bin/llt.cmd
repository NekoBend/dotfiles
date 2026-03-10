@echo off
where lsd >nul 2>&1 && (lsd -l --tree %*) || (tree /f %*)

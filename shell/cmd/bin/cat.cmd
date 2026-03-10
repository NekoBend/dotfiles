@echo off
where bat >nul 2>&1 && (bat --style=plain --paging=never %*) || (type %*)

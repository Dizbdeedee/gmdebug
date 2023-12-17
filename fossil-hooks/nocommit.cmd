@echo off
rg NOCOMMIT --type-add "haxe:*.{hx,hxml}" --type haxe
if %ERRORLEVEL% EQU 0 (exit /b 1) else (exit /b 0)
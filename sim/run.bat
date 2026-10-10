@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0regress.ps1"
exit /b %ERRORLEVEL%

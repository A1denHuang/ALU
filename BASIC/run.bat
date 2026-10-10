@echo off
setlocal
set "MODE=%~1"
if "%MODE%"=="" set "MODE=examples"
set "SV_BASICS_MODE=%MODE%"

if exist "D:\Questasim\win64\vsim.exe" (
  set "VSIM=D:\Questasim\win64\vsim.exe"
) else (
  set "VSIM=vsim"
)

pushd "%~dp0"
"%VSIM%" -c -do "do run.do"
set "RESULT=%ERRORLEVEL%"
popd
exit /b %RESULT%

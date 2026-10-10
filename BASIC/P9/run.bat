@echo off
setlocal

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

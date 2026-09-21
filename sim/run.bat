@echo off
setlocal
pushd "%~dp0"
vsim -c -do run.do
set "SIM_EXIT_CODE=%ERRORLEVEL%"
popd
exit /b %SIM_EXIT_CODE%

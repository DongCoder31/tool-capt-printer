@echo off
:: Double-click file nay de cai may in Canon LBP2900 (tu dong xin quyen Admin)
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Cai-May-In.ps1"

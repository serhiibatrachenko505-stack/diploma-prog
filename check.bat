@echo off
flutter analyze
if errorlevel 1 exit /b 1

flutter test
if errorlevel 1 exit /b 1

echo All checks passed.
@echo off
REM Warehouse Container Tracker Testing Script for Windows
REM This script helps test the app step by step

echo 🧪 Testing Warehouse Container Tracker...

REM Step 1: Check Flutter installation
echo 📱 Step 1: Checking Flutter installation...
flutter --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Flutter is installed
) else (
    echo ❌ Flutter is not installed
    pause
    exit /b 1
)

REM Step 2: Check Flutter doctor
echo 🔍 Step 2: Running Flutter doctor...
flutter doctor >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Flutter doctor passed
) else (
    echo ⚠️  Flutter doctor has warnings
)

REM Step 3: Check if .env file exists
echo 📄 Step 3: Checking .env file...
if exist ".env" (
    echo ✅ .env file exists
) else (
    echo ⚠️  .env file not found. Please create it from env_template.txt
)

REM Step 4: Get dependencies
echo 📦 Step 4: Getting dependencies...
flutter pub get >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Dependencies installed
) else (
    echo ❌ Failed to install dependencies
)

REM Step 5: Run unit tests
echo 🧪 Step 5: Running unit tests...
flutter test >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Unit tests passed
) else (
    echo ⚠️  Unit tests failed or no tests found
)

REM Step 6: Check for linting issues
echo 🔍 Step 6: Checking for linting issues...
flutter analyze >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ No linting issues found
) else (
    echo ⚠️  Linting issues found
)

REM Step 7: Build debug APK
echo 🔨 Step 7: Building debug APK...
flutter build apk --debug >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Debug APK built successfully
) else (
    echo ❌ Failed to build debug APK
)

REM Step 8: Check if devices are connected
echo 📱 Step 8: Checking connected devices...
flutter devices >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Devices check completed
    echo Available devices:
    flutter devices
) else (
    echo ⚠️  No devices connected. Connect a device or start an emulator.
)

echo.
echo 🎉 Testing completed!
echo.
echo 📋 Next steps:
echo 1. Create .env file from env_template.txt
echo 2. Fill in your Firebase and Google Sheets configuration
echo 3. Run: flutter run
echo 4. Test the app functionality
echo.
echo 🚀 Happy testing!
pause

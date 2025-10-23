@echo off
REM Build script for Android Release APK (Windows)
REM Usage: build-android.bat

echo 🚀 Building Warehouse Tracker - Android Release APK
echo ==================================================

REM Check if node_modules exists
if not exist "node_modules" (
    echo 📦 Installing dependencies...
    call npm install
)

REM Clean previous builds
echo 🧹 Cleaning previous builds...
cd android
call gradlew clean
cd ..

REM Build release APK
echo 🔨 Building release APK...
cd android
call gradlew assembleRelease
cd ..

REM Check if build was successful
if exist "android\app\build\outputs\apk\release\app-release.apk" (
    echo ✅ Build successful!
    echo 📱 APK location: android\app\build\outputs\apk\release\app-release.apk
    
    REM Copy to root for easy access
    copy android\app\build\outputs\apk\release\app-release.apk warehouse-tracker-android.apk
    echo 📋 Copied to: warehouse-tracker-android.apk
) else (
    echo ❌ Build failed!
    exit /b 1
)

echo.
echo 🎉 Build complete! You can now install the APK on your device.
echo To install: adb install warehouse-tracker-android.apk
pause

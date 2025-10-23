@echo off
REM Warehouse Container Tracker Build Script for Windows
REM This script helps build the Flutter app for different platforms

echo 🏗️  Building Warehouse Container Tracker...

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed. Please install Flutter first.
    pause
    exit /b 1
)

REM Get Flutter version
echo 📱 Flutter version:
flutter --version

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Run tests (if any)
echo 🧪 Running tests...
flutter test
if %errorlevel% neq 0 (
    echo ⚠️  No tests found or tests failed
)

REM Build for different platforms
echo 🔨 Building for different platforms...

REM Android APK
echo 📱 Building Android APK...
flutter build apk --release

REM Android App Bundle (for Play Store)
echo 📱 Building Android App Bundle...
flutter build appbundle --release

REM Web
echo 🌐 Building Web...
flutter build web --release

echo ✅ Build completed successfully!
echo.
echo 📁 Build outputs:
echo    Android APK: build\app\outputs\flutter-apk\app-release.apk
echo    Android Bundle: build\app\outputs\bundle\release\app-release.aab
echo    Web: build\web\
echo.
echo 🚀 Ready for deployment!
pause

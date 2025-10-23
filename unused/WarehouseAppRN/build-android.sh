#!/bin/bash

# Build script for Android Release APK
# Usage: ./build-android.sh

echo "🚀 Building Warehouse Tracker - Android Release APK"
echo "=================================================="

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
cd android
./gradlew clean
cd ..

# Build release APK
echo "🔨 Building release APK..."
cd android
./gradlew assembleRelease
cd ..

# Check if build was successful
if [ -f "android/app/build/outputs/apk/release/app-release.apk" ]; then
    echo "✅ Build successful!"
    echo "📱 APK location: android/app/build/outputs/apk/release/app-release.apk"
    
    # Get APK size
    APK_SIZE=$(du -h android/app/build/outputs/apk/release/app-release.apk | cut -f1)
    echo "📊 APK size: $APK_SIZE"
    
    # Copy to root for easy access
    cp android/app/build/outputs/apk/release/app-release.apk ./warehouse-tracker-android.apk
    echo "📋 Copied to: ./warehouse-tracker-android.apk"
else
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "🎉 Build complete! You can now install the APK on your device."
echo "To install: adb install warehouse-tracker-android.apk"

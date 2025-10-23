#!/bin/bash

# Warehouse Container Tracker Build Script
# This script helps build the Flutter app for different platforms

set -e

echo "🏗️  Building Warehouse Container Tracker..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Get Flutter version
echo "📱 Flutter version:"
flutter --version

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run tests (if any)
echo "🧪 Running tests..."
flutter test || echo "⚠️  No tests found or tests failed"

# Build for different platforms
echo "🔨 Building for different platforms..."

# Android APK
echo "📱 Building Android APK..."
flutter build apk --release

# Android App Bundle (for Play Store)
echo "📱 Building Android App Bundle..."
flutter build appbundle --release

# iOS (requires macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building iOS..."
    flutter build ios --release
else
    echo "⚠️  Skipping iOS build (requires macOS)"
fi

# Web (optional)
echo "🌐 Building Web..."
flutter build web --release

echo "✅ Build completed successfully!"
echo ""
echo "📁 Build outputs:"
echo "   Android APK: build/app/outputs/flutter-apk/app-release.apk"
echo "   Android Bundle: build/app/outputs/bundle/release/app-release.aab"
echo "   iOS: build/ios/iphoneos/Runner.app"
echo "   Web: build/web/"
echo ""
echo "🚀 Ready for deployment!"

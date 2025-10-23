#!/bin/bash

# Warehouse Container Tracker Testing Script
# This script helps test the app step by step

echo "🧪 Testing Warehouse Container Tracker..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $2 -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Step 1: Check Flutter installation
echo "📱 Step 1: Checking Flutter installation..."
flutter --version > /dev/null 2>&1
print_status "Flutter is installed" $?

# Step 2: Check Flutter doctor
echo "🔍 Step 2: Running Flutter doctor..."
flutter doctor > /dev/null 2>&1
print_status "Flutter doctor passed" $?

# Step 3: Check if .env file exists
echo "📄 Step 3: Checking .env file..."
if [ -f ".env" ]; then
    print_status ".env file exists" 0
else
    print_warning ".env file not found. Please create it from env_template.txt"
fi

# Step 4: Get dependencies
echo "📦 Step 4: Getting dependencies..."
flutter pub get > /dev/null 2>&1
print_status "Dependencies installed" $?

# Step 5: Run unit tests
echo "🧪 Step 5: Running unit tests..."
flutter test > /dev/null 2>&1
print_status "Unit tests passed" $?

# Step 6: Check for linting issues
echo "🔍 Step 6: Checking for linting issues..."
flutter analyze > /dev/null 2>&1
print_status "No linting issues found" $?

# Step 7: Build debug APK
echo "🔨 Step 7: Building debug APK..."
flutter build apk --debug > /dev/null 2>&1
print_status "Debug APK built successfully" $?

# Step 8: Check if devices are connected
echo "📱 Step 8: Checking connected devices..."
DEVICES=$(flutter devices --machine | grep -c '"id"')
if [ $DEVICES -gt 0 ]; then
    print_status "Devices connected: $DEVICES" 0
    echo "Available devices:"
    flutter devices
else
    print_warning "No devices connected. Connect a device or start an emulator."
fi

echo ""
echo "🎉 Testing completed!"
echo ""
echo "📋 Next steps:"
echo "1. Create .env file from env_template.txt"
echo "2. Fill in your Firebase and Google Sheets configuration"
echo "3. Run: flutter run"
echo "4. Test the app functionality"
echo ""
echo "🚀 Happy testing!"

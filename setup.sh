#!/bin/bash

# Warehouse Container Tracker Setup Script
# This script helps set up the development environment

set -e

echo "🚀 Setting up Warehouse Container Tracker..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed."
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Flutter version
echo "📱 Checking Flutter version..."
flutter --version

# Check if Flutter doctor passes
echo "🔍 Running Flutter doctor..."
flutter doctor

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p assets/images
mkdir -p assets/config
mkdir -p android/app/src/main/res/drawable
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset

# Create placeholder files
echo "📄 Creating placeholder files..."

# Create placeholder image
cat > assets/images/placeholder.png << 'EOF'
# This is a placeholder for the actual image file
# Replace this with a real PNG image file
EOF

# Create Firebase configuration template
cat > assets/config/firebase_config.dart << 'EOF'
// Firebase Configuration Template
// Replace with your actual Firebase configuration

class FirebaseConfig {
  // Firebase Project Configuration
  static const String projectId = 'your-project-id';
  static const String storageBucket = 'your-project-id.appspot.com';
  static const String messagingSenderId = 'your-sender-id';
  
  // Android Configuration
  static const String androidAppId = 'your-android-app-id';
  
  // iOS Configuration  
  static const String iosAppId = 'your-ios-app-id';
  
  // API Keys (if needed)
  static const String apiKey = 'your-api-key';
}
EOF

# Create Google Sheets configuration template
cat > assets/config/google_sheets_config.dart << 'EOF'
// Google Sheets Configuration Template
// Replace with your actual Google Sheets configuration

class GoogleSheetsConfig {
  // Spreadsheet Configuration
  static const String spreadsheetId = 'your-spreadsheet-id';
  static const String sheetName = 'Sheet1';
  static const String range = 'A:Z';
  
  // Service Account Configuration
  static const String serviceAccountEmail = 'your-service-account@project.iam.gserviceaccount.com';
  
  // Column Mapping
  static const Map<String, String> columnMapping = {
    'containerNumber': 'A',
    'type': 'B', 
    'pieceCount': 'C',
    'materials': 'D',
    'doorNumber': 'E',
    'dateCompleted': 'F',
    'shareableLink': 'G',
    'status': 'H',
    'hasDiscrepancies': 'I',
    'discrepancies': 'J',
  };
}
EOF

# Create environment configuration template
cat > .env.template << 'EOF'
# Environment Configuration Template
# Copy this file to .env and fill in your actual values

# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your-sender-id

# Google Sheets Configuration
GOOGLE_SHEETS_SPREADSHEET_ID=your-spreadsheet-id
GOOGLE_SERVICE_ACCOUNT_JSON=your-service-account-json-base64

# Admin Configuration
ADMIN_EMAIL=admin@yourcompany.com

# App Configuration
DEBUG_MODE=true
LOG_LEVEL=debug
EOF

echo "✅ Setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Configure Firebase:"
echo "   - Create a Firebase project"
echo "   - Enable Storage and Cloud Messaging"
echo "   - Download google-services.json (Android) and GoogleService-Info.plist (iOS)"
echo "   - Update assets/config/firebase_config.dart"
echo ""
echo "2. Configure Google Sheets:"
echo "   - Create a Google Sheet with the required columns"
echo "   - Create a service account"
echo "   - Share the sheet with the service account"
echo "   - Update assets/config/google_sheets_config.dart"
echo ""
echo "3. Set up environment variables:"
echo "   - Copy .env.template to .env"
echo "   - Fill in your actual configuration values"
echo ""
echo "4. Run the app:"
echo "   - flutter run"
echo ""
echo "🚀 Happy coding!"

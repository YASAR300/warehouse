@echo off
REM Warehouse Container Tracker Setup Script for Windows
REM This script helps set up the development environment

echo 🚀 Setting up Warehouse Container Tracker...

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed.
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Check Flutter version
echo 📱 Checking Flutter version...
flutter --version

REM Check if Flutter doctor passes
echo 🔍 Running Flutter doctor...
flutter doctor

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Create necessary directories
echo 📁 Creating necessary directories...
if not exist "assets\images" mkdir "assets\images"
if not exist "assets\config" mkdir "assets\config"
if not exist "android\app\src\main\res\drawable" mkdir "android\app\src\main\res\drawable"
if not exist "ios\Runner\Assets.xcassets\AppIcon.appiconset" mkdir "ios\Runner\Assets.xcassets\AppIcon.appiconset"

REM Create placeholder files
echo 📄 Creating placeholder files...

REM Create Firebase configuration template
echo // Firebase Configuration Template > assets\config\firebase_config.dart
echo // Replace with your actual Firebase configuration >> assets\config\firebase_config.dart
echo. >> assets\config\firebase_config.dart
echo class FirebaseConfig { >> assets\config\firebase_config.dart
echo   // Firebase Project Configuration >> assets\config\firebase_config.dart
echo   static const String projectId = 'your-project-id'; >> assets\config\firebase_config.dart
echo   static const String storageBucket = 'your-project-id.appspot.com'; >> assets\config\firebase_config.dart
echo   static const String messagingSenderId = 'your-sender-id'; >> assets\config\firebase_config.dart
echo. >> assets\config\firebase_config.dart
echo   // Android Configuration >> assets\config\firebase_config.dart
echo   static const String androidAppId = 'your-android-app-id'; >> assets\config\firebase_config.dart
echo. >> assets\config\firebase_config.dart
echo   // iOS Configuration >> assets\config\firebase_config.dart
echo   static const String iosAppId = 'your-ios-app-id'; >> assets\config\firebase_config.dart
echo. >> assets\config\firebase_config.dart
echo   // API Keys (if needed) >> assets\config\firebase_config.dart
echo   static const String apiKey = 'your-api-key'; >> assets\config\firebase_config.dart
echo } >> assets\config\firebase_config.dart

REM Create Google Sheets configuration template
echo // Google Sheets Configuration Template > assets\config\google_sheets_config.dart
echo // Replace with your actual Google Sheets configuration >> assets\config\google_sheets_config.dart
echo. >> assets\config\google_sheets_config.dart
echo class GoogleSheetsConfig { >> assets\config\google_sheets_config.dart
echo   // Spreadsheet Configuration >> assets\config\google_sheets_config.dart
echo   static const String spreadsheetId = 'your-spreadsheet-id'; >> assets\config\google_sheets_config.dart
echo   static const String sheetName = 'Sheet1'; >> assets\config\google_sheets_config.dart
echo   static const String range = 'A:Z'; >> assets\config\google_sheets_config.dart
echo. >> assets\config\google_sheets_config.dart
echo   // Service Account Configuration >> assets\config\google_sheets_config.dart
echo   static const String serviceAccountEmail = 'your-service-account@project.iam.gserviceaccount.com'; >> assets\config\google_sheets_config.dart
echo. >> assets\config\google_sheets_config.dart
echo   // Column Mapping >> assets\config\google_sheets_config.dart
echo   static const Map^<String, String^> columnMapping = { >> assets\config\google_sheets_config.dart
echo     'containerNumber': 'A', >> assets\config\google_sheets_config.dart
echo     'type': 'B', >> assets\config\google_sheets_config.dart
echo     'pieceCount': 'C', >> assets\config\google_sheets_config.dart
echo     'materials': 'D', >> assets\config\google_sheets_config.dart
echo     'doorNumber': 'E', >> assets\config\google_sheets_config.dart
echo     'dateCompleted': 'F', >> assets\config\google_sheets_config.dart
echo     'shareableLink': 'G', >> assets\config\google_sheets_config.dart
echo     'status': 'H', >> assets\config\google_sheets_config.dart
echo     'hasDiscrepancies': 'I', >> assets\config\google_sheets_config.dart
echo     'discrepancies': 'J', >> assets\config\google_sheets_config.dart
echo   }; >> assets\config\google_sheets_config.dart
echo } >> assets\config\google_sheets_config.dart

REM Create environment configuration template
echo # Environment Configuration Template > .env.template
echo # Copy this file to .env and fill in your actual values >> .env.template
echo. >> .env.template
echo # Firebase Configuration >> .env.template
echo FIREBASE_PROJECT_ID=your-project-id >> .env.template
echo FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com >> .env.template
echo FIREBASE_MESSAGING_SENDER_ID=your-sender-id >> .env.template
echo. >> .env.template
echo # Google Sheets Configuration >> .env.template
echo GOOGLE_SHEETS_SPREADSHEET_ID=your-spreadsheet-id >> .env.template
echo GOOGLE_SERVICE_ACCOUNT_JSON=your-service-account-json-base64 >> .env.template
echo. >> .env.template
echo # Admin Configuration >> .env.template
echo ADMIN_EMAIL=admin@yourcompany.com >> .env.template
echo. >> .env.template
echo # App Configuration >> .env.template
echo DEBUG_MODE=true >> .env.template
echo LOG_LEVEL=debug >> .env.template

echo ✅ Setup completed successfully!
echo.
echo 📋 Next steps:
echo 1. Configure Firebase:
echo    - Create a Firebase project
echo    - Enable Storage and Cloud Messaging
echo    - Download google-services.json (Android) and GoogleService-Info.plist (iOS)
echo    - Update assets\config\firebase_config.dart
echo.
echo 2. Configure Google Sheets:
echo    - Create a Google Sheet with the required columns
echo    - Create a service account
echo    - Share the sheet with the service account
echo    - Update assets\config\google_sheets_config.dart
echo.
echo 3. Set up environment variables:
echo    - Copy .env.template to .env
echo    - Fill in your actual configuration values
echo.
echo 4. Run the app:
echo    - flutter run
echo.
echo 🚀 Happy coding!
pause

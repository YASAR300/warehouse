# Quick Start Guide - React Native Version

Get the Warehouse Container Tracker app running in 5 minutes!

## 🚀 Prerequisites

- Node.js 18+ installed
- Android Studio (for Android) or Xcode (for iOS)
- Physical device or emulator

## ⚡ Quick Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

```bash
# Copy example env file
cp .env.example .env

# Edit .env with your credentials
# Minimum required:
# - GOOGLE_SHEETS_API_KEY
# - GOOGLE_SHEETS_SPREADSHEET_ID
# - FIREBASE_STORAGE_BUCKET
```

### 3. Run the App

**Android:**
```bash
npm run android
```

**iOS (macOS only):**
```bash
cd ios && pod install && cd ..
npm run ios
```

## 📱 Test on Device

### Android

1. Enable USB debugging on your device
2. Connect via USB
3. Run: `npm run android`

### iOS

1. Open `ios/WarehouseApp.xcworkspace` in Xcode
2. Select your device
3. Click Run (⌘R)

## 🔧 Common Issues

**Metro bundler not starting?**
```bash
npx react-native start --reset-cache
```

**Build errors?**
```bash
# Clean and rebuild
cd android && ./gradlew clean && cd ..
npm run android
```

**Camera not working?**
- Grant camera permissions in device settings
- Restart the app

## 📖 Full Documentation

See [README.md](./README.md) for complete setup instructions.

## 🆘 Need Help?

1. Check [SETUP_GUIDE.md](../SETUP_GUIDE.md)
2. Review [Troubleshooting](#troubleshooting) section
3. Verify all credentials are correct

---

**That's it!** You should now have the app running on your device. 🎉

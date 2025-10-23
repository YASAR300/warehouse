# 📋 Quick Reference Card - Warehouse Container Tracker

**Print this page for quick access to common tasks and commands**

---

## 🚀 First Time Setup (5 Steps)

1. **Install dependencies**
   - Flutter: `flutter pub get`
   - React Native: `npm install`

2. **Copy environment file**
   - Flutter: `cp env_template.txt .env`
   - React Native: `cp .env.example .env`

3. **Add your credentials to .env**
   - Google Sheets API key
   - Spreadsheet ID
   - Firebase config

4. **Add Firebase config files**
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/` (Flutter) or `ios/` (RN)

5. **Run the app**
   - Flutter: `flutter run`
   - React Native: `npm run android` or `npm run ios`

---

## 📱 Daily Development Commands

### Flutter
```bash
flutter run                    # Run on connected device
flutter run -d android         # Run on Android specifically
flutter run -d ios             # Run on iOS specifically
flutter clean                  # Clean build cache
flutter pub get                # Update dependencies
flutter doctor                 # Check setup
```

### React Native
```bash
npm start                      # Start Metro bundler
npm run android                # Run on Android
npm run ios                    # Run on iOS (macOS only)
npx react-native start --reset-cache  # Clear cache
npm install                    # Update dependencies
```

---

## 🔨 Building Release Versions

### Flutter - Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Flutter - iOS
```bash
flutter build ios --release
# Then open in Xcode and archive
```

### React Native - Android APK
```bash
cd WarehouseAppRN
npm run build:android
# Or use the script:
./build-android.sh  # macOS/Linux
build-android.bat   # Windows
```

### React Native - iOS
```bash
cd WarehouseAppRN
npm run build:ios
# Then open in Xcode and archive
```

---

## 🐛 Troubleshooting Quick Fixes

### Problem: App won't build
**Solution:**
```bash
# Flutter
flutter clean
flutter pub get
flutter run

# React Native
cd android && ./gradlew clean && cd ..
npm install
npm run android
```

### Problem: Camera not working
**Solution:**
1. Check device has camera
2. Grant camera permission in device settings
3. Restart app

### Problem: Google Sheets sync fails
**Solution:**
1. Verify `.env` has correct credentials
2. Check spreadsheet is shared with service account
3. Ensure Google Sheets API is enabled in Cloud Console

### Problem: Firebase upload fails
**Solution:**
1. Verify Firebase config files are in correct location
2. Check Firebase Storage rules allow writes
3. Ensure internet connection

### Problem: Metro bundler won't start (React Native)
**Solution:**
```bash
npx react-native start --reset-cache
```

### Problem: Pod install fails (iOS)
**Solution:**
```bash
cd ios
pod deintegrate
pod install
cd ..
```

---

## 📂 Important File Locations

### Flutter
```
.env                                    # Environment variables
lib/main.dart                          # App entry point
lib/services/google_sheets_service.dart # Sheets integration
android/app/google-services.json       # Firebase Android config
ios/Runner/GoogleService-Info.plist    # Firebase iOS config
```

### React Native
```
.env                                    # Environment variables
App.tsx                                # App entry point
src/services/GoogleSheetsService.ts    # Sheets integration
android/app/google-services.json       # Firebase Android config
ios/GoogleService-Info.plist           # Firebase iOS config
```

---

## 🔑 Required Credentials

### Google Sheets
- **API Key** (React Native)
- **Service Account JSON** (Flutter)
- **Spreadsheet ID** (both)

### Firebase
- **Project ID**
- **Storage Bucket**
- **API Key**
- **Config files** (google-services.json, GoogleService-Info.plist)

### Admin
- **Email address** for notifications

---

## 📊 Google Sheet Column Structure

| Column | Header | Example |
|--------|--------|---------|
| A | Container # | CONT001 |
| B | Type | Import |
| C | Piece Count | 10 Pallets, 5 Crates |
| D | Materials | Pallets, Shrink Wrap |
| E | Door # | Door 3 |
| F | Date Completed | 2025-10-18 |
| G | Shareable Link | https://... |
| H | Status | true |
| I | Has Discrepancies | Yes |
| J | Discrepancies | Damaged crate |

---

## 🎯 App Workflow Cheat Sheet

1. **Open app** → View container list
2. **Tap +** → Create new container
3. **Enter details** → Container #, Type, Door #
4. **Add piece counts** → Tap "+ Add", select type & quantity
5. **Select materials** → Tap materials field, multi-select
6. **Take photos** → Tap "Take Photo", use camera
7. **Report issues** → Tap "+ Add" in Discrepancies
8. **Complete** → Tap "Complete Container"
   - PDF generated
   - Uploaded to cloud
   - Google Sheets updated
   - Row turns green
   - Admin notified (if discrepancies)

---

## 🔧 Common Configuration Changes

### Change App Name
**Flutter:** Edit `pubspec.yaml` line 1
**React Native:** Edit `app.json`

### Change Spreadsheet ID
**Flutter:** Edit `lib/services/google_sheets_service.dart` line 10
**React Native:** Edit `.env` file

### Change Admin Email
**Both:** Edit `.env` file

### Change App Colors
**Flutter:** Edit `lib/main.dart` theme section
**React Native:** Edit styles in each screen file

---

## 📞 Getting Help

### Documentation
1. **README_MASTER.md** - Overview
2. **PROJECT_SUMMARY.md** - Complete features
3. **SETUP_GUIDE.md** - Detailed setup
4. **COMPARISON.md** - Flutter vs React Native

### Online Resources
- Flutter: https://flutter.dev/docs
- React Native: https://reactnative.dev/docs
- Firebase: https://firebase.google.com/docs
- Google Sheets API: https://developers.google.com/sheets/api

---

## ✅ Pre-Deployment Checklist

- [ ] Tested on multiple devices
- [ ] Camera works in low light
- [ ] Offline mode tested
- [ ] Google Sheets sync verified
- [ ] PDF generation tested with 20+ photos
- [ ] Discrepancy notifications work
- [ ] All credentials secured
- [ ] Firebase rules updated for production
- [ ] App icons and splash screens added
- [ ] Version numbers updated

---

## 🎓 Training Your Team

### For Warehouse Staff
1. Show how to create container
2. Demonstrate photo capture
3. Explain piece count entry
4. Show how to report discrepancies
5. Practice completing container

### For Developers
1. Review architecture documentation
2. Understand Google Sheets integration
3. Learn Firebase Storage setup
4. Practice building release versions
5. Know troubleshooting steps

---

## 📈 Performance Tips

### Optimize Photo Size
- Photos auto-compress to <2MB
- Take photos in good lighting
- Avoid taking 50+ photos per container

### Improve Sync Speed
- Ensure good internet connection
- Sync during off-peak hours
- Use WiFi instead of cellular when possible

### Reduce App Size
- Remove unused dependencies
- Enable ProGuard (Android)
- Optimize images and assets

---

## 🔐 Security Reminders

- ✅ Never commit `.env` to git
- ✅ Keep service account JSON secure
- ✅ Rotate API keys regularly
- ✅ Use Firebase authentication in production
- ✅ Review Storage rules before launch
- ✅ Enable HTTPS only
- ✅ Validate all user inputs

---

## 📱 Device Requirements

### Minimum Requirements
- **Android**: 6.0+ (API 23+)
- **iOS**: 12.0+
- **RAM**: 2GB+
- **Storage**: 100MB free
- **Camera**: Required
- **Internet**: Required for sync

### Recommended
- **Android**: 10.0+
- **iOS**: 14.0+
- **RAM**: 4GB+
- **Storage**: 500MB free
- **Camera**: 8MP+
- **Internet**: WiFi or 4G+

---

## 🎯 Success Metrics

Track these to measure app success:
- Containers processed per day
- Average time per container
- Photo quality (clear/blurry ratio)
- Sync success rate
- Discrepancy report rate
- User satisfaction score

---

**Keep this card handy for quick reference!**

**Need more details? See [README_MASTER.md](./README_MASTER.md)**

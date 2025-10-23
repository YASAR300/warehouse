# Warehouse Container Tracker - React Native Edition

A production-ready mobile app for warehouse staff to track container loading/unloading operations with real-time Google Sheets integration, photo capture, and PDF report generation.

## 🚀 Features

### Core Functionality
- **In-App Camera**: Take photos directly without leaving the app
- **Photo Management**: Reorder, rotate, and delete photos with drag-and-drop
- **Real-time Sync**: Automatic synchronization with Google Sheets
- **PDF Generation**: Professional loading/stripping reports with embedded photos
- **Offline Support**: Queue operations when offline, auto-sync when online
- **Discrepancy Tracking**: Report and track issues with notifications

### Key Capabilities
- ✅ Container number tracking
- ✅ Import/Export/Delivery type selection
- ✅ Piece count recording (quantity + package type)
- ✅ Materials supplied tracking (Pallets, Shrink Wrap, Air Bags, Dunnage)
- ✅ Discrepancy reporting with timestamps
- ✅ Photo capture with flash control
- ✅ Cloud storage with shareable links
- ✅ Row coloring in Google Sheets on completion
- ✅ Admin notifications for discrepancies

## 📱 Tech Stack

- **Framework**: React Native 0.73
- **Navigation**: React Navigation 6
- **State Management**: React Context API
- **Camera**: react-native-vision-camera
- **PDF Generation**: react-native-pdf-lib
- **Cloud Storage**: Firebase Storage
- **Google Sheets**: Google Sheets API v4
- **Offline Storage**: AsyncStorage
- **Image Processing**: react-native-image-resizer

## 📋 Prerequisites

Before setting up the app, ensure you have:

1. **Node.js** (18 or higher)
2. **React Native CLI** or **Expo CLI**
3. **Android Studio** (for Android development)
4. **Xcode** (for iOS development, macOS only)
5. **Google Cloud Project** with Sheets API enabled
6. **Firebase Project** with Storage enabled
7. **Google Sheet** with proper column structure

## 🔧 Installation & Setup

### 1. Clone and Install Dependencies

```bash
cd WarehouseAppRN
npm install
```

### 2. Configure Environment Variables

Copy `.env.example` to `.env` and fill in your credentials:

```bash
cp .env.example .env
```

Edit `.env` with your actual values:

```env
GOOGLE_SHEETS_API_KEY=your-api-key
GOOGLE_SHEETS_SPREADSHEET_ID=your-spreadsheet-id
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-bucket.appspot.com
ADMIN_EMAIL=admin@yourcompany.com
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Storage
4. Add iOS and Android apps

#### Download Configuration Files
- **Android**: Download `google-services.json` → place in `android/app/`
- **iOS**: Download `GoogleService-Info.plist` → place in `ios/WarehouseApp/`

#### Update Firebase Rules
Set Storage rules to allow authenticated uploads:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Google Sheets Setup

#### Create Service Account
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Google Sheets API
3. Create service account and download JSON key
4. Add service account email to your spreadsheet with Editor permissions

#### Configure Google Sheet
Create a sheet with these columns:
- **A**: Container #
- **B**: Type (Import/Export/Delivery)
- **C**: Piece Count Summary
- **D**: Materials Supplied
- **E**: Door #
- **F**: Date Completed
- **G**: Shareable Link
- **H**: Status (true/false)
- **I**: Has Discrepancies (Yes/No)
- **J**: Discrepancies

### 5. iOS Setup (macOS only)

```bash
cd ios
pod install
cd ..
```

### 6. Android Setup

Update `android/local.properties` with your Android SDK path:

```properties
sdk.dir=/Users/YOUR_USERNAME/Library/Android/sdk
```

## 🏃 Running the App

### Development Mode

**Android:**
```bash
npm run android
```

**iOS:**
```bash
npm run ios
```

**Start Metro Bundler:**
```bash
npm start
```

### Production Builds

**Android APK:**
```bash
npm run build:android
# Output: android/app/build/outputs/apk/release/app-release.apk
```

**iOS Archive:**
```bash
npm run build:ios
# Then open in Xcode and archive
```

## 📱 Usage Guide

### Basic Workflow

1. **Open App** → View list of containers
2. **Create Container** → Tap "+" button
3. **Enter Details** → Fill container number, type, door number
4. **Add Piece Counts** → Record quantities and package types
5. **Select Materials** → Choose materials supplied
6. **Take Photos** → Use in-app camera
7. **Report Discrepancies** → Add any issues found
8. **Complete** → Generate PDF and sync to Google Sheets

### Photo Management

- **Take Photo**: Tap camera button, use flash if needed
- **Reorder**: Long press and drag photos in gallery
- **Rotate**: Tap rotate icon on photo
- **Delete**: Tap trash icon on photo

### Offline Mode

- App automatically detects offline status
- Changes are queued locally
- Auto-sync when connection restored
- Manual sync available in Settings

## 🔧 Configuration

### Camera Settings

Modify camera quality in `src/screens/CameraScreen.tsx`:

```typescript
const photo = await camera.current.takePhoto({
  flash: flashMode,
  qualityPrioritization: 'quality', // or 'speed'
});
```

### PDF Customization

Edit PDF template in `src/services/StorageService.ts`:

```typescript
// Customize colors, fonts, layout
.drawText('Your Company Name', {
  x: 20,
  y: 180,
  color: rgb(0, 0.2, 0.8),
  fontSize: 20,
})
```

### Google Sheets Integration

Update column mapping in `src/services/GoogleSheetsService.ts`:

```typescript
private containerToRow(container: Container): any[] {
  return [
    container.containerNumber,
    container.type,
    // Add more columns as needed
  ];
}
```

## 🚨 Troubleshooting

### Common Issues

#### Camera Not Working
- **Issue**: Black screen or permission denied
- **Solution**: Check permissions in device settings
  - Android: Settings → Apps → Warehouse Tracker → Permissions
  - iOS: Settings → Privacy → Camera

#### Google Sheets Sync Fails
- **Issue**: "Failed to sync with Google Sheets"
- **Solution**: 
  - Verify API key is correct
  - Check spreadsheet ID
  - Ensure service account has Editor access

#### Firebase Upload Errors
- **Issue**: "Failed to upload photos"
- **Solution**:
  - Verify Firebase configuration
  - Check Storage rules
  - Ensure internet connection

#### Build Errors

**Android:**
```bash
cd android
./gradlew clean
cd ..
npm run android
```

**iOS:**
```bash
cd ios
pod deintegrate
pod install
cd ..
npm run ios
```

## 📊 Data Structure

### Container Model

```typescript
interface Container {
  id: string;
  containerNumber: string;
  type: ContainerType;
  pieceCounts: PieceCount[];
  materialsSupplied: MaterialType[];
  discrepancies: Discrepancy[];
  photoPaths: string[];
  doorNumber?: string;
  completedAt?: Date;
  shareableLink?: string;
  isCompleted: boolean;
}
```

## 🔒 Security

### Best Practices
- Store API keys in `.env` (never commit to git)
- Use Firebase Security Rules
- Implement proper authentication
- Validate all user inputs
- Sanitize data before Google Sheets sync

### Permissions Required
- **Camera**: Photo capture
- **Storage**: Save photos and PDFs
- **Internet**: API calls and sync

## 🚀 Deployment

### Android Play Store

1. Generate signing key:
```bash
keytool -genkeypair -v -storetype PKCS12 -keystore warehouse.keystore -alias warehouse -keyalg RSA -keysize 2048 -validity 10000
```

2. Update `android/gradle.properties`:
```properties
WAREHOUSE_UPLOAD_STORE_FILE=warehouse.keystore
WAREHOUSE_UPLOAD_KEY_ALIAS=warehouse
WAREHOUSE_UPLOAD_STORE_PASSWORD=your-password
WAREHOUSE_UPLOAD_KEY_PASSWORD=your-password
```

3. Build release APK:
```bash
npm run build:android
```

4. Upload to Google Play Console

### iOS App Store

1. Open in Xcode:
```bash
open ios/WarehouseApp.xcworkspace
```

2. Select "Any iOS Device" target
3. Product → Archive
4. Upload to App Store Connect
5. Submit for review

## 📈 Performance Optimization

### Image Optimization
- Photos automatically compressed to reduce size
- Thumbnails generated for faster loading
- Background processing for large images

### Network Optimization
- Batch API calls when possible
- Retry logic for failed requests
- Connection pooling

### Storage Optimization
- Automatic cleanup of temporary files
- Efficient data serialization
- Local caching for offline access

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create feature branch
3. Make changes
4. Test on both iOS and Android
5. Submit pull request

### Code Style
- Follow React Native best practices
- Use TypeScript for type safety
- Add comments for complex logic
- Format with Prettier

## 📄 License

MIT License - See LICENSE file for details

## 📞 Support

For issues and questions:
- Create an issue in the repository
- Check troubleshooting section
- Review documentation

## 🔄 Version History

### Version 1.0.0
- Initial release
- Core container tracking
- Google Sheets integration
- Firebase Storage support
- PDF report generation
- Photo management
- Offline mode

### Planned Features
- Barcode scanning
- Multi-language support
- Advanced analytics
- Container movement tracking
- Driver app integration
- Chassis number management

---

**Note**: This is a production-ready app designed for warehouse operations. Ensure all prerequisites are met and properly configured before deployment.

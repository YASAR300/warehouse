import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for managing environment variables from .env file
class EnvironmentService {
  static bool _isInitialized = false;

  /// Initialize environment variables from .env file
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load .env file
      await dotenv.load(fileName: ".env");
      _isInitialized = true;
    } catch (e) {
      // If .env file doesn't exist, use system environment variables
      _isInitialized = true;
    }
  }

  /// Get environment variable value
  static String? get(String key) {
    if (!_isInitialized) {
      throw Exception('EnvironmentService not initialized. Call initialize() first.');
    }

    // First try to get from .env file
    String? value = dotenv.env[key];
    
    // If not found in .env, try system environment
    value ??= Platform.environment[key];

    return value;
  }

  /// Get environment variable with default value
  static String getOrDefault(String key, String defaultValue) {
    return get(key) ?? defaultValue;
  }

  /// Get boolean environment variable
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = get(key);
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// Get integer environment variable
  static int getInt(String key, {int defaultValue = 0}) {
    final value = get(key);
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Get double environment variable
  static double getDouble(String key, {double defaultValue = 0.0}) {
    final value = get(key);
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  /// Check if environment variable exists
  static bool has(String key) {
    return get(key) != null;
  }

  /// Get all environment variables
  static Map<String, String> getAll() {
    if (!_isInitialized) {
      throw Exception('EnvironmentService not initialized. Call initialize() first.');
    }

    final Map<String, String> allVars = {};
    
    // Add .env variables
    allVars.addAll(dotenv.env);
    
    // Add system environment variables (don't override .env)
    Platform.environment.forEach((key, value) {
      if (!allVars.containsKey(key)) {
        allVars[key] = value;
      }
    });

    return allVars;
  }

  /// Firebase Configuration
  static String get firebaseProjectId => getOrDefault('FIREBASE_PROJECT_ID', '');
  static String get firebaseStorageBucket => getOrDefault('FIREBASE_STORAGE_BUCKET', '');
  static String get firebaseMessagingSenderId => getOrDefault('FIREBASE_MESSAGING_SENDER_ID', '');
  static String get firebaseApiKey => getOrDefault('FIREBASE_API_KEY', '');

  /// Google Sheets Configuration
  static String get googleSheetsSpreadsheetId => getOrDefault('GOOGLE_SHEETS_SPREADSHEET_ID', '');
  static String get googleServiceAccountEmail => getOrDefault('GOOGLE_SERVICE_ACCOUNT_EMAIL', '');
  static String get googleServiceAccountJson => getOrDefault('GOOGLE_SERVICE_ACCOUNT_JSON', '');

  /// Admin Configuration
  static String get adminEmail => getOrDefault('ADMIN_EMAIL', 'admin@company.com');

  /// App Configuration
  static String get appName => getOrDefault('APP_NAME', 'Warehouse Container Tracker');
  static String get appVersion => getOrDefault('APP_VERSION', '1.0.0');
  static bool get debugMode => getBool('DEBUG_MODE', defaultValue: true);
  static String get logLevel => getOrDefault('LOG_LEVEL', 'debug');

  /// Offline Configuration
  static int get offlineQueueSizeLimit => getInt('OFFLINE_QUEUE_SIZE_LIMIT', defaultValue: 100);
  static int get offlineSyncIntervalMinutes => getInt('OFFLINE_SYNC_INTERVAL_MINUTES', defaultValue: 5);

  /// Camera Configuration
  static String get cameraResolution => getOrDefault('CAMERA_RESOLUTION', 'high');
  static int get photoCompressionQuality => getInt('PHOTO_COMPRESSION_QUALITY', defaultValue: 85);
  static int get maxPhotoSizeMB => getInt('MAX_PHOTO_SIZE_MB', defaultValue: 10);

  /// PDF Configuration
  static String get pdfPageFormat => getOrDefault('PDF_PAGE_FORMAT', 'A4');
  static int get pdfMarginMM => getInt('PDF_MARGIN_MM', defaultValue: 20);
  static int get pdfFontSize => getInt('PDF_FONT_SIZE', defaultValue: 12);

  /// Storage Configuration
  static int get tempFileCleanupHours => getInt('TEMP_FILE_CLEANUP_HOURS', defaultValue: 24);
  static int get maxFileSizeMB => getInt('MAX_FILE_SIZE_MB', defaultValue: 50);

  /// Validate required environment variables
  static List<String> validateRequired() {
    final List<String> missing = [];
    
    final requiredVars = [
      'FIREBASE_PROJECT_ID',
      'FIREBASE_STORAGE_BUCKET',
      'GOOGLE_SHEETS_SPREADSHEET_ID',
      'ADMIN_EMAIL',
    ];

    for (final varName in requiredVars) {
      if (!has(varName) || get(varName)!.isEmpty) {
        missing.add(varName);
      }
    }

    return missing;
  }

  /// Print environment configuration (for debugging)
  static void printConfig() {
    if (!_isInitialized) {
      return;
    }
    // Environment configuration available for debugging
  }
}

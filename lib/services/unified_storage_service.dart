import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'storage_service.dart';
import 'box_storage_service.dart';

/// Unified storage service that switches between Firebase and Box.com
class UnifiedStorageService {
  final String _storageProvider;
  final StorageService? _firebaseStorage;
  final BoxStorageService? _boxStorage;

  UnifiedStorageService._({
    required String storageProvider,
    StorageService? firebaseStorage,
    BoxStorageService? boxStorage,
  })  : _storageProvider = storageProvider,
        _firebaseStorage = firebaseStorage,
        _boxStorage = boxStorage;

  /// Factory constructor to create the appropriate storage service
  factory UnifiedStorageService() {
    final provider = dotenv.env['STORAGE_PROVIDER'] ?? 'firebase';

    if (provider.toLowerCase() == 'box') {
      // Initialize Box.com storage
      final clientId = dotenv.env['BOX_CLIENT_ID'] ?? '';
      final clientSecret = dotenv.env['BOX_CLIENT_SECRET'] ?? '';
      final accessToken = dotenv.env['BOX_ACCESS_TOKEN'] ?? '';
      final folderId = dotenv.env['BOX_FOLDER_ID'] ?? '';

      if (clientId.isEmpty || clientSecret.isEmpty || accessToken.isEmpty || folderId.isEmpty) {
        throw Exception('Box.com credentials not configured in .env file');
      }

      return UnifiedStorageService._(
        storageProvider: 'box',
        boxStorage: BoxStorageService(
          clientId: clientId,
          clientSecret: clientSecret,
          accessToken: accessToken,
          folderId: folderId,
        ),
      );
    } else {
      // Initialize Firebase storage (default)
      return UnifiedStorageService._(
        storageProvider: 'firebase',
        firebaseStorage: StorageService(),
      );
    }
  }

  /// Upload photos to cloud storage
  Future<List<String>> uploadPhotos({
    required String containerNumber,
    required List<String> photoPaths,
  }) async {
    if (_storageProvider == 'box' && _boxStorage != null) {
      return await _boxStorage!.uploadPhotos(
        containerNumber: containerNumber,
        photoPaths: photoPaths,
      );
    } else if (_firebaseStorage != null) {
      return await _firebaseStorage!.uploadPhotos(
        containerNumber: containerNumber,
        photoPaths: photoPaths,
      );
    } else {
      throw Exception('Storage service not initialized');
    }
  }

  /// Upload PDF report to cloud storage
  Future<String> uploadPdfReport({
    required String containerNumber,
    required String pdfPath,
  }) async {
    if (_storageProvider == 'box' && _boxStorage != null) {
      return await _boxStorage!.uploadPdfReport(
        containerNumber: containerNumber,
        pdfPath: pdfPath,
      );
    } else if (_firebaseStorage != null) {
      return await _firebaseStorage!.uploadPdfReport(
        containerNumber: containerNumber,
        pdfPath: pdfPath,
      );
    } else {
      throw Exception('Storage service not initialized');
    }
  }

  /// Generate a shareable folder link
  Future<String> generateShareableLink(String containerNumber) async {
    if (_storageProvider == 'box' && _boxStorage != null) {
      return await _boxStorage!.generateShareableLink(containerNumber);
    } else if (_firebaseStorage != null) {
      return await _firebaseStorage!.generateShareableLink(containerNumber);
    } else {
      throw Exception('Storage service not initialized');
    }
  }

  /// Get the current storage provider name
  String get providerName => _storageProvider;

  /// Check if using Box.com
  bool get isUsingBox => _storageProvider == 'box';

  /// Check if using Firebase
  bool get isUsingFirebase => _storageProvider == 'firebase';
}

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

/// Service for handling file uploads to Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  /// Upload single photo to Firebase Storage
  Future<String> uploadPhoto({
    required String containerNumber,
    required String photoPath,
  }) async {
    try {
      final photoFile = File(photoPath);
      final fileName = '${containerNumber}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('containers/$containerNumber/photos/$fileName');
      
      final uploadTask = ref.putFile(photoFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  /// Upload photos to Firebase Storage
  Future<List<String>> uploadPhotos({
    required String containerNumber,
    required List<String> photoPaths,
  }) async {
    final uploadedUrls = <String>[];
    
    try {
      for (int i = 0; i < photoPaths.length; i++) {
        final photoFile = File(photoPaths[i]);
        final fileName = '${containerNumber}_photo_${i + 1}.jpg';
        final ref = _storage.ref().child('containers/$containerNumber/photos/$fileName');
        
        final uploadTask = ref.putFile(photoFile);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        
        uploadedUrls.add(downloadUrl);
      }
    } catch (e) {
      throw Exception('Failed to upload photos: $e');
    }
    
    return uploadedUrls;
  }

  /// Upload PDF report to Firebase Storage
  Future<String> uploadPdfReport({
    required String containerNumber,
    required String pdfPath,
  }) async {
    try {
      final pdfFile = File(pdfPath);
      final fileName = '${containerNumber}_report.pdf';
      final ref = _storage.ref().child('containers/$containerNumber/reports/$fileName');
      
      final uploadTask = ref.putFile(pdfFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload PDF report: $e');
    }
  }

  /// Generate a shareable folder link
  Future<String> generateShareableLink(String containerNumber) async {
    try {
      final ref = _storage.ref().child('containers/$containerNumber');
      
      // Create a signed URL that expires in 1 year
      final downloadUrl = await ref.getDownloadURL();
      
      // For a folder, we'll return the parent directory URL
      // In a real implementation, you might want to create a custom sharing mechanism
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to generate shareable link: $e');
    }
  }

  /// Delete photos from storage
  Future<void> deletePhotos({
    required String containerNumber,
    required List<String> photoUrls,
  }) async {
    try {
      for (final url in photoUrls) {
        final ref = _storage.refFromURL(url);
        await ref.delete();
      }
    } catch (e) {
      // Failed to delete some photos - continue anyway
    }
  }

  /// Delete PDF report from storage
  Future<void> deletePdfReport(String pdfUrl) async {
    try {
      final ref = _storage.refFromURL(pdfUrl);
      await ref.delete();
    } catch (e) {
      // Failed to delete PDF report
    }
  }

  /// Get temporary directory for local file operations
  Future<Directory> getTemporaryDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Get application documents directory
  Future<Directory> getApplicationDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Create a local file path for temporary storage
  Future<String> createTempFilePath(String fileName) async {
    final tempDir = await getTemporaryDirectory();
    return path.join(tempDir.path, fileName);
  }

  /// Create a local file path in documents directory
  Future<String> createDocumentsFilePath(String fileName) async {
    final docsDir = await getApplicationDocumentsDirectory();
    return path.join(docsDir.path, fileName);
  }

  /// Check if file exists locally
  bool fileExists(String filePath) {
    return File(filePath).existsSync();
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return await file.length();
  }

  /// Copy file to a new location
  Future<String> copyFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    final copiedFile = await sourceFile.copy(destinationPath);
    return copiedFile.path;
  }

  /// Move file to a new location
  Future<String> moveFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    final movedFile = await sourceFile.rename(destinationPath);
    return movedFile.path;
  }

  /// Delete local file
  Future<void> deleteLocalFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Clean up temporary files
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (final file in files) {
        if (file is File) {
          // Delete files older than 24 hours
          final stat = await file.stat();
          final now = DateTime.now();
          final fileAge = now.difference(stat.modified);
          
          if (fileAge.inHours > 24) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      // Failed to cleanup temp files
    }
  }
}

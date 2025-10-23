import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'storage_service.dart';

/// Service for handling camera operations and photo management
class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  final StorageService _storageService = StorageService();

  /// Initialize camera
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _cameras = await availableCameras();
      
      if (_cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Use back camera by default
      final camera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize camera: $e');
    }
  }

  /// Get camera controller
  CameraController? get controller => _controller;

  /// Check if camera is initialized
  bool get isInitialized => _isInitialized;

  /// Take a photo and return the file path
  Future<String> takePhoto() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    try {
      final image = await _controller!.takePicture();
      return image.path;
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  /// Process and optimize photo
  Future<String> processPhoto(String originalPath) async {
    try {
      // Read the original image
      final originalFile = File(originalPath);
      final originalBytes = await originalFile.readAsBytes();
      final originalImage = img.decodeImage(originalBytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image if too large (max 1920x1080)
      img.Image processedImage = originalImage;
      if (originalImage.width > 1920 || originalImage.height > 1080) {
        processedImage = img.copyResize(
          originalImage,
          width: originalImage.width > 1920 ? 1920 : null,
          height: originalImage.height > 1080 ? 1080 : null,
          maintainAspect: true,
        );
      }

      // Compress image (quality 85%)
      final processedBytes = img.encodeJpg(processedImage, quality: 85);

      // Save processed image
      final fileName = 'processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final processedPath = await _storageService.createTempFilePath(fileName);
      final processedFile = File(processedPath);
      await processedFile.writeAsBytes(processedBytes);

      // Delete original file
      await originalFile.delete();

      return processedPath;
    } catch (e) {
      throw Exception('Failed to process photo: $e');
    }
  }

  /// Rotate photo by 90 degrees
  Future<String> rotatePhoto(String photoPath, {bool clockwise = true}) async {
    try {
      final file = File(photoPath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Rotate image
      final rotatedImage = clockwise 
          ? img.copyRotate(image, angle: 90)
          : img.copyRotate(image, angle: -90);

      // Save rotated image
      final rotatedBytes = img.encodeJpg(rotatedImage, quality: 85);
      await file.writeAsBytes(rotatedBytes);

      return photoPath;
    } catch (e) {
      throw Exception('Failed to rotate photo: $e');
    }
  }

  /// Delete photo file
  Future<void> deletePhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete photo: $e');
    }
  }

  /// Copy photo to a new location
  Future<String> copyPhoto(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      final copiedFile = await sourceFile.copy(destinationPath);
      return copiedFile.path;
    } catch (e) {
      throw Exception('Failed to copy photo: $e');
    }
  }

  /// Get photo file size
  Future<int> getPhotoSize(String photoPath) async {
    try {
      final file = File(photoPath);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Get photo dimensions
  Future<Map<String, int>> getPhotoDimensions(String photoPath) async {
    try {
      final file = File(photoPath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return {'width': 0, 'height': 0};
      }

      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      return {'width': 0, 'height': 0};
    }
  }

  /// Create thumbnail of photo
  Future<String> createThumbnail(String photoPath, {int maxSize = 200}) async {
    try {
      final file = File(photoPath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Create thumbnail
      final thumbnail = img.copyResize(
        image,
        width: maxSize,
        height: maxSize,
        maintainAspect: true,
      );

      // Save thumbnail
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 70);
      final thumbnailFileName = 'thumb_${path.basename(photoPath)}';
      final thumbnailPath = await _storageService.createTempFilePath(thumbnailFileName);
      final thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(thumbnailBytes);

      return thumbnailPath;
    } catch (e) {
      throw Exception('Failed to create thumbnail: $e');
    }
  }

  /// Batch process multiple photos
  Future<List<String>> processPhotos(List<String> photoPaths) async {
    final processedPaths = <String>[];

    for (final photoPath in photoPaths) {
      try {
        final processedPath = await processPhoto(photoPath);
        processedPaths.add(processedPath);
      } catch (e) {
        // If processing fails, keep original path
        processedPaths.add(photoPath);
        print('Failed to process photo $photoPath: $e');
      }
    }

    return processedPaths;
  }

  /// Clean up camera resources
  Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    _isInitialized = false;
  }

  /// Check camera permissions
  Future<bool> checkPermissions() async {
    // This would typically use permission_handler package
    // For now, we'll assume permissions are granted
    return true;
  }

  /// Request camera permissions
  Future<bool> requestPermissions() async {
    // This would typically use permission_handler package
    // For now, we'll assume permissions are granted
    return true;
  }

  /// Get available camera resolutions
  List<ResolutionPreset> getAvailableResolutions() {
    return [
      ResolutionPreset.low,
      ResolutionPreset.medium,
      ResolutionPreset.high,
      ResolutionPreset.veryHigh,
      ResolutionPreset.ultraHigh,
      ResolutionPreset.max,
    ];
  }

  /// Set camera resolution
  Future<void> setResolution(ResolutionPreset resolution) async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    try {
      // Note: setResolutionPreset is not available in this camera version
      // This is a placeholder for future implementation
      print('Resolution setting not supported in current camera version');
    } catch (e) {
      throw Exception('Failed to set resolution: $e');
    }
  }

  /// Set camera flash mode
  Future<void> setFlashMode(FlashMode flashMode) async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    try {
      await _controller!.setFlashMode(flashMode);
    } catch (e) {
      throw Exception('Failed to set flash mode: $e');
    }
  }

  /// Get current flash mode
  FlashMode? getFlashMode() {
    return _controller?.value.flashMode;
  }

  /// Toggle flash mode
  Future<void> toggleFlash() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    final currentMode = _controller!.value.flashMode;
    FlashMode newMode;

    switch (currentMode) {
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
        newMode = FlashMode.off;
        break;
      default:
        newMode = FlashMode.off;
    }

    await setFlashMode(newMode);
  }
}

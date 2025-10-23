import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../services/app_state.dart';
import '../services/camera_service.dart';
import '../models/container_model.dart';

/// Photo gallery screen for managing container photos
class PhotoGalleryScreen extends StatefulWidget {
  final int? initialIndex;

  const PhotoGalleryScreen({
    super.key,
    this.initialIndex,
  });

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  final CameraService _cameraService = CameraService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isCameraInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  /// Initialize camera
  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickFromGallery,
            tooltip: 'Pick from Gallery',
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final container = appState.currentContainer;
          if (container == null) {
            return const Center(
              child: Text('No container selected'),
            );
          }

          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // Camera preview with capture button
              if (_isCameraInitialized) _buildCameraPreview(),
              
              // Photo grid
              Expanded(
                child: _buildPhotoGrid(container),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build camera preview with capture button
  Widget _buildCameraPreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Camera preview
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: CameraPreview(_cameraService.controller!),
            ),
          ),
          // Capture button
          Container(
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Flash toggle
                IconButton(
                  icon: Icon(
                    _cameraService.getFlashMode() == FlashMode.off
                        ? Icons.flash_off
                        : _cameraService.getFlashMode() == FlashMode.auto
                            ? Icons.flash_auto
                            : Icons.flash_on,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await _cameraService.toggleFlash();
                    setState(() {});
                  },
                  tooltip: 'Toggle Flash',
                ),
                // Capture button
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera, size: 28),
                    label: const Text(
                      'CAPTURE PHOTO',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                // Gallery button
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  onPressed: _pickFromGallery,
                  tooltip: 'Pick from Gallery',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build photo grid
  Widget _buildPhotoGrid(ContainerModel container) {
    if (container.photoPaths.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No photos taken yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Use the camera preview above or gallery button',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ReorderableColumn(
      children: container.photoPaths.asMap().entries.map((entry) {
        final index = entry.key;
        final photoPath = entry.value;
        
        return _buildPhotoItem(photoPath, index);
      }).toList(),
      onReorder: (oldIndex, newIndex) {
        context.read<AppState>().reorderPhotos(oldIndex, newIndex);
      },
    );
  }

  /// Build individual photo item
  Widget _buildPhotoItem(String photoPath, int index) {
    return Card(
      key: ValueKey(photoPath),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildPhotoImage(photoPath),
          ),
        ),
        title: Text('Photo ${index + 1}'),
        subtitle: Text(photoPath.split('/').last),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.rotate_left),
              onPressed: () => _rotatePhoto(photoPath, false),
            ),
            IconButton(
              icon: const Icon(Icons.rotate_right),
              onPressed: () => _rotatePhoto(photoPath, true),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deletePhoto(index),
            ),
          ],
        ),
        onTap: () => _showPhotoViewer(photoPath, index),
      ),
    );
  }

  /// Build photo image widget
  Widget _buildPhotoImage(String photoPath) {
    final file = File(photoPath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: Colors.red);
        },
      );
    } else {
      return const Icon(Icons.image_not_supported, color: Colors.grey);
    }
  }

  /// Pick photo from gallery
  Future<void> _pickFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        context.read<AppState>().addPhoto(pickedFile.path);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo added from gallery!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick photo: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Take photo
  Future<void> _takePhoto() async {
    if (!_isCameraInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera not initialized. Please wait...'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final photoPath = await _cameraService.takePhoto();
      final processedPath = await _cameraService.processPhoto(photoPath);
      
      if (mounted) {
        context.read<AppState>().addPhoto(processedPath);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo taken successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Rotate photo
  Future<void> _rotatePhoto(String photoPath, bool clockwise) async {
    try {
      await _cameraService.rotatePhoto(photoPath, clockwise: clockwise);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo rotated ${clockwise ? 'clockwise' : 'counterclockwise'}'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to rotate photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Delete photo
  void _deletePhoto(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppState>().removePhoto(index);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Photo deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Show photo viewer
  void _showPhotoViewer(String photoPath, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(
          photoPath: photoPath,
          index: index,
        ),
      ),
    );
  }
}

/// Photo viewer screen for full-screen photo viewing
class PhotoViewerScreen extends StatelessWidget {
  final String photoPath;
  final int index;

  const PhotoViewerScreen({
    super.key,
    required this.photoPath,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo ${index + 1}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          child: _buildFullImage(photoPath),
        ),
      ),
    );
  }

  /// Build full image widget
  Widget _buildFullImage(String photoPath) {
    final file = File(photoPath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.broken_image,
            size: 100,
            color: Colors.white,
          );
        },
      );
    } else {
      return const Icon(
        Icons.image_not_supported,
        size: 100,
        color: Colors.white,
      );
    }
  }
}

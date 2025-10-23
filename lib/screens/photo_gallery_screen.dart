import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:camera/camera.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initialize camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _isCameraInitialized ? _takePhoto : null,
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
              // Camera preview
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

  /// Build camera preview
  Widget _buildCameraPreview() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CameraPreview(_cameraService.controller!),
      ),
    );
  }

  /// Build photo grid
  Widget _buildPhotoGrid(ContainerModel container) {
    if (container.photoPaths.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No photos taken yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the camera button to take photos',
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
            child: Image.asset(
              'assets/images/placeholder.png', // Placeholder
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image);
              },
            ),
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

  /// Take photo
  Future<void> _takePhoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final photoPath = await _cameraService.takePhoto();
      final processedPath = await _cameraService.processPhoto(photoPath);
      
      context.read<AppState>().addPhoto(processedPath);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo taken successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to take photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Rotate photo
  Future<void> _rotatePhoto(String photoPath, bool clockwise) async {
    try {
      await _cameraService.rotatePhoto(photoPath, clockwise: clockwise);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo rotated ${clockwise ? 'clockwise' : 'counterclockwise'}'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to rotate photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
          child: Image.asset(
            'assets/images/placeholder.png', // Placeholder
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image,
                size: 100,
                color: Colors.white,
              );
            },
          ),
        ),
      ),
    );
  }
}

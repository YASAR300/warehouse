import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/container_model.dart';

/// Service for handling offline operations and connectivity
class OfflineService {
  static const String _offlineQueueKey = 'offline_queue';
  static const String _connectivityKey = 'last_connectivity_status';
  
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  List<ContainerModel> _offlineQueue = [];

  /// Initialize offline service
  Future<void> initialize() async {
    await _loadOfflineQueue();
    await checkConnectivity();
    _setupConnectivityListener();
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;
      await _saveConnectivityStatus(_isOnline);
      return _isOnline;
    } catch (e) {
      _isOnline = false;
      return false;
    }
  }

  /// Setup connectivity listener
  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      
      if (!wasOnline && _isOnline) {
        // Just came online - trigger sync
        _onConnectivityRestored();
      }
    });
  }

  /// Handle connectivity restoration
  void _onConnectivityRestored() {
    // This would typically trigger a sync operation
  }

  /// Add container to offline queue
  Future<void> addToOfflineQueue(ContainerModel container) async {
    _offlineQueue.add(container);
    await _saveOfflineQueue();
  }

  /// Remove container from offline queue
  Future<void> removeFromOfflineQueue(ContainerModel container) async {
    _offlineQueue.removeWhere((c) => c.containerNumber == container.containerNumber);
    await _saveOfflineQueue();
  }

  /// Get offline queue
  List<ContainerModel> get offlineQueue => List.unmodifiable(_offlineQueue);

  /// Check if container is in offline queue
  bool isInOfflineQueue(String containerNumber) {
    return _offlineQueue.any((c) => c.containerNumber == containerNumber);
  }

  /// Load offline queue from SharedPreferences
  Future<void> _loadOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_offlineQueueKey);
      
      if (queueJson != null) {
        final List<dynamic> queueList = json.decode(queueJson);
        _offlineQueue = queueList
            .map((json) => ContainerModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _offlineQueue = [];
    }
  }

  /// Save offline queue to SharedPreferences
  Future<void> _saveOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = json.encode(
        _offlineQueue.map((container) => container.toJson()).toList(),
      );
      await prefs.setString(_offlineQueueKey, queueJson);
    } catch (e) {
      // Failed to save offline queue
    }
  }

  /// Save connectivity status
  Future<void> _saveConnectivityStatus(bool isOnline) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_connectivityKey, isOnline);
    } catch (e) {
      // Failed to save connectivity status
    }
  }

  /// Clear offline queue
  Future<void> clearOfflineQueue() async {
    _offlineQueue.clear();
    await _saveOfflineQueue();
  }

  /// Get offline queue size
  int get offlineQueueSize => _offlineQueue.length;

  /// Check if app is currently online
  bool get isOnline => _isOnline;

  /// Check if app is currently offline
  bool get isOffline => !_isOnline;

  /// Get containers that need to be synced
  List<ContainerModel> getContainersToSync() {
    return _offlineQueue.where((container) => 
      container.isCompleted && !container.shareableLink.isNullOrEmpty
    ).toList();
  }

  /// Mark container as synced
  Future<void> markContainerAsSynced(String containerNumber) async {
    final container = _offlineQueue.firstWhere(
      (c) => c.containerNumber == containerNumber,
      orElse: () => throw StateError('Container not found in offline queue'),
    );
    
    _offlineQueue.remove(container);
    await _saveOfflineQueue();
  }

  /// Get sync statistics
  Map<String, int> getSyncStatistics() {
    final totalContainers = _offlineQueue.length;
    final completedContainers = _offlineQueue.where((c) => c.isCompleted).length;
    final pendingContainers = totalContainers - completedContainers;
    
    return {
      'total': totalContainers,
      'completed': completedContainers,
      'pending': pendingContainers,
    };
  }

  /// Check if sync is needed
  bool get needsSync => _offlineQueue.isNotEmpty && _isOnline;

  /// Get estimated sync time (in seconds)
  int getEstimatedSyncTime() {
    // Rough estimate: 2 seconds per container
    return _offlineQueue.length * 2;
  }

  /// Validate offline data integrity
  Future<bool> validateOfflineData() async {
    try {
      for (final container in _offlineQueue) {
        // Check if container has required fields
        if (container.containerNumber.isEmpty) {
          return false;
        }
        
        // Check if photos exist locally
        for (final photoPath in container.photoPaths) {
          if (!File(photoPath).existsSync()) {
            return false;
          }
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clean up invalid offline data
  Future<void> cleanupInvalidData() async {
    final validContainers = <ContainerModel>[];
    
    for (final container in _offlineQueue) {
      bool isValid = true;
      
      // Check if container has required fields
      if (container.containerNumber.isEmpty) {
        isValid = false;
      }
      
      // Check if photos exist locally
      for (final photoPath in container.photoPaths) {
        if (!File(photoPath).existsSync()) {
          isValid = false;
          break;
        }
      }
      
      if (isValid) {
        validContainers.add(container);
      }
    }
    
    _offlineQueue = validContainers;
    await _saveOfflineQueue();
  }

  /// Export offline data for debugging
  Future<Map<String, dynamic>> exportOfflineData() async {
    return {
      'queueSize': _offlineQueue.length,
      'isOnline': _isOnline,
      'containers': _offlineQueue.map((c) => c.toJson()).toList(),
      'statistics': getSyncStatistics(),
    };
  }

  /// Import offline data (for testing/debugging)
  Future<void> importOfflineData(List<ContainerModel> containers) async {
    _offlineQueue.addAll(containers);
    await _saveOfflineQueue();
  }
}

/// Extension for null safety
extension NullSafetyExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

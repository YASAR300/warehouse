import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/container_model.dart';

/// Main app state management using Provider
class AppState extends ChangeNotifier {
  List<ContainerModel> _containers = [];
  ContainerModel? _currentContainer;
  bool _isLoading = false;
  bool _isOffline = false;
  List<ContainerModel> _offlineQueue = [];
  String? _adminEmail;

  // Getters
  List<ContainerModel> get containers => _containers;
  ContainerModel? get currentContainer => _currentContainer;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  List<ContainerModel> get offlineQueue => _offlineQueue;
  String? get adminEmail => _adminEmail;

  /// Initialize app state
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      // Load offline queue
      await _loadOfflineQueue();
      
      // Load admin email
      await _loadAdminEmail();
      
      // Check network status
      _checkNetworkStatus();
    } catch (e) {
      debugPrint('Failed to initialize app state: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set offline state
  void setOffline(bool offline) {
    _isOffline = offline;
    notifyListeners();
  }

  /// Load containers from Google Sheets
  Future<void> loadContainers() async {
    _setLoading(true);
    
    try {
      // This would typically load from Google Sheets service
      // For now, we'll use mock data
      _containers = _getMockContainers();
    } catch (e) {
      debugPrint('Failed to load containers: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set current container
  void setCurrentContainer(ContainerModel? container) {
    _currentContainer = container;
    notifyListeners();
  }

  /// Create new container
  void createNewContainer(String containerNumber, ContainerType type) {
    final container = ContainerModel(
      containerNumber: containerNumber,
      type: type,
    );
    
    _currentContainer = container;
    notifyListeners();
  }

  /// Update current container
  void updateCurrentContainer(ContainerModel container) {
    _currentContainer = container;
    notifyListeners();
  }

  /// Add piece count to current container
  void addPieceCount(PieceCount pieceCount) {
    if (_currentContainer == null) return;
    
    final updatedContainer = _currentContainer!.copyWith(
      pieceCounts: [..._currentContainer!.pieceCounts, pieceCount],
    );
    
    _currentContainer = updatedContainer;
    notifyListeners();
  }

  /// Remove piece count from current container
  void removePieceCount(int index) {
    if (_currentContainer == null || index < 0 || index >= _currentContainer!.pieceCounts.length) return;
    
    final pieceCounts = List<PieceCount>.from(_currentContainer!.pieceCounts);
    pieceCounts.removeAt(index);
    
    final updatedContainer = _currentContainer!.copyWith(
      pieceCounts: pieceCounts,
    );
    
    _currentContainer = updatedContainer;
    notifyListeners();
  }

  /// Add material to current container
  void addMaterial(MaterialType material) {
    if (_currentContainer == null) return;
    
    final materials = List<MaterialType>.from(_currentContainer!.materialsSupplied);
    if (!materials.contains(material)) {
      materials.add(material);
    }
    
    final updatedContainer = _currentContainer!.copyWith(
      materialsSupplied: materials,
    );
    
    _currentContainer = updatedContainer;
    notifyListeners();
  }

  /// Remove material from current container
  void removeMaterial(MaterialType material) {
    if (_currentContainer == null) return;
    
    final materials = List<MaterialType>.from(_currentContainer!.materialsSupplied);
    materials.remove(material);
    
    final updatedContainer = _currentContainer!.copyWith(
      materialsSupplied: materials,
    );
    
    _currentContainer = updatedContainer;
    notifyListeners();
  }

  /// Add discrepancy to current container
  void addDiscrepancy(Discrepancy discrepancy) {
    if (_currentContainer == null) return;
    
    final discrepancies = List<Discrepancy>.from(_currentContainer!.discrepancies);
    discrepancies.add(discrepancy);
    
    final updatedContainer = _currentContainer!.copyWith(
      discrepancies: discrepancies,
    );
    
    _currentContainer = updatedContainer;
    notifyListeners();
  }

  /// Remove discrepancy from current container
  void removeDiscrepancy(int index) {
    if (_currentContainer == null || index < 0 || index >= _currentContainer!.discrepancies.length) return;
    
    final discrepancies = List<Discrepancy>.from(_currentContainer!.discrepancies);
    discrepancies.removeAt(index);
    
    final updatedContainer = _currentContainer!.copyWith(
      discrepancies: discrepancies,
    );
    
    _currentContainer = updatedContainer;
    notifyListeners();
  }

  /// Add photo to current container
  void addPhoto(String photoPath) {
    if (_currentContainer == null) return;
    
    final photoPaths = List<String>.from(_currentContainer!.photoPaths);
    photoPaths.add(photoPath);
    
    final updatedContainer = _currentContainer!.copyWith(
      photoPaths: photoPaths,
    );
    
    _currentContainer = updatedContainer;
    notifyListeners();
  }

  /// Remove photo from current container
  void removePhoto(int index) {
    if (_currentContainer == null || index < 0 || index >= _currentContainer!.photoPaths.length) return;
    
    final photoPaths = List<String>.from(_currentContainer!.photoPaths);
    photoPaths.removeAt(index);
    
    final updatedContainer = _currentContainer!.copyWith(
      photoPaths: photoPaths,
    );
    
    _currentContainer = updatedContainer;
    notifyListeners();
  }

  /// Reorder photos
  void reorderPhotos(int oldIndex, int newIndex) {
    if (_currentContainer == null) return;
    
    final photoPaths = List<String>.from(_currentContainer!.photoPaths);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final item = photoPaths.removeAt(oldIndex);
    photoPaths.insert(newIndex, item);
    
    final updatedContainer = _currentContainer!.copyWith(
      photoPaths: photoPaths,
    );
    
    _currentContainer = updatedContainer;
    notifyListeners();
  }

  /// Set door number
  void setDoorNumber(String doorNumber) {
    if (_currentContainer == null) return;
    
    final updatedContainer = _currentContainer!.copyWith(
      doorNumber: doorNumber,
    );
    
    _currentContainer = updatedContainer;
    notifyListeners();
  }

  /// Complete container
  Future<void> completeContainer() async {
    if (_currentContainer == null) return;
    
    final completedContainer = _currentContainer!.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
    
    if (_isOffline) {
      // Add to offline queue
      await _addToOfflineQueue(completedContainer);
    } else {
      // Save to Google Sheets and upload files
      await _saveContainer(completedContainer);
    }
    
    // Add to containers list
    _containers.add(completedContainer);
    
    // Clear current container
    _currentContainer = null;
    notifyListeners();
  }

  /// Save container to Google Sheets and upload files
  Future<void> _saveContainer(ContainerModel container) async {
    try {
      // This would typically:
      // 1. Generate PDF report
      // 2. Upload photos and PDF to Firebase Storage
      // 3. Update Google Sheets
      // 4. Send notifications if needed
      
      debugPrint('Saving container: ${container.containerNumber}');
    } catch (e) {
      debugPrint('Failed to save container: $e');
      // Add to offline queue if save fails
      await _addToOfflineQueue(container);
    }
  }

  /// Add container to offline queue
  Future<void> _addToOfflineQueue(ContainerModel container) async {
    _offlineQueue.add(container);
    await _saveOfflineQueue();
    notifyListeners();
  }

  /// Sync offline queue when online
  Future<void> syncOfflineQueue() async {
    if (_offlineQueue.isEmpty) return;
    
    final containersToSync = List<ContainerModel>.from(_offlineQueue);
    
    for (final container in containersToSync) {
      try {
        await _saveContainer(container);
        _offlineQueue.remove(container);
      } catch (e) {
        debugPrint('Failed to sync container ${container.containerNumber}: $e');
      }
    }
    
    await _saveOfflineQueue();
    notifyListeners();
  }

  /// Load offline queue from SharedPreferences
  Future<void> _loadOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString('offline_queue');
      
      if (queueJson != null) {
        final List<dynamic> queueList = json.decode(queueJson);
        _offlineQueue = queueList
            .map((json) => ContainerModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to load offline queue: $e');
    }
  }

  /// Save offline queue to SharedPreferences
  Future<void> _saveOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = json.encode(
        _offlineQueue.map((container) => container.toJson()).toList(),
      );
      await prefs.setString('offline_queue', queueJson);
    } catch (e) {
      debugPrint('Failed to save offline queue: $e');
    }
  }

  /// Set admin email
  void setAdminEmail(String email) {
    _adminEmail = email;
    _saveAdminEmail();
    notifyListeners();
  }

  /// Load admin email from SharedPreferences
  Future<void> _loadAdminEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _adminEmail = prefs.getString('admin_email');
    } catch (e) {
      debugPrint('Failed to load admin email: $e');
    }
  }

  /// Save admin email to SharedPreferences
  Future<void> _saveAdminEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_email', _adminEmail ?? '');
    } catch (e) {
      debugPrint('Failed to save admin email: $e');
    }
  }

  /// Check network status
  void _checkNetworkStatus() {
    // This would typically use connectivity_plus package
    // For now, we'll assume online
    _isOffline = false;
  }

  /// Get mock containers for testing
  List<ContainerModel> _getMockContainers() {
    return [
      ContainerModel(
        containerNumber: 'CONT001',
        type: ContainerType.import,
        doorNumber: 'Door 1',
        isCompleted: true,
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ContainerModel(
        containerNumber: 'CONT002',
        type: ContainerType.export,
        doorNumber: 'Door 2',
        isCompleted: false,
      ),
      ContainerModel(
        containerNumber: 'CONT003',
        type: ContainerType.delivery,
        doorNumber: 'Door 3',
        isCompleted: true,
        completedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  /// Clear all data
  void clearAllData() {
    _containers.clear();
    _currentContainer = null;
    _offlineQueue.clear();
    notifyListeners();
  }

  /// Get container by number
  ContainerModel? getContainerByNumber(String containerNumber) {
    try {
      return _containers.firstWhere(
        (container) => container.containerNumber == containerNumber,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get active containers (not completed)
  List<ContainerModel> get activeContainers {
    return _containers.where((container) => !container.isCompleted).toList();
  }

  /// Get completed containers
  List<ContainerModel> get completedContainers {
    return _containers.where((container) => container.isCompleted).toList();
  }
}

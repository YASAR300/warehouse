import 'package:flutter/foundation.dart';

/// Simple container model for basic functionality
class SimpleContainer {
  final String id;
  final String containerNumber;
  final String type;
  final String status;
  final DateTime createdAt;
  final String? doorNumber;
  final List<String> pieceCounts;
  final List<String> materials;
  final List<String> discrepancies;
  final List<String> photos;

  SimpleContainer({
    required this.id,
    required this.containerNumber,
    required this.type,
    this.status = 'In Progress',
    required this.createdAt,
    this.doorNumber,
    this.pieceCounts = const [],
    this.materials = const [],
    this.discrepancies = const [],
    this.photos = const [],
  });

  SimpleContainer copyWith({
    String? id,
    String? containerNumber,
    String? type,
    String? status,
    DateTime? createdAt,
    String? doorNumber,
    List<String>? pieceCounts,
    List<String>? materials,
    List<String>? discrepancies,
    List<String>? photos,
  }) {
    return SimpleContainer(
      id: id ?? this.id,
      containerNumber: containerNumber ?? this.containerNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      doorNumber: doorNumber ?? this.doorNumber,
      pieceCounts: pieceCounts ?? this.pieceCounts,
      materials: materials ?? this.materials,
      discrepancies: discrepancies ?? this.discrepancies,
      photos: photos ?? this.photos,
    );
  }
}

/// Simple app state management
class SimpleAppState extends ChangeNotifier {
  List<SimpleContainer> _containers = [];
  SimpleContainer? _currentContainer;
  bool _isLoading = false;

  // Getters
  List<SimpleContainer> get containers => _containers;
  SimpleContainer? get currentContainer => _currentContainer;
  bool get isLoading => _isLoading;

  /// Initialize with sample data
  void initialize() {
    _containers = [
      SimpleContainer(
        id: '1',
        containerNumber: 'CONT001',
        type: 'Import',
        status: 'Completed',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        doorNumber: 'Door 1',
        pieceCounts: ['10 Crates', '5 Pallets'],
        materials: ['Pallets', 'Shrink Wrap'],
        discrepancies: [],
        photos: [],
      ),
      SimpleContainer(
        id: '2',
        containerNumber: 'CONT002',
        type: 'Export',
        status: 'In Progress',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        doorNumber: 'Door 2',
        pieceCounts: ['15 Cartons'],
        materials: ['Air Bags'],
        discrepancies: ['Damaged goods'],
        photos: [],
      ),
      SimpleContainer(
        id: '3',
        containerNumber: 'CONT003',
        type: 'Delivery',
        status: 'In Progress',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        doorNumber: 'Door 3',
        pieceCounts: [],
        materials: [],
        discrepancies: [],
        photos: [],
      ),
    ];
    notifyListeners();
  }

  /// Set current container
  void setCurrentContainer(SimpleContainer? container) {
    _currentContainer = container;
    notifyListeners();
  }

  /// Create new container
  void createNewContainer(String containerNumber, String type) {
    final container = SimpleContainer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      containerNumber: containerNumber,
      type: type,
      createdAt: DateTime.now(),
    );
    
    _currentContainer = container;
    notifyListeners();
  }

  /// Update current container
  void updateCurrentContainer(SimpleContainer container) {
    _currentContainer = container;
    notifyListeners();
  }

  /// Add piece count
  void addPieceCount(String pieceCount) {
    if (_currentContainer == null) return;
    
    final updatedContainer = _currentContainer!.copyWith(
      pieceCounts: [..._currentContainer!.pieceCounts, pieceCount],
    );
    
    _currentContainer = updatedContainer;
    notifyListeners();
  }

  /// Add material
  void addMaterial(String material) {
    if (_currentContainer == null) return;
    
    final materials = List<String>.from(_currentContainer!.materials);
    if (!materials.contains(material)) {
      materials.add(material);
    }
    
    final updatedContainer = _currentContainer!.copyWith(
      materials: materials,
    );
    
    _currentContainer = updatedContainer;
    notifyListeners();
  }

  /// Add discrepancy
  void addDiscrepancy(String discrepancy) {
    if (_currentContainer == null) return;
    
    final discrepancies = List<String>.from(_currentContainer!.discrepancies);
    discrepancies.add(discrepancy);
    
    final updatedContainer = _currentContainer!.copyWith(
      discrepancies: discrepancies,
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
  void completeContainer() {
    if (_currentContainer == null) return;
    
    final completedContainer = _currentContainer!.copyWith(
      status: 'Completed',
    );
    
    // Add to containers list
    _containers.add(completedContainer);
    
    // Clear current container
    _currentContainer = null;
    notifyListeners();
  }

  /// Get active containers
  List<SimpleContainer> get activeContainers {
    return _containers.where((container) => container.status == 'In Progress').toList();
  }

  /// Get completed containers
  List<SimpleContainer> get completedContainers {
    return _containers.where((container) => container.status == 'Completed').toList();
  }
}

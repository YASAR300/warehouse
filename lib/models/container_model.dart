/// Data models for the Warehouse Container Tracker app

/// Container type enumeration
enum ContainerType {
  import('Import'),
  export('Export'),
  delivery('Delivery');

  const ContainerType(this.displayName);
  final String displayName;
}

/// Package type enumeration
enum PackageType {
  crates('Crates'),
  pallets('Pallets'),
  coils('Coils'),
  reels('Reels'),
  bundles('Bundles'),
  cartons('Cartons'),
  car('Car'),
  bike('Bike'),
  boat('Boat'),
  other('Other');

  const PackageType(this.displayName);
  final String displayName;
}

/// Material type enumeration
enum MaterialType {
  pallets('Pallets'),
  shrinkWrap('Shrink Wrap'),
  airBags('Air Bags'),
  dunnage('Dunnage');

  const MaterialType(this.displayName);
  final String displayName;
}

/// Piece count model
class PieceCount {
  final int quantity;
  final PackageType packageType;

  PieceCount({
    required this.quantity,
    required this.packageType,
  });

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'packageType': packageType.name,
    };
  }

  factory PieceCount.fromJson(Map<String, dynamic> json) {
    return PieceCount(
      quantity: json['quantity'] as int,
      packageType: PackageType.values.firstWhere(
        (e) => e.name == json['packageType'],
        orElse: () => PackageType.other,
      ),
    );
  }

  @override
  String toString() {
    return '$quantity ${packageType.displayName}';
  }
}

/// Discrepancy model
class Discrepancy {
  final String description;
  final List<String> photoPaths;
  final DateTime timestamp;

  Discrepancy({
    required this.description,
    required this.photoPaths,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'photoPaths': photoPaths,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Discrepancy.fromJson(Map<String, dynamic> json) {
    return Discrepancy(
      description: json['description'] as String,
      photoPaths: List<String>.from(json['photoPaths'] as List),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Container model representing the main data structure
class ContainerModel {
  final String containerNumber;
  final ContainerType type;
  final List<PieceCount> pieceCounts;
  final List<MaterialType> materialsSupplied;
  final List<Discrepancy> discrepancies;
  final List<String> photoPaths;
  final String? doorNumber;
  final DateTime? completedAt;
  final String? shareableLink;
  final bool isCompleted;

  ContainerModel({
    required this.containerNumber,
    required this.type,
    this.pieceCounts = const [],
    this.materialsSupplied = const [],
    this.discrepancies = const [],
    this.photoPaths = const [],
    this.doorNumber,
    this.completedAt,
    this.shareableLink,
    this.isCompleted = false,
  });

  ContainerModel copyWith({
    String? containerNumber,
    ContainerType? type,
    List<PieceCount>? pieceCounts,
    List<MaterialType>? materialsSupplied,
    List<Discrepancy>? discrepancies,
    List<String>? photoPaths,
    String? doorNumber,
    DateTime? completedAt,
    String? shareableLink,
    bool? isCompleted,
  }) {
    return ContainerModel(
      containerNumber: containerNumber ?? this.containerNumber,
      type: type ?? this.type,
      pieceCounts: pieceCounts ?? this.pieceCounts,
      materialsSupplied: materialsSupplied ?? this.materialsSupplied,
      discrepancies: discrepancies ?? this.discrepancies,
      photoPaths: photoPaths ?? this.photoPaths,
      doorNumber: doorNumber ?? this.doorNumber,
      completedAt: completedAt ?? this.completedAt,
      shareableLink: shareableLink ?? this.shareableLink,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'containerNumber': containerNumber,
      'type': type.name,
      'pieceCounts': pieceCounts.map((pc) => pc.toJson()).toList(),
      'materialsSupplied': materialsSupplied.map((m) => m.name).toList(),
      'discrepancies': discrepancies.map((d) => d.toJson()).toList(),
      'photoPaths': photoPaths,
      'doorNumber': doorNumber,
      'completedAt': completedAt?.toIso8601String(),
      'shareableLink': shareableLink,
      'isCompleted': isCompleted,
    };
  }

  factory ContainerModel.fromJson(Map<String, dynamic> json) {
    return ContainerModel(
      containerNumber: json['containerNumber'] as String,
      type: ContainerType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ContainerType.import,
      ),
      pieceCounts: (json['pieceCounts'] as List?)
          ?.map((pc) => PieceCount.fromJson(pc as Map<String, dynamic>))
          .toList() ?? [],
      materialsSupplied: (json['materialsSupplied'] as List?)
          ?.map((m) => MaterialType.values.firstWhere(
                (e) => e.name == m,
                orElse: () => MaterialType.pallets,
              ))
          .toList() ?? [],
      discrepancies: (json['discrepancies'] as List?)
          ?.map((d) => Discrepancy.fromJson(d as Map<String, dynamic>))
          .toList() ?? [],
      photoPaths: List<String>.from(json['photoPaths'] ?? []),
      doorNumber: json['doorNumber'] as String?,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      shareableLink: json['shareableLink'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  /// Get total piece count
  int get totalPieceCount {
    return pieceCounts.fold(0, (sum, pc) => sum + pc.quantity);
  }

  /// Check if container has discrepancies
  bool get hasDiscrepancies {
    return discrepancies.isNotEmpty;
  }

  /// Get formatted piece count summary
  String get pieceCountSummary {
    if (pieceCounts.isEmpty) return 'No pieces recorded';
    
    final grouped = <PackageType, int>{};
    for (final pc in pieceCounts) {
      grouped[pc.packageType] = (grouped[pc.packageType] ?? 0) + pc.quantity;
    }
    
    return grouped.entries
        .map((e) => '${e.value} ${e.key.displayName}')
        .join(', ');
  }
}

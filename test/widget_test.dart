import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_container_tracker/models/container_model.dart';

void main() {
  group('Container Model Tests', () {
    test('should create container with required fields', () {
      final container = ContainerModel(
        containerNumber: 'CONT001',
        type: ContainerType.import,
      );

      expect(container.containerNumber, 'CONT001');
      expect(container.type, ContainerType.import);
      expect(container.isCompleted, false);
      expect(container.pieceCounts, isEmpty);
      expect(container.materialsSupplied, isEmpty);
      expect(container.discrepancies, isEmpty);
      expect(container.photoPaths, isEmpty);
    });

    test('should calculate total piece count correctly', () {
      final container = ContainerModel(
        containerNumber: 'CONT001',
        type: ContainerType.import,
        pieceCounts: [
          PieceCount(quantity: 10, packageType: PackageType.crates),
          PieceCount(quantity: 5, packageType: PackageType.pallets),
        ],
      );

      expect(container.totalPieceCount, 15);
    });

    test('should detect discrepancies correctly', () {
      final containerWithDiscrepancies = ContainerModel(
        containerNumber: 'CONT001',
        type: ContainerType.import,
        discrepancies: [
          Discrepancy(
            description: 'Damaged goods',
            photoPaths: [],
            timestamp: DateTime.now(),
          ),
        ],
      );

      final containerWithoutDiscrepancies = ContainerModel(
        containerNumber: 'CONT002',
        type: ContainerType.export,
      );

      expect(containerWithDiscrepancies.hasDiscrepancies, true);
      expect(containerWithoutDiscrepancies.hasDiscrepancies, false);
    });

    test('should generate piece count summary correctly', () {
      final container = ContainerModel(
        containerNumber: 'CONT001',
        type: ContainerType.import,
        pieceCounts: [
          PieceCount(quantity: 10, packageType: PackageType.crates),
          PieceCount(quantity: 5, packageType: PackageType.pallets),
          PieceCount(quantity: 3, packageType: PackageType.crates),
        ],
      );

      expect(container.pieceCountSummary, contains('13 Crates'));
      expect(container.pieceCountSummary, contains('5 Pallets'));
    });

    test('should serialize and deserialize correctly', () {
      final originalContainer = ContainerModel(
        containerNumber: 'CONT001',
        type: ContainerType.import,
        pieceCounts: [
          PieceCount(quantity: 10, packageType: PackageType.crates),
        ],
        materialsSupplied: [MaterialType.pallets],
        discrepancies: [
          Discrepancy(
            description: 'Test discrepancy',
            photoPaths: ['photo1.jpg'],
            timestamp: DateTime.now(),
          ),
        ],
        photoPaths: ['photo1.jpg', 'photo2.jpg'],
        doorNumber: 'Door 1',
        completedAt: DateTime.now(),
        shareableLink: 'https://example.com/link',
        isCompleted: true,
      );

      final json = originalContainer.toJson();
      final deserializedContainer = ContainerModel.fromJson(json);

      expect(deserializedContainer.containerNumber, originalContainer.containerNumber);
      expect(deserializedContainer.type, originalContainer.type);
      expect(deserializedContainer.pieceCounts.length, originalContainer.pieceCounts.length);
      expect(deserializedContainer.materialsSupplied.length, originalContainer.materialsSupplied.length);
      expect(deserializedContainer.discrepancies.length, originalContainer.discrepancies.length);
      expect(deserializedContainer.photoPaths.length, originalContainer.photoPaths.length);
      expect(deserializedContainer.doorNumber, originalContainer.doorNumber);
      expect(deserializedContainer.isCompleted, originalContainer.isCompleted);
    });
  });

  group('Package Type Tests', () {
    test('should have correct display names', () {
      expect(PackageType.crates.displayName, 'Crates');
      expect(PackageType.pallets.displayName, 'Pallets');
      expect(PackageType.coils.displayName, 'Coils');
      expect(PackageType.reels.displayName, 'Reels');
      expect(PackageType.bundles.displayName, 'Bundles');
      expect(PackageType.cartons.displayName, 'Cartons');
      expect(PackageType.car.displayName, 'Car');
      expect(PackageType.bike.displayName, 'Bike');
      expect(PackageType.boat.displayName, 'Boat');
      expect(PackageType.other.displayName, 'Other');
    });
  });

  group('Container Type Tests', () {
    test('should have correct display names', () {
      expect(ContainerType.import.displayName, 'Import');
      expect(ContainerType.export.displayName, 'Export');
      expect(ContainerType.delivery.displayName, 'Delivery');
    });
  });

  group('Material Type Tests', () {
    test('should have correct display names', () {
      expect(MaterialType.pallets.displayName, 'Pallets');
      expect(MaterialType.shrinkWrap.displayName, 'Shrink Wrap');
      expect(MaterialType.airBags.displayName, 'Air Bags');
      expect(MaterialType.dunnage.displayName, 'Dunnage');
    });
  });
}

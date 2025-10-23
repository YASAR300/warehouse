import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/container_model.dart' as models;
import 'photo_gallery_screen.dart';
import 'piece_count_dialog.dart';
import 'discrepancy_dialog.dart';

/// Container detail screen for editing container information
class ContainerDetailScreen extends StatefulWidget {
  final models.ContainerModel? container;

  const ContainerDetailScreen({
    super.key,
    this.container,
  });

  @override
  State<ContainerDetailScreen> createState() => _ContainerDetailScreenState();
}

class _ContainerDetailScreenState extends State<ContainerDetailScreen> {
  final TextEditingController _doorController = TextEditingController();
  final List<models.MaterialType> _selectedMaterials = [];

  @override
  void initState() {
    super.initState();
    if (widget.container != null) {
      context.read<AppState>().setCurrentContainer(widget.container!);
      _doorController.text = widget.container!.doorNumber ?? '';
      _selectedMaterials.addAll(widget.container!.materialsSupplied);
    }
  }

  @override
  void dispose() {
    _doorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.container?.containerNumber ?? 'New Container'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PhotoGalleryScreen(),
                ),
              );
            },
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container Info Card
                _buildContainerInfoCard(container),
                
                const SizedBox(height: 16),
                
                // Piece Count Section
                _buildPieceCountSection(container),
                
                const SizedBox(height: 16),
                
                // Materials Supplied Section
                _buildMaterialsSection(container),
                
                const SizedBox(height: 16),
                
                // Discrepancies Section
                _buildDiscrepanciesSection(container),
                
                const SizedBox(height: 16),
                
                // Photos Section
                _buildPhotosSection(container),
                
                const SizedBox(height: 16),
                
                // Door Number Section
                _buildDoorNumberSection(),
                
                const SizedBox(height: 32),
                
                // Complete Button
                _buildCompleteButton(container),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build container info card
  Widget _buildContainerInfoCard(models.ContainerModel container) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getContainerTypeIcon(container.type),
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Container Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Container #', container.containerNumber),
                ),
                Expanded(
                  child: _buildInfoItem('Type', container.type.displayName),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Status', 
                    container.isCompleted ? 'Completed' : 'In Progress'),
                ),
                Expanded(
                  child: _buildInfoItem('Total Pieces', 
                    container.totalPieceCount.toString()),
                ),
              ],
            ),
            if (container.hasDiscrepancies) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Has Discrepancies',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build info item widget
  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Get container type icon
  IconData _getContainerTypeIcon(models.ContainerType type) {
    switch (type) {
      case models.ContainerType.import:
        return Icons.input;
      case models.ContainerType.export:
        return Icons.output;
      case models.ContainerType.delivery:
        return Icons.local_shipping;
    }
  }

  /// Build piece count section
  Widget _buildPieceCountSection(models.ContainerModel container) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Piece Count',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _showPieceCountDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (container.pieceCounts.isEmpty)
              const Text(
                'No pieces recorded',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...container.pieceCounts.asMap().entries.map((entry) {
                final index = entry.key;
                final pieceCount = entry.value;
                return ListTile(
                  leading: const Icon(Icons.inventory),
                  title: Text(pieceCount.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<AppState>().removePieceCount(index);
                    },
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  /// Build materials section
  Widget _buildMaterialsSection(models.ContainerModel container) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Materials Supplied',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: models.MaterialType.values.map((material) {
                final isSelected = container.materialsSupplied.contains(material);
                return FilterChip(
                  label: Text(material.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<AppState>().addMaterial(material);
                    } else {
                      context.read<AppState>().removeMaterial(material);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build discrepancies section
  Widget _buildDiscrepanciesSection(models.ContainerModel container) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discrepancies',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _showDiscrepancyDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (container.discrepancies.isEmpty)
              const Text(
                'No discrepancies reported',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...container.discrepancies.asMap().entries.map((entry) {
                final index = entry.key;
                final discrepancy = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: Text(discrepancy.description),
                    subtitle: Text(
                      'Reported: ${_formatDate(discrepancy.timestamp)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        context.read<AppState>().removeDiscrepancy(index);
                      },
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  /// Build photos section
  Widget _buildPhotosSection(models.ContainerModel container) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Photos (${container.photoPaths.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PhotoGalleryScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (container.photoPaths.isEmpty)
              const Text(
                'No photos taken',
                style: TextStyle(color: Colors.grey),
              )
            else
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: container.photoPaths.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoGalleryScreen(
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 100,
                          height: 100,
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
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build door number section
  Widget _buildDoorNumberSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Door Number',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _doorController,
              decoration: const InputDecoration(
                hintText: 'Enter door number',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                context.read<AppState>().setDoorNumber(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build complete button
  Widget _buildCompleteButton(models.ContainerModel container) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: container.isCompleted ? null : () {
          _showCompleteDialog(container);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: container.isCompleted ? Colors.green : Colors.blue,
        ),
        child: Text(
          container.isCompleted ? 'COMPLETED' : 'COMPLETE CONTAINER',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Show piece count dialog
  void _showPieceCountDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PieceCountDialog(),
      ),
    );
  }

  /// Show discrepancy dialog
  void _showDiscrepancyDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DiscrepancyDialog(),
      ),
    );
  }

  /// Show complete dialog
  void _showCompleteDialog(models.ContainerModel container) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Container'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to complete this container?'),
            const SizedBox(height: 16),
            Text('Container: ${container.containerNumber}'),
            Text('Type: ${container.type.displayName}'),
            Text('Total Pieces: ${container.totalPieceCount}'),
            Text('Photos: ${container.photoPaths.length}'),
            if (container.hasDiscrepancies) ...[
              const SizedBox(height: 8),
              const Text(
                '⚠️ This container has discrepancies and will notify the admin.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AppState>().completeContainer();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Container completed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

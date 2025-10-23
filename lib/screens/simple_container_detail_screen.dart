import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/simple_app_state.dart';

/// Simple container detail screen
class SimpleContainerDetailScreen extends StatefulWidget {
  final SimpleContainer? container;

  const SimpleContainerDetailScreen({
    super.key,
    this.container,
  });

  @override
  State<SimpleContainerDetailScreen> createState() => _SimpleContainerDetailScreenState();
}

class _SimpleContainerDetailScreenState extends State<SimpleContainerDetailScreen> {
  final TextEditingController _doorController = TextEditingController();
  final TextEditingController _pieceCountController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _discrepancyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.container != null) {
      context.read<SimpleAppState>().setCurrentContainer(widget.container!);
      _doorController.text = widget.container!.doorNumber ?? '';
    }
  }

  @override
  void dispose() {
    _doorController.dispose();
    _pieceCountController.dispose();
    _materialController.dispose();
    _discrepancyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.container?.containerNumber ?? 'New Container'),
      ),
      body: Consumer<SimpleAppState>(
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
                
                // Materials Section
                _buildMaterialsSection(container),
                
                const SizedBox(height: 16),
                
                // Discrepancies Section
                _buildDiscrepanciesSection(container),
                
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
  Widget _buildContainerInfoCard(SimpleContainer container) {
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
                  child: _buildInfoItem('Type', container.type),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Status', container.status),
                ),
                Expanded(
                  child: _buildInfoItem('Created', _formatDate(container.createdAt)),
                ),
              ],
            ),
            if (container.discrepancies.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 16),
                  SizedBox(width: 4),
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
  IconData _getContainerTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'import':
        return Icons.input;
      case 'export':
        return Icons.output;
      case 'delivery':
        return Icons.local_shipping;
      default:
        return Icons.inventory_2;
    }
  }

  /// Build piece count section
  Widget _buildPieceCountSection(SimpleContainer container) {
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
                    _showAddPieceCountDialog();
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
              ...container.pieceCounts.map((pieceCount) => 
                ListTile(
                  leading: const Icon(Icons.inventory),
                  title: Text(pieceCount),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Remove piece count logic here
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build materials section
  Widget _buildMaterialsSection(SimpleContainer container) {
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
                  'Materials Supplied',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _showAddMaterialDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (container.materials.isEmpty)
              const Text(
                'No materials recorded',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: container.materials.map((material) => 
                  Chip(
                    label: Text(material),
                    onDeleted: () {
                      // Remove material logic here
                    },
                  ),
                ).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// Build discrepancies section
  Widget _buildDiscrepanciesSection(SimpleContainer container) {
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
                    _showAddDiscrepancyDialog();
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
              ...container.discrepancies.map((discrepancy) => 
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: Text(discrepancy),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // Remove discrepancy logic here
                      },
                    ),
                  ),
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
                context.read<SimpleAppState>().setDoorNumber(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build complete button
  Widget _buildCompleteButton(SimpleContainer container) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: container.status == 'Completed' ? null : () {
          _showCompleteDialog(container);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: container.status == 'Completed' ? Colors.green : Colors.blue,
        ),
        child: Text(
          container.status == 'Completed' ? 'COMPLETED' : 'COMPLETE CONTAINER',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Show add piece count dialog
  void _showAddPieceCountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Piece Count'),
        content: TextField(
          controller: _pieceCountController,
          decoration: const InputDecoration(
            labelText: 'Piece Count',
            hintText: 'e.g., 10 Crates, 5 Pallets',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final pieceCount = _pieceCountController.text.trim();
              if (pieceCount.isNotEmpty) {
                context.read<SimpleAppState>().addPieceCount(pieceCount);
                _pieceCountController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Show add material dialog
  void _showAddMaterialDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Material'),
        content: TextField(
          controller: _materialController,
          decoration: const InputDecoration(
            labelText: 'Material',
            hintText: 'e.g., Pallets, Shrink Wrap',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final material = _materialController.text.trim();
              if (material.isNotEmpty) {
                context.read<SimpleAppState>().addMaterial(material);
                _materialController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Show add discrepancy dialog
  void _showAddDiscrepancyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Discrepancy'),
        content: TextField(
          controller: _discrepancyController,
          decoration: const InputDecoration(
            labelText: 'Discrepancy',
            hintText: 'Describe the issue...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final discrepancy = _discrepancyController.text.trim();
              if (discrepancy.isNotEmpty) {
                context.read<SimpleAppState>().addDiscrepancy(discrepancy);
                _discrepancyController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Show complete dialog
  void _showCompleteDialog(SimpleContainer container) {
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
            Text('Type: ${container.type}'),
            Text('Piece Counts: ${container.pieceCounts.length}'),
            if (container.discrepancies.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                '⚠️ This container has discrepancies.',
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
            onPressed: () {
              Navigator.pop(context);
              context.read<SimpleAppState>().completeContainer();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Container completed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

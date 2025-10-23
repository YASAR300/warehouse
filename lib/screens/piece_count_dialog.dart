import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/container_model.dart';

/// Dialog for adding piece count
class PieceCountDialog extends StatefulWidget {
  const PieceCountDialog({super.key});

  @override
  State<PieceCountDialog> createState() => _PieceCountDialogState();
}

class _PieceCountDialogState extends State<PieceCountDialog> {
  final TextEditingController _quantityController = TextEditingController();
  PackageType _selectedPackageType = PackageType.crates;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Piece Count'),
        actions: [
          TextButton(
            onPressed: _savePieceCount,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quantity input
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter quantity',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Package type dropdown
            DropdownButtonFormField<PackageType>(
              initialValue: _selectedPackageType,
              decoration: const InputDecoration(
                labelText: 'Package Type',
                border: OutlineInputBorder(),
              ),
              items: PackageType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPackageType = value;
                  });
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preview:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPreviewText(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePieceCount,
                child: const Text('Add Piece Count'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get preview text
  String _getPreviewText() {
    final quantity = _quantityController.text.isEmpty ? '0' : _quantityController.text;
    return '$quantity ${_selectedPackageType.displayName}';
  }

  /// Save piece count
  void _savePieceCount() {
    final quantityText = _quantityController.text.trim();
    
    if (quantityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quantity = int.tryParse(quantityText);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pieceCount = PieceCount(
      quantity: quantity,
      packageType: _selectedPackageType,
    );

    context.read<AppState>().addPieceCount(pieceCount);
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Piece count added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/container_model.dart';

/// Dialog for adding discrepancies
class DiscrepancyDialog extends StatefulWidget {
  const DiscrepancyDialog({super.key});

  @override
  State<DiscrepancyDialog> createState() => _DiscrepancyDialogState();
}

class _DiscrepancyDialogState extends State<DiscrepancyDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _photoPaths = [];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Discrepancy'),
        actions: [
          TextButton(
            onPressed: _saveDiscrepancy,
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
            // Description input
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the discrepancy...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Photo section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Photos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Take Photo'),
                          onPressed: _takePhoto,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_photoPaths.isEmpty)
                      const Text(
                        'No photos attached',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _photoPaths.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Container(
                                width: 80,
                                height: 80,
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
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
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
                    Text(_descriptionController.text.isEmpty 
                        ? 'No description entered' 
                        : _descriptionController.text),
                    if (_photoPaths.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Photos: ${_photoPaths.length}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDiscrepancy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Add Discrepancy'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Take photo for discrepancy
  Future<void> _takePhoto() async {
    // This would typically open camera
    // For now, we'll simulate adding a photo
    setState(() {
      _photoPaths.add('photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo added to discrepancy'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Save discrepancy
  void _saveDiscrepancy() {
    final description = _descriptionController.text.trim();
    
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final discrepancy = Discrepancy(
      description: description,
      photoPaths: _photoPaths,
      timestamp: DateTime.now(),
    );

    context.read<AppState>().addDiscrepancy(discrepancy);
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Discrepancy added successfully!'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

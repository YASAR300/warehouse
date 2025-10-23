import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/container_model.dart';
import 'storage_service.dart';

/// Service for generating PDF reports
class PdfService {
  final StorageService _storageService = StorageService();

  /// Generate a complete stripping/loading report PDF
  Future<String> generateReport({
    required ContainerModel container,
    required List<String> photoPaths,
  }) async {
    try {
      // Create PDF document
      final pdf = pw.Document();

      // Add main page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildReportContent(container, photoPaths);
          },
        ),
      );

      // Save PDF to temporary file
      final fileName = '${container.containerNumber}_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final pdfPath = await _storageService.createTempFilePath(fileName);
      
      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());

      return pdfPath;
    } catch (e) {
      throw Exception('Failed to generate PDF report: $e');
    }
  }

  /// Build the main report content
  pw.Widget _buildReportContent(ContainerModel container, List<String> photoPaths) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(container),
        
        pw.SizedBox(height: 20),
        
        // Container Information
        _buildContainerInfo(container),
        
        pw.SizedBox(height: 20),
        
        // Piece Count Section
        _buildPieceCountSection(container),
        
        pw.SizedBox(height: 20),
        
        // Materials Supplied Section
        _buildMaterialsSection(container),
        
        pw.SizedBox(height: 20),
        
        // Discrepancies Section
        _buildDiscrepanciesSection(container),
        
        pw.SizedBox(height: 20),
        
        // Photos Section
        _buildPhotosSection(photoPaths),
        
        pw.SizedBox(height: 20),
        
        // Footer
        _buildFooter(container),
      ],
    );
  }

  /// Build report header
  pw.Widget _buildHeader(ContainerModel container) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue100,
        border: pw.Border.all(color: PdfColors.blue800),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'WAREHOUSE CONTAINER REPORT',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Container #: ${container.containerNumber}',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Date: ${DateTime.now().toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 14),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Type: ${container.type.displayName}',
            style: pw.TextStyle(fontSize: 14),
          ),
          if (container.doorNumber != null) ...[
            pw.SizedBox(height: 5),
            pw.Text(
              'Door #: ${container.doorNumber}',
              style: pw.TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  /// Build container information section
  pw.Widget _buildContainerInfo(ContainerModel container) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CONTAINER INFORMATION',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Container Number:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(container.containerNumber),
                    pw.SizedBox(height: 8),
                    pw.Text('Type:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(container.type.displayName),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Door Number:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(container.doorNumber ?? 'Not specified'),
                    pw.SizedBox(height: 8),
                    pw.Text('Status:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(container.isCompleted ? 'Completed' : 'In Progress'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build piece count section
  pw.Widget _buildPieceCountSection(ContainerModel container) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PIECE COUNT',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          if (container.pieceCounts.isEmpty)
            pw.Text('No pieces recorded')
          else
            pw.Column(
              children: container.pieceCounts.map((pc) => 
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Text('• ${pc.toString()}'),
                ),
              ).toList(),
            ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Total Pieces: ${container.totalPieceCount}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Build materials supplied section
  pw.Widget _buildMaterialsSection(ContainerModel container) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'MATERIALS SUPPLIED',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          if (container.materialsSupplied.isEmpty)
            pw.Text('No materials recorded')
          else
            pw.Column(
              children: container.materialsSupplied.map((material) => 
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Text('• ${material.displayName}'),
                ),
              ).toList(),
            ),
        ],
      ),
    );
  }

  /// Build discrepancies section
  pw.Widget _buildDiscrepanciesSection(ContainerModel container) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DISCREPANCIES',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red800,
            ),
          ),
          pw.SizedBox(height: 10),
          if (container.discrepancies.isEmpty)
            pw.Text('No discrepancies reported')
          else
            pw.Column(
              children: container.discrepancies.map((discrepancy) => 
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '• ${discrepancy.description}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '   Reported: ${discrepancy.timestamp.toString().split(' ')[0]}',
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ),
        ],
      ),
    );
  }

  /// Build photos section
  pw.Widget _buildPhotosSection(List<String> photoPaths) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PHOTOS',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          if (photoPaths.isEmpty)
            pw.Text('No photos attached')
          else
            pw.Wrap(
              children: photoPaths.map((photoPath) => 
                pw.Container(
                  margin: const pw.EdgeInsets.all(5),
                  child: pw.FutureBuilder<Uint8List>(
                    future: _loadImageBytes(photoPath),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return pw.Image(
                          pw.MemoryImage(snapshot.data!),
                          width: 100,
                          height: 100,
                          fit: pw.BoxFit.cover,
                        );
                      } else {
                        return pw.Container(
                          width: 100,
                          height: 100,
                          color: PdfColors.grey200,
                          child: pw.Center(
                            child: pw.Text('Loading...'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ).toList(),
            ),
        ],
      ),
    );
  }

  /// Load image bytes from file path
  Future<Uint8List> _loadImageBytes(String imagePath) async {
    final file = File(imagePath);
    return await file.readAsBytes();
  }

  /// Build report footer
  pw.Widget _buildFooter(ContainerModel container) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Report Generated: ${DateTime.now().toString()}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Container Status: ${container.isCompleted ? 'COMPLETED' : 'IN PROGRESS'}',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: container.isCompleted ? PdfColors.green800 : PdfColors.orange800,
            ),
          ),
          if (container.shareableLink != null) ...[
            pw.SizedBox(height: 5),
            pw.Text(
              'Shareable Link: ${container.shareableLink}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.blue600),
            ),
          ],
        ],
      ),
    );
  }

  /// Print PDF directly (for testing)
  Future<void> printPdf(String pdfPath) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final file = File(pdfPath);
          return await file.readAsBytes();
        },
      );
    } catch (e) {
      throw Exception('Failed to print PDF: $e');
    }
  }

  /// Save PDF to device storage
  Future<String> savePdfToDevice(String pdfPath, String fileName) async {
    try {
      final documentsDir = await _storageService.getApplicationDocumentsDirectory();
      final destinationPath = '${documentsDir.path}/$fileName';
      
      final sourceFile = File(pdfPath);
      final destinationFile = await sourceFile.copy(destinationPath);
      
      return destinationFile.path;
    } catch (e) {
      throw Exception('Failed to save PDF to device: $e');
    }
  }
}

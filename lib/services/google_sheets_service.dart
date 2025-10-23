import 'dart:convert';
import 'dart:io';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../models/container_model.dart';

/// Service for interacting with Google Sheets API
class GoogleSheetsService {
  static const String _spreadsheetId = 'YOUR_SPREADSHEET_ID'; // Replace with actual ID
  static const String _range = 'Sheet1!A:Z'; // Adjust range as needed
  
  sheets.SheetsApi? _sheetsApi;
  bool _isInitialized = false;

  /// Initialize the Google Sheets API with service account credentials
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load service account credentials from assets
      final credentials = await _loadServiceAccountCredentials();
      
      // Create authenticated client
      final client = await clientViaServiceAccount(
        credentials,
        [sheets.SheetsApi.spreadsheetsScope],
      );

      _sheetsApi = sheets.SheetsApi(client);
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize Google Sheets API: $e');
    }
  }

  /// Load service account credentials from assets
  Future<ServiceAccountCredentials> _loadServiceAccountCredentials() async {
    try {
      // In production, load from secure storage or environment variables
      // For now, we'll expect the credentials to be provided via environment
      final credentialsJson = Platform.environment['GOOGLE_SERVICE_ACCOUNT_JSON'];
      
      if (credentialsJson == null) {
        throw Exception('Google service account credentials not found');
      }

      final credentialsMap = json.decode(credentialsJson) as Map<String, dynamic>;
      return ServiceAccountCredentials.fromJson(credentialsMap);
    } catch (e) {
      throw Exception('Failed to load service account credentials: $e');
    }
  }

  /// Get all containers from the spreadsheet
  Future<List<ContainerModel>> getContainers() async {
    await initialize();
    
    try {
      final response = await _sheetsApi!.spreadsheets.values.get(
        _spreadsheetId,
        _range,
      );

      final values = response.values;
      if (values == null || values.isEmpty) {
        return [];
      }

      // Skip header row
      final dataRows = values.skip(1).toList();
      
      return dataRows.map((row) => _parseContainerFromRow(row)).toList();
    } catch (e) {
      throw Exception('Failed to fetch containers: $e');
    }
  }

  /// Parse a spreadsheet row into a ContainerModel
  ContainerModel _parseContainerFromRow(List<dynamic> row) {
    return ContainerModel(
      containerNumber: row.isNotEmpty ? row[0].toString() : '',
      type: row.length > 1 ? _parseContainerType(row[1].toString()) : ContainerType.import,
      doorNumber: row.length > 4 ? row[4].toString() : null,
      completedAt: row.length > 5 && row[5].toString().isNotEmpty 
          ? DateTime.tryParse(row[5].toString()) 
          : null,
      shareableLink: row.length > 6 ? row[6].toString() : null,
      isCompleted: row.length > 7 && row[7].toString().toLowerCase() == 'true',
    );
  }

  /// Parse container type from string
  ContainerType _parseContainerType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'export':
        return ContainerType.export;
      case 'delivery':
        return ContainerType.delivery;
      default:
        return ContainerType.import;
    }
  }

  /// Update container data in the spreadsheet
  Future<void> updateContainer(ContainerModel container) async {
    await initialize();

    try {
      // Find the row for this container
      final rowIndex = await _findContainerRow(container.containerNumber);
      
      if (rowIndex == -1) {
        throw Exception('Container not found in spreadsheet');
      }

      // Prepare update data
      final updateData = _prepareUpdateData(container);
      
      // Update the row
      await _sheetsApi!.spreadsheets.values.update(
        sheets.ValueRange(
          values: [updateData],
        ),
        _spreadsheetId,
        'Sheet1!A${rowIndex + 1}:Z${rowIndex + 1}',
        valueInputOption: 'RAW',
      );

      // Update row formatting if completed
      if (container.isCompleted) {
        await _updateRowFormatting(rowIndex + 1, isCompleted: true);
      }
    } catch (e) {
      throw Exception('Failed to update container: $e');
    }
  }

  /// Find the row index for a container number
  Future<int> _findContainerRow(String containerNumber) async {
    final response = await _sheetsApi!.spreadsheets.values.get(
      _spreadsheetId,
      'Sheet1!A:A',
    );

    final values = response.values;
    if (values == null || values.isEmpty) {
      return -1;
    }

    for (int i = 0; i < values.length; i++) {
      if (values[i].isNotEmpty && values[i][0].toString() == containerNumber) {
        return i;
      }
    }

    return -1;
  }

  /// Prepare update data for spreadsheet
  List<dynamic> _prepareUpdateData(ContainerModel container) {
    return [
      container.containerNumber,
      container.type.displayName,
      container.pieceCountSummary,
      container.materialsSupplied.map((m) => m.displayName).join(', '),
      container.doorNumber ?? '',
      container.completedAt?.toIso8601String() ?? '',
      container.shareableLink ?? '',
      container.isCompleted.toString(),
      container.hasDiscrepancies ? 'Yes' : 'No',
      container.discrepancies.map((d) => d.description).join('; '),
    ];
  }

  /// Update row formatting (background color)
  Future<void> _updateRowFormatting(int rowIndex, {required bool isCompleted}) async {
    try {
      final requests = [
        sheets.Request(
          repeatCell: sheets.RepeatCellRequest(
            range: sheets.GridRange(
              sheetId: 0, // Assuming first sheet
              startRowIndex: rowIndex - 1,
              endRowIndex: rowIndex,
              startColumnIndex: 0,
              endColumnIndex: 10, // Adjust based on your columns
            ),
            cell: sheets.CellData(
              userEnteredFormat: sheets.CellFormat(
                backgroundColor: sheets.Color(
                  red: isCompleted ? 0.0 : 1.0,
                  green: isCompleted ? 1.0 : 1.0,
                  blue: 0.0,
                ),
              ),
            ),
            fields: 'userEnteredFormat.backgroundColor',
          ),
        ),
      ];

      await _sheetsApi!.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(requests: requests),
        _spreadsheetId,
      );
    } catch (e) {
      // Log error but don't fail the main operation
      print('Failed to update row formatting: $e');
    }
  }

  /// Add a new container to the spreadsheet
  Future<void> addContainer(ContainerModel container) async {
    await initialize();

    try {
      final updateData = _prepareUpdateData(container);
      
      await _sheetsApi!.spreadsheets.values.append(
        sheets.ValueRange(values: [updateData]),
        _spreadsheetId,
        'Sheet1!A:Z',
        valueInputOption: 'RAW',
        insertDataOption: 'INSERT_ROWS',
      );
    } catch (e) {
      throw Exception('Failed to add container: $e');
    }
  }

  /// Get container suggestions for autocomplete
  Future<List<String>> getContainerSuggestions() async {
    try {
      final containers = await getContainers();
      return containers.map((c) => c.containerNumber).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if container exists
  Future<bool> containerExists(String containerNumber) async {
    try {
      final rowIndex = await _findContainerRow(containerNumber);
      return rowIndex != -1;
    } catch (e) {
      return false;
    }
  }

  /// Get container by number
  Future<ContainerModel?> getContainerByNumber(String containerNumber) async {
    try {
      final containers = await getContainers();
      return containers.firstWhere(
        (c) => c.containerNumber == containerNumber,
        orElse: () => throw StateError('Container not found'),
      );
    } catch (e) {
      return null;
    }
  }
}

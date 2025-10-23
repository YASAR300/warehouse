import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for handling file uploads to Box.com
class BoxStorageService {
  final String _clientId;
  final String _clientSecret;
  final String _accessToken;
  final String _folderId;
  
  static const String _baseUrl = 'https://api.box.com/2.0';
  static const String _uploadUrl = 'https://upload.box.com/api/2.0';
  
  BoxStorageService({
    required String clientId,
    required String clientSecret,
    required String accessToken,
    required String folderId,
  })  : _clientId = clientId,
        _clientSecret = clientSecret,
        _accessToken = accessToken,
        _folderId = folderId;

  /// Upload a file to Box.com
  Future<Map<String, dynamic>> uploadFile({
    required String filePath,
    required String fileName,
    String? parentFolderId,
  }) async {
    try {
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_uploadUrl/files/content'),
      );
      
      request.headers['Authorization'] = 'Bearer $_accessToken';
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );
      
      request.fields['parent_id'] = parentFolderId ?? _folderId;
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['entries'][0];
      } else {
        throw Exception('Failed to upload file: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to upload file to Box: $e');
    }
  }

  /// Upload photos to Box.com
  Future<List<String>> uploadPhotos({
    required String containerNumber,
    required List<String> photoPaths,
  }) async {
    final uploadedUrls = <String>[];
    
    try {
      // Create a folder for this container
      final containerFolder = await createFolder(
        folderName: containerNumber,
        parentFolderId: _folderId,
      );
      
      final containerFolderId = containerFolder['id'];
      
      // Create photos subfolder
      final photosFolder = await createFolder(
        folderName: 'photos',
        parentFolderId: containerFolderId,
      );
      
      final photosFolderId = photosFolder['id'];
      
      // Upload each photo
      for (int i = 0; i < photoPaths.length; i++) {
        final photoFile = File(photoPaths[i]);
        final fileName = '${containerNumber}_photo_${i + 1}.jpg';
        
        final uploadedFile = await uploadFile(
          filePath: photoFile.path,
          fileName: fileName,
          parentFolderId: photosFolderId,
        );
        
        // Get shareable link for the photo
        final shareableLink = await createSharedLink(uploadedFile['id']);
        uploadedUrls.add(shareableLink);
      }
    } catch (e) {
      throw Exception('Failed to upload photos: $e');
    }
    
    return uploadedUrls;
  }

  /// Upload PDF report to Box.com
  Future<String> uploadPdfReport({
    required String containerNumber,
    required String pdfPath,
  }) async {
    try {
      // Create or get container folder
      final containerFolder = await createFolder(
        folderName: containerNumber,
        parentFolderId: _folderId,
      );
      
      final containerFolderId = containerFolder['id'];
      
      // Create reports subfolder
      final reportsFolder = await createFolder(
        folderName: 'reports',
        parentFolderId: containerFolderId,
      );
      
      final reportsFolderId = reportsFolder['id'];
      
      final pdfFile = File(pdfPath);
      final fileName = '${containerNumber}_report.pdf';
      
      final uploadedFile = await uploadFile(
        filePath: pdfFile.path,
        fileName: fileName,
        parentFolderId: reportsFolderId,
      );
      
      // Get shareable link for the PDF
      final shareableLink = await createSharedLink(uploadedFile['id']);
      
      return shareableLink;
    } catch (e) {
      throw Exception('Failed to upload PDF report: $e');
    }
  }

  /// Create a folder in Box.com
  Future<Map<String, dynamic>> createFolder({
    required String folderName,
    required String parentFolderId,
  }) async {
    try {
      // First, check if folder already exists
      final existingFolder = await getFolderByName(
        folderName: folderName,
        parentFolderId: parentFolderId,
      );
      
      if (existingFolder != null) {
        return existingFolder;
      }
      
      // Create new folder
      final response = await http.post(
        Uri.parse('$_baseUrl/folders'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': folderName,
          'parent': {'id': parentFolderId},
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 409) {
        // 409 means folder already exists
        if (response.statusCode == 409) {
          // Get the existing folder
          return await getFolderByName(
            folderName: folderName,
            parentFolderId: parentFolderId,
          ) ?? {};
        }
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create folder: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create folder in Box: $e');
    }
  }

  /// Get folder by name
  Future<Map<String, dynamic>?> getFolderByName({
    required String folderName,
    required String parentFolderId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/folders/$parentFolderId/items'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final entries = jsonResponse['entries'] as List;
        
        for (final entry in entries) {
          if (entry['type'] == 'folder' && entry['name'] == folderName) {
            return entry;
          }
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting folder by name: $e');
      return null;
    }
  }

  /// Create a shared link for a file
  Future<String> createSharedLink(String fileId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/files/$fileId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'shared_link': {
            'access': 'open',
            'permissions': {
              'can_download': true,
              'can_preview': true,
            },
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['shared_link']['url'];
      } else {
        throw Exception('Failed to create shared link: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create shared link: $e');
    }
  }

  /// Generate a shareable folder link for container
  Future<String> generateShareableLink(String containerNumber) async {
    try {
      // Get container folder
      final containerFolder = await getFolderByName(
        folderName: containerNumber,
        parentFolderId: _folderId,
      );
      
      if (containerFolder == null) {
        throw Exception('Container folder not found');
      }
      
      final folderId = containerFolder['id'];
      
      // Create shared link for folder
      final response = await http.put(
        Uri.parse('$_baseUrl/folders/$folderId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'shared_link': {
            'access': 'open',
            'permissions': {
              'can_download': true,
              'can_preview': true,
            },
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['shared_link']['url'];
      } else {
        throw Exception('Failed to create folder shared link: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to generate shareable link: $e');
    }
  }

  /// Delete a file from Box.com
  Future<void> deleteFile(String fileId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/files/$fileId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );
      
      if (response.statusCode != 204) {
        print('Failed to delete file: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to delete file from Box: $e');
    }
  }

  /// Delete a folder from Box.com
  Future<void> deleteFolder(String folderId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/folders/$folderId?recursive=true'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );
      
      if (response.statusCode != 204) {
        print('Failed to delete folder: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to delete folder from Box: $e');
    }
  }

  /// Refresh access token using refresh token
  Future<String> refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.box.com/oauth2/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': _clientId,
          'client_secret': _clientSecret,
        },
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['access_token'];
      } else {
        throw Exception('Failed to refresh token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to refresh access token: $e');
    }
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class GoogleDriveService {
  static const List<String> _scopes = [
    drive.DriveApi.driveFileScope,
  ];

  drive.DriveApi? _driveApi;
  bool _isConfigured = false;

  // Check if Google Drive is properly configured
  Future<bool> isConfigured() async {
    if (_isConfigured) return true;
    
    final prefs = await SharedPreferences.getInstance();
    final hasCredentials = prefs.getString('google_drive_credentials') != null;
    _isConfigured = hasCredentials;
    return hasCredentials;
  }

  Future<bool> initialize() async {
    try {
      // Check if credentials are stored
      final prefs = await SharedPreferences.getInstance();
      final credentialsJson = prefs.getString('google_drive_credentials');
      
      if (credentialsJson == null) {
        Logger.warning('Google Drive credentials not configured. Please set up credentials first.');
        return false;
      }

      final credentialsMap = jsonDecode(credentialsJson) as Map<String, dynamic>;
      
      // Validate required fields
      if (!_validateCredentials(credentialsMap)) {
        Logger.error('Invalid Google Drive credentials format');
        return false;
      }

      final credentials = ServiceAccountCredentials.fromJson(credentialsMap);
      final client = await clientViaServiceAccount(credentials, _scopes);
      _driveApi = drive.DriveApi(client);
      _isConfigured = true;
      
      Logger.info('Google Drive service initialized successfully');
      return true;
    } catch (e) {
      Logger.error('Failed to initialize Google Drive service: $e');
      return false;
    }
  }

  // Validate credentials format
  bool _validateCredentials(Map<String, dynamic> credentials) {
    final requiredFields = [
      'type',
      'project_id',
      'private_key_id',
      'private_key',
      'client_email',
      'client_id',
      'auth_uri',
      'token_uri',
      'auth_provider_x509_cert_url',
      'client_x509_cert_url'
    ];

    for (final field in requiredFields) {
      if (!credentials.containsKey(field) || credentials[field] == null) {
        Logger.error('Missing required field in credentials: $field');
        return false;
      }
    }

    // Validate private key format
    final privateKey = credentials['private_key'] as String;
    if (!privateKey.startsWith('-----BEGIN PRIVATE KEY-----') || 
        !privateKey.endsWith('-----END PRIVATE KEY-----')) {
      Logger.error('Invalid private key format');
      return false;
    }

    return true;
  }

  // Set up Google Drive credentials
  Future<bool> setupCredentials(Map<String, dynamic> credentials) async {
    try {
      if (!_validateCredentials(credentials)) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('google_drive_credentials', jsonEncode(credentials));
      _isConfigured = true;
      
      Logger.info('Google Drive credentials saved successfully');
      return true;
    } catch (e) {
      Logger.error('Failed to save Google Drive credentials: $e');
      return false;
    }
  }

  // Remove Google Drive credentials
  Future<bool> removeCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('google_drive_credentials');
      _isConfigured = false;
      _driveApi = null;
      
      Logger.info('Google Drive credentials removed successfully');
      return true;
    } catch (e) {
      Logger.error('Failed to remove Google Drive credentials: $e');
      return false;
    }
  }

  Future<bool> uploadBackup(File backupFile) async {
    try {
      if (!await isConfigured()) {
        Logger.warning('Google Drive not configured. Skipping upload.');
        return false;
      }

      if (_driveApi == null) {
        final initialized = await initialize();
        if (!initialized) return false;
      }

      final fileName = backupFile.path.split('/').last;
      
      final file = drive.File()
        ..name = fileName
        ..parents = ['root']; // Upload to root folder

      final media = drive.Media(
        backupFile.openRead(),
        backupFile.lengthSync(),
      );

      await _driveApi!.files.create(file, uploadMedia: media);
      Logger.info('Backup uploaded to Google Drive: $fileName');
      return true;
    } catch (e) {
      Logger.error('Failed to upload backup: $e');
      return false;
    }
  }

  Future<List<drive.File>> listBackups() async {
    try {
      if (!await isConfigured()) {
        Logger.warning('Google Drive not configured. Cannot list backups.');
        return [];
      }

      if (_driveApi == null) {
        final initialized = await initialize();
        if (!initialized) return [];
      }

      final response = await _driveApi!.files.list(
        q: "name contains 'se_backup_' and trashed=false",
        orderBy: 'createdTime desc',
      );

      return response.files ?? [];
    } catch (e) {
      Logger.error('Failed to list backups: $e');
      return [];
    }
  }

  Future<bool> downloadBackup(String fileId, String fileName) async {
    try {
      if (!await isConfigured()) {
        Logger.warning('Google Drive not configured. Cannot download backup.');
        return false;
      }

      if (_driveApi == null) {
        final initialized = await initialize();
        if (!initialized) return false;
      }

      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) return false;

      final filePath = '${downloadsDir.path}/$fileName';
      final file = File(filePath);

      final response = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as http.Response;

      await file.writeAsBytes(response.bodyBytes);
      Logger.info('Backup downloaded from Google Drive: $fileName');
      return true;
    } catch (e) {
      Logger.error('Failed to download backup: $e');
      return false;
    }
  }

  Future<bool> deleteBackup(String fileId) async {
    try {
      if (!await isConfigured()) {
        Logger.warning('Google Drive not configured. Cannot delete backup.');
        return false;
      }

      if (_driveApi == null) {
        final initialized = await initialize();
        if (!initialized) return false;
      }

      await _driveApi!.files.delete(fileId);
      Logger.info('Backup deleted from Google Drive: $fileId');
      return true;
    } catch (e) {
      Logger.error('Failed to delete backup: $e');
      return false;
    }
  }
} 
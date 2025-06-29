import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import 'google_drive_service.dart';
import 'package:intl/intl.dart';
import '../utils/logger.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final GoogleDriveService _googleDriveService = GoogleDriveService();

  // Backup types
  static const String localBackup = 'local';
  static const String cloudBackup = 'cloud';

  // Initialize backup service
  Future<void> initialize() async {
    await _scheduleDailyBackup();
  }

  // Get backup directory
  Future<Directory> getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(join(appDir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  // Generate backup filename with date
  String generateBackupFilename(String type) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now);
    return 'se_${type}_backup_$dateStr.json';
  }

  // Create backup data
  Future<Map<String, dynamic>> createBackupData() async {
    try {
      final db = await _databaseHelper.database;
      
      // Get all data from database
      final bills = await db.query('bills');
      final vehicles = await db.query('vehicles');
      final advancePayments = await db.query('advance_payments');
      final drivers = await db.query('drivers');
      final driverEntries = await db.query('driver_entries');
      final driverAdvancePayments = await db.query('driver_advance_payments');
      final users = await db.query('users');

      return {
        'backup_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'data': {
          'bills': bills,
          'vehicles': vehicles,
          'advance_payments': advancePayments,
          'drivers': drivers,
          'driver_entries': driverEntries,
          'driver_advance_payments': driverAdvancePayments,
          'users': users,
        },
        'metadata': {
          'total_bills': bills.length,
          'total_vehicles': vehicles.length,
          'total_advance_payments': advancePayments.length,
          'total_drivers': drivers.length,
          'total_driver_entries': driverEntries.length,
          'total_driver_advance_payments': driverAdvancePayments.length,
        }
      };
    } catch (e) {
      throw Exception('Failed to create backup data: $e');
    }
  }

  // Local backup
  Future<bool> performLocalBackup() async {
    try {
      final backupData = await createBackupData();
      final backupDir = await getBackupDirectory();
      final filename = generateBackupFilename(localBackup);
      final backupFile = File(join(backupDir.path, filename));
      
      // Write backup data to file
      await backupFile.writeAsString(jsonEncode(backupData));
      
      // Copy to Downloads folder
      await _copyToDownloads(backupFile, filename);
      
      // Save backup record
      await _saveBackupRecord(localBackup, filename, backupData['metadata']);
      
      Logger.info('Local backup completed: $filename');
      return true;
    } catch (e) {
      Logger.error('Local backup failed: $e');
      return false;
    }
  }

  // Cloud backup (Google Drive)
  Future<bool> performCloudBackup() async {
    try {
      final backupData = await createBackupData();
      final backupDir = await getBackupDirectory();
      final filename = generateBackupFilename(cloudBackup);
      final backupFile = File(join(backupDir.path, filename));
      
      // Write backup data to file
      await backupFile.writeAsString(jsonEncode(backupData));
      
      // Upload to Google Drive
      final uploadSuccess = await _googleDriveService.uploadBackup(backupFile);
      
      if (uploadSuccess) {
        // Copy to Downloads folder
        await _copyToDownloads(backupFile, filename);
        
        // Save backup record
        await _saveBackupRecord(cloudBackup, filename, backupData['metadata']);
        
        Logger.info('Cloud backup completed: $filename');
        return true;
      }
      
      return false;
    } catch (e) {
      Logger.error('Cloud backup failed: $e');
      return false;
    }
  }

  // Copy backup file to Downloads folder
  Future<void> _copyToDownloads(File sourceFile, String filename) async {
    try {
      // Get Downloads directory
      final downloadsDir = await _getDownloadsDirectory();
      final destinationFile = File(join(downloadsDir.path, filename));
      
      // Copy the file
      await sourceFile.copy(destinationFile.path);
      Logger.info('Backup copied to Downloads: ${destinationFile.path}');
    } catch (e) {
      Logger.error('Failed to copy to Downloads: $e');
      // Don't throw error as this is not critical for backup functionality
    }
  }

  // Get Downloads directory
  Future<Directory> _getDownloadsDirectory() async {
    try {
      // Try to get Downloads directory
      final appDir = await getApplicationDocumentsDirectory();
      
      // For Android, try the external storage Downloads
      if (Platform.isAndroid) {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final androidDownloads = Directory(join(externalDir.path, '..', '..', 'Download'));
          if (await androidDownloads.exists()) {
            return androidDownloads;
          }
        }
      }
      
      // For Windows, try the user's Downloads folder
      if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null) {
          final windowsDownloads = Directory(join(userProfile, 'Downloads'));
          if (await windowsDownloads.exists()) {
            return windowsDownloads;
          }
        }
      }
      
      // Fallback to app documents directory with Downloads subfolder
      final fallbackDownloads = Directory(join(appDir.path, 'Downloads'));
      if (!await fallbackDownloads.exists()) {
        await fallbackDownloads.create(recursive: true);
      }
      return fallbackDownloads;
      
    } catch (e) {
      Logger.error('Error getting Downloads directory: $e');
      // Fallback to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fallbackDownloads = Directory(join(appDir.path, 'Downloads'));
      if (!await fallbackDownloads.exists()) {
        await fallbackDownloads.create(recursive: true);
      }
      return fallbackDownloads;
    }
  }

  // Save backup record
  Future<void> _saveBackupRecord(String type, String filename, Map<String, dynamic> metadata) async {
    final prefs = await SharedPreferences.getInstance();
    final backupRecords = prefs.getStringList('backup_records') ?? [];
    
    final record = {
      'type': type,
      'filename': filename,
      'date': DateTime.now().toIso8601String(),
      'metadata': metadata,
    };
    
    backupRecords.add(jsonEncode(record));
    
    // Keep only last 30 backup records
    if (backupRecords.length > 30) {
      backupRecords.removeAt(0);
    }
    
    await prefs.setStringList('backup_records', backupRecords);
  }

  // Restore from backup
  Future<bool> restoreFromBackup(String filename, String type) async {
    try {
      final backupDir = await getBackupDirectory();
      final backupFile = File(join(backupDir.path, filename));
      
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found: $filename');
      }
      
      final backupContent = await backupFile.readAsString();
      final backupData = jsonDecode(backupContent) as Map<String, dynamic>;
      
      // Validate backup data
      if (!_validateBackupData(backupData)) {
        throw Exception('Invalid backup data format');
      }
      
      // Restore data to database
      await _restoreDataToDatabase(backupData['data']);
      
      Logger.info('Restore completed from: $filename');
      return true;
    } catch (e) {
      Logger.error('Restore failed: $e');
      return false;
    }
  }

  // Validate backup data
  bool _validateBackupData(Map<String, dynamic> backupData) {
    return backupData.containsKey('data') && 
           backupData.containsKey('backup_date') &&
           backupData['data'] is Map<String, dynamic>;
  }

  // Restore data to database
  Future<void> _restoreDataToDatabase(Map<String, dynamic> data) async {
    final db = await _databaseHelper.database;
    
    // Clear existing data
    await db.delete('bills');
    await db.delete('vehicles');
    await db.delete('advance_payments');
    await db.delete('drivers');
    await db.delete('driver_entries');
    await db.delete('driver_advance_payments');
    // Don't delete users table to preserve login credentials
    
    // Restore data
    if (data['bills'] != null) {
      for (final bill in data['bills']) {
        await db.insert('bills', bill);
      }
    }
    
    if (data['vehicles'] != null) {
      for (final vehicle in data['vehicles']) {
        await db.insert('vehicles', vehicle);
      }
    }
    
    if (data['advance_payments'] != null) {
      for (final payment in data['advance_payments']) {
        await db.insert('advance_payments', payment);
      }
    }
    
    if (data['drivers'] != null) {
      for (final driver in data['drivers']) {
        await db.insert('drivers', driver);
      }
    }
    
    if (data['driver_entries'] != null) {
      for (final entry in data['driver_entries']) {
        await db.insert('driver_entries', entry);
      }
    }
    
    if (data['driver_advance_payments'] != null) {
      for (final payment in data['driver_advance_payments']) {
        await db.insert('driver_advance_payments', payment);
      }
    }
  }

  // Get backup history
  Future<List<Map<String, dynamic>>> getBackupHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final backupRecords = prefs.getStringList('backup_records') ?? [];
    
    return backupRecords.map((record) {
      final data = jsonDecode(record) as Map<String, dynamic>;
      return {
        'type': data['type'],
        'filename': data['filename'],
        'date': data['date'],
        'metadata': data['metadata'],
      };
    }).toList();
  }

  // Schedule daily backup
  Future<void> _scheduleDailyBackup() async {
    // This would typically use a background task scheduler
    // For now, we'll check if daily backup is needed when app starts
    await _checkAndPerformDailyBackup();
  }

  // Check and perform daily backup
  Future<void> _checkAndPerformDailyBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBackupDate = prefs.getString('last_daily_backup_date');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    if (lastBackupDate != today) {
      // Perform daily backups
      await performLocalBackup();
      await performCloudBackup();
      
      // Update last backup date
      await prefs.setString('last_daily_backup_date', today);
    }
  }

  // Manual daily backup check
  Future<void> performDailyBackupIfNeeded() async {
    await _checkAndPerformDailyBackup();
  }

  // Get backup statistics
  Future<Map<String, dynamic>> getBackupStats() async {
    final backupHistory = await getBackupHistory();
    final backupDir = await getBackupDirectory();
    
    int localBackupCount = 0;
    int cloudBackupCount = 0;
    int totalSize = 0;
    
    for (final record in backupHistory) {
      if (record['type'] == localBackup) {
        localBackupCount++;
      } else if (record['type'] == cloudBackup) {
        cloudBackupCount++;
      }
      
      final file = File(join(backupDir.path, record['filename']));
      if (await file.exists()) {
        totalSize += await file.length();
      }
    }
    
    return {
      'total_backups': backupHistory.length,
      'local_backups': localBackupCount,
      'cloud_backups': cloudBackupCount,
      'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'last_backup': backupHistory.isNotEmpty ? backupHistory.last['date'] : null,
    };
  }

  // Copy all existing backups to Downloads
  Future<bool> copyAllBackupsToDownloads() async {
    try {
      final backupHistory = await getBackupHistory();
      final backupDir = await getBackupDirectory();
      int copiedCount = 0;
      
      for (final record in backupHistory) {
        final sourceFile = File(join(backupDir.path, record['filename']));
        if (await sourceFile.exists()) {
          await _copyToDownloads(sourceFile, record['filename']);
          copiedCount++;
        }
      }
      
      Logger.info('Copied $copiedCount backup files to Downloads');
      return copiedCount > 0;
    } catch (e) {
      Logger.error('Failed to copy backups to Downloads: $e');
      return false;
    }
  }

  // Get backup file path in Downloads
  Future<String?> getBackupInDownloadsPath(String filename) async {
    try {
      final downloadsDir = await _getDownloadsDirectory();
      final downloadsFile = File(join(downloadsDir.path, filename));
      
      if (await downloadsFile.exists()) {
        return downloadsFile.path;
      }
      return null;
    } catch (e) {
      Logger.error('Error getting backup in Downloads path: $e');
      return null;
    }
  }
} 
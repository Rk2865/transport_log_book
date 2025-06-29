import 'package:flutter/material.dart';
import '../services/backup_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBiometricsEnabled = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadBiometricsSetting();
  }

  Future<void> _loadBiometricsSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricsEnabled = prefs.getBool('biometrics_enabled') ?? false;
    });
  }

  Future<void> _setBiometricsSetting(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometrics_enabled', enabled);
    setState(() {
      _isBiometricsEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
          children: [
            const SizedBox(height: 30),
            _buildSectionHeader('Security'),
            _buildSettingToggle(
              'Biometrics',
              'Enable biometric authentication',
              _isBiometricsEnabled,
              (bool value) async {
                if (value) {
                  bool canCheck = await _localAuth.canCheckBiometrics;
                  if (!canCheck) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Biometric authentication not available on this device.')),
                    );
                    return;
                  }
                }
                await _setBiometricsSetting(value);
              },
            ),
            const SizedBox(height: 30),
            _buildSectionHeader('Backups'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                "Local Backup & Restore",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: localBackup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Backup Locally"),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: localRestore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Restore from Local"),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Cloud Backup & Restore",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: driveBackup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Backup to Google Drive"),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: driveRestore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Restore from Drive"),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Backup Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• All backup files are automatically copied to your Downloads folder',
                      style: TextStyle(fontSize: 14, color: Colors.blue[800]),
                    ),
                    Text(
                      '• Backup files are named with date and time for easy identification',
                      style: TextStyle(fontSize: 14, color: Colors.blue[800]),
                    ),
                    Text(
                      '• You can access backup files directly from your Downloads folder',
                      style: TextStyle(fontSize: 14, color: Colors.blue[800]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: copyExistingBackupsToDownloads,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Copy Existing Backups to Downloads"),
                ),
              ),
            ],
            ),
            const SizedBox(height: 20),
          ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  // Backup and Restore Methods
  void localBackup() async {
    try {
      final backupService = BackupService();
      final success = await backupService.performLocalBackup();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local backup completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local backup failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void localRestore() async {
    try {
      final currentContext = context;
      final backupService = BackupService();
      final backupHistory = await backupService.getBackupHistory();
      final localBackups = backupHistory.where((b) => b['type'] == 'local').toList();
      
      if (localBackups.isEmpty) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('No local backups found.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Show backup selection dialog
      _showBackupSelectionDialog(localBackups, 'local');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void driveBackup() async {
    try {
      final currentContext = context;
      final backupService = BackupService();
      final success = await backupService.performCloudBackup();
      
      if (success) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Cloud backup completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Cloud backup failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void driveRestore() async {
    try {
      final currentContext = context;
      final backupService = BackupService();
      final backupHistory = await backupService.getBackupHistory();
      final cloudBackups = backupHistory.where((b) => b['type'] == 'cloud').toList();
      
      if (cloudBackups.isEmpty) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('No cloud backups found.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Show backup selection dialog
      _showBackupSelectionDialog(cloudBackups, 'cloud');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBackupSelectionDialog(List<Map<String, dynamic>> backups, String type) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select ${type == 'local' ? 'Local' : 'Cloud'} Backup to Restore'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: backups.length,
              itemBuilder: (context, index) {
                final backup = backups[backups.length - 1 - index]; // Show newest first
                final date = DateTime.parse(backup['date']);
                final metadata = backup['metadata'] as Map<String, dynamic>;
                
                return ListTile(
                  title: Text('Backup ${backups.length - index}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                      Text('Date: ${date.toString().substring(0, 19)}'),
                      Text('Bills: ${metadata['total_bills']}'),
                      Text('Vehicles: ${metadata['total_vehicles']}'),
                      Text('Drivers: ${metadata['total_drivers']}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore, color: Colors.blue),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _performRestore(backup['filename'], type);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performRestore(String filename, String type) async {
    try {
      final currentContext = context;
      final backupService = BackupService();
      final success = await backupService.restoreFromBackup(filename, type);
      
      if (success) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('${type == 'local' ? 'Local' : 'Cloud'} restore completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('${type == 'local' ? 'Local' : 'Cloud'} restore failed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void copyExistingBackupsToDownloads() async {
    try {
      final currentContext = context;
      final backupService = BackupService();
      final success = await backupService.copyAllBackupsToDownloads();
      
      if (success) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('All existing backups copied to Downloads folder successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('No existing backups found to copy.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error copying backups: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 
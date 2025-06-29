import 'package:flutter/material.dart';
import '../services/backup_service.dart';
import '../utils/logger.dart';
// import 'scan_document_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkDailyBackup();
  }

  Future<void> _checkDailyBackup() async {
    try {
      final backupService = BackupService();
      await backupService.performDailyBackupIfNeeded();
    } catch (e) {
      Logger.error('Daily backup check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Image.asset(
                  'assets/logo_2.png',
                  width: 280,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Transport Book',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              _buildHomeButton(context, 'Create Bill', Icons.add_box, () => Navigator.pushNamed(context, '/new_bill')),
              const SizedBox(height: 20),
              _buildHomeButton(context, 'Generate Bill', Icons.receipt_long, () => Navigator.pushNamed(context, '/generate_bill'), isPrimary: false),
              const SizedBox(height: 20),
              _buildHomeButton(context, 'Record', Icons.history, () => Navigator.pushNamed(context, '/record'), isPrimary: false),
              const SizedBox(height: 20),
              _buildHomeButton(context, 'Advance Payment', Icons.payments, () => Navigator.pushNamed(context, '/advance_payment'), isPrimary: false),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSmallHomeButton(context, 'Manage Vehicles', () => Navigator.pushNamed(context, '/manage_vehicles')),
                  _buildSmallHomeButton(context, 'Settings', () => Navigator.pushNamed(context, '/settings')),
                ],
              ),
              const SizedBox(height: 16),
              _buildDriverKhataButton(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Row(
          children: [
            // Removed Scan Document and View Document buttons
          ],
        ),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context, String text, IconData icon, VoidCallback onPressed, {bool isPrimary = true}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.blue : Colors.grey[200],
          foregroundColor: isPrimary ? Colors.white : Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: isPrimary ? 3 : 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isPrimary ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallHomeButton(BuildContext context, String text, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverKhataButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/driver_khata');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Driver Khata',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
} 
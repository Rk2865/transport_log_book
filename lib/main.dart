import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/home_screen.dart';
import 'screens/new_bill_screen.dart';
import 'screens/generate_bill_screen.dart';
import 'screens/advance_payment_screen.dart';
import 'screens/manage_vehicles_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/record_screen.dart';
import 'screens/driver_khata_screen.dart';
import 'database/database_service.dart';
import 'services/backup_service.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize database service
    final databaseService = DatabaseService();
    bool isInitialized = await databaseService.initialize();
    
    if (isInitialized) {
      Logger.info('Database service initialized successfully');
      
      // Get database info
      Map<String, dynamic> dbInfo = await databaseService.getDatabaseInfo();
      Logger.info('Database info: $dbInfo');
    } else {
      Logger.error('Database service initialization failed');
    }
    
    // Initialize backup service
    final backupService = BackupService();
    await backupService.initialize();
    Logger.info('Backup service initialized successfully');
    
  } catch (e) {
    Logger.error('Error initializing services: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transport Log Book',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
        '/new_bill': (context) => const NewBillScreen(),
        '/generate_bill': (context) => const GenerateBillScreen(),
        '/advance_payment': (context) => const AdvancePaymentScreen(),
        '/manage_vehicles': (context) => const ManageVehiclesScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/record': (context) => const RecordScreen(),
        '/driver_khata': (context) => const DriverKhataScreen(),
      },
    );
  }
}

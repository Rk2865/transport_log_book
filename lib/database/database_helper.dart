import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../utils/logger.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      // Use getDatabasesPath() for Android which is the recommended approach
      String path = join(await getDatabasesPath(), 'transport_log_book.db');
      
      // Check if database exists
      bool exists = await databaseExists(path);
      
      if (!exists) {
        // Make sure the directory exists
        try {
          await Directory(dirname(path)).create(recursive: true);
        } catch (_) {}
      }
      
      return await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        singleInstance: true,
      );
    } catch (e) {
      Logger.error('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      // Bills table
      await db.execute('''
        CREATE TABLE bills (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          vehicle_number TEXT NOT NULL,
          load_weight REAL NOT NULL,
          unload_weight REAL NOT NULL,
          short_weight REAL NOT NULL,
          rate REAL NOT NULL,
          short_rate REAL NOT NULL,
          short_amount REAL NOT NULL,
          amount REAL NOT NULL,
          advance REAL NOT NULL,
          expenses REAL NOT NULL,
          round_off REAL NOT NULL,
          net_balance REAL NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      // Users table
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL
        )
      ''');
      // Insert default user
      await db.insert('users', {
        'user_id': 'Ajay2865',
        'password': 'Sharma@2865',
      });

      // Vehicles table
      await db.execute('''
        CREATE TABLE vehicles (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          vehicle_number TEXT UNIQUE NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      // Advance payments table
      await db.execute('''
        CREATE TABLE advance_payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          vehicle_number TEXT NOT NULL,
          amount REAL NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      // Drivers table
      await db.execute('''
        CREATE TABLE drivers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          truck_number TEXT NOT NULL,
          driver_name TEXT NOT NULL
        )
      ''');

      // Driver entries table
      await db.execute('''
        CREATE TABLE driver_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          driver_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          punji REAL NOT NULL,
          advance REAL NOT NULL,
          expenses REAL NOT NULL,
          total_expenses REAL NOT NULL,
          note TEXT,
          FOREIGN KEY(driver_id) REFERENCES drivers(id) ON DELETE CASCADE
        )
      ''');

      // Driver advance payments table
      await db.execute('''
        CREATE TABLE driver_advance_payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          driver_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          amount REAL NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY(driver_id) REFERENCES drivers(id) ON DELETE CASCADE
        )
      ''');
      
      Logger.info('Database tables created successfully');
    } catch (e) {
      Logger.error('Error creating database tables: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    Logger.info('Upgrading database from version $oldVersion to $newVersion');
    
    if (oldVersion < 2) {
      // Add driver_advance_payments table for version 2
      await db.execute('''
        CREATE TABLE driver_advance_payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          driver_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          amount REAL NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY(driver_id) REFERENCES drivers(id) ON DELETE CASCADE
        )
      ''');
      Logger.info('Added driver_advance_payments table');
    }
  }

  // Bills CRUD operations
  Future<int> insertBill(Map<String, dynamic> bill) async {
    try {
      Database db = await database;
      bill['created_at'] = DateTime.now().toIso8601String();
      int id = await db.insert('bills', bill);
      Logger.info('Bill inserted with ID: $id');
      return id;
    } catch (e) {
      Logger.error('Error inserting bill: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllBills() async {
    try {
      Database db = await database;
      return await db.query('bills', orderBy: 'created_at DESC');
    } catch (e) {
      Logger.error('Error getting all bills: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBillsByDate(String date) async {
    try {
      Database db = await database;
      return await db.query('bills', where: 'date = ?', whereArgs: [date]);
    } catch (e) {
      Logger.error('Error getting bills by date: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBillsByVehicle(String vehicleNumber) async {
    try {
      Database db = await database;
      return await db.query('bills', where: 'vehicle_number = ?', whereArgs: [vehicleNumber]);
    } catch (e) {
      Logger.error('Error getting bills by vehicle: $e');
      rethrow;
    }
  }

  Future<int> updateBill(Map<String, dynamic> bill) async {
    try {
      Database db = await database;
      return await db.update('bills', bill, where: 'id = ?', whereArgs: [bill['id']]);
    } catch (e) {
      Logger.error('Error updating bill: $e');
      rethrow;
    }
  }

  Future<int> deleteBill(int id) async {
    try {
      Database db = await database;
      return await db.delete('bills', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      Logger.error('Error deleting bill: $e');
      rethrow;
    }
  }

  // Vehicles CRUD operations
  Future<int> insertVehicle(Map<String, dynamic> vehicle) async {
    try {
      Database db = await database;
      vehicle['created_at'] = DateTime.now().toIso8601String();
      int id = await db.insert('vehicles', vehicle);
      Logger.info('Vehicle inserted with ID: $id');
      return id;
    } catch (e) {
      Logger.error('Error inserting vehicle: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllVehicles() async {
    try {
      Database db = await database;
      return await db.query('vehicles', orderBy: 'created_at DESC');
    } catch (e) {
      Logger.error('Error getting all vehicles: $e');
      rethrow;
    }
  }

  Future<int> updateVehicle(Map<String, dynamic> vehicle) async {
    try {
      Database db = await database;
      return await db.update('vehicles', vehicle, where: 'id = ?', whereArgs: [vehicle['id']]);
    } catch (e) {
      Logger.error('Error updating vehicle: $e');
      rethrow;
    }
  }

  Future<int> deleteVehicle(int id) async {
    try {
      Database db = await database;
      return await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      Logger.error('Error deleting vehicle: $e');
      rethrow;
    }
  }

  // Advance payments CRUD operations
  Future<int> insertAdvancePayment(Map<String, dynamic> payment) async {
    try {
      Database db = await database;
      payment['created_at'] = DateTime.now().toIso8601String();
      int id = await db.insert('advance_payments', payment);
      Logger.info('Advance payment inserted with ID: $id');
      return id;
    } catch (e) {
      Logger.error('Error inserting advance payment: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllAdvancePayments() async {
    try {
      Database db = await database;
      return await db.query('advance_payments', orderBy: 'created_at DESC');
    } catch (e) {
      Logger.error('Error getting all advance payments: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAdvancePaymentsByVehicle(String vehicleNumber) async {
    try {
      Database db = await database;
      return await db.query('advance_payments', where: 'vehicle_number = ?', whereArgs: [vehicleNumber]);
    } catch (e) {
      Logger.error('Error getting advance payments by vehicle: $e');
      rethrow;
    }
  }

  Future<int> updateAdvancePayment(Map<String, dynamic> payment) async {
    try {
      Database db = await database;
      return await db.update('advance_payments', payment, where: 'id = ?', whereArgs: [payment['id']]);
    } catch (e) {
      Logger.error('Error updating advance payment: $e');
      rethrow;
    }
  }

  Future<int> deleteAdvancePayment(int id) async {
    try {
      Database db = await database;
      return await db.delete('advance_payments', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      Logger.error('Error deleting advance payment: $e');
      rethrow;
    }
  }

  // User authentication
  Future<bool> validateUser(String userId, String password) async {
    Database db = await database;
    final result = await db.query(
      'users',
      where: 'user_id = ? AND password = ?',
      whereArgs: [userId, password],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Change user password
  Future<bool> changePassword(String userId, String newPassword) async {
    Database db = await database;
    int count = await db.update(
      'users',
      {'password': newPassword},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return count > 0;
  }

  // Driver CRUD operations
  Future<int> insertDriver(Map<String, dynamic> driver) async {
    Database db = await database;
    return await db.insert('drivers', driver);
  }

  Future<List<Map<String, dynamic>>> getAllDrivers() async {
    Database db = await database;
    return await db.query('drivers', orderBy: 'id DESC');
  }

  Future<int> deleteDriver(int id) async {
    Database db = await database;
    return await db.delete('drivers', where: 'id = ?', whereArgs: [id]);
  }

  // Driver entry CRUD operations
  Future<int> insertDriverEntry(Map<String, dynamic> entry) async {
    Database db = await database;
    return await db.insert('driver_entries', entry);
  }

  Future<List<Map<String, dynamic>>> getDriverEntries(int driverId) async {
    Database db = await database;
    return await db.query('driver_entries', where: 'driver_id = ?', whereArgs: [driverId], orderBy: 'date DESC');
  }

  Future<int> deleteDriverEntry(int id) async {
    Database db = await database;
    return await db.delete('driver_entries', where: 'id = ?', whereArgs: [id]);
  }

  // Driver advance payment CRUD operations
  Future<int> insertDriverAdvancePayment(Map<String, dynamic> payment) async {
    try {
      Database db = await database;
      payment['created_at'] = DateTime.now().toIso8601String();
      int id = await db.insert('driver_advance_payments', payment);
      Logger.info('Driver advance payment inserted with ID: $id');
      return id;
    } catch (e) {
      Logger.error('Error inserting driver advance payment: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllDriverAdvancePayments() async {
    try {
      Database db = await database;
      return await db.query('driver_advance_payments', orderBy: 'created_at DESC');
    } catch (e) {
      Logger.error('Error getting all driver advance payments: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDriverAdvancePaymentsByDriver(int driverId) async {
    try {
      Database db = await database;
      return await db.query('driver_advance_payments', where: 'driver_id = ?', whereArgs: [driverId], orderBy: 'date DESC');
    } catch (e) {
      Logger.error('Error getting driver advance payments by driver: $e');
      rethrow;
    }
  }

  Future<int> updateDriverAdvancePayment(Map<String, dynamic> payment) async {
    try {
      Database db = await database;
      return await db.update('driver_advance_payments', payment, where: 'id = ?', whereArgs: [payment['id']]);
    } catch (e) {
      Logger.error('Error updating driver advance payment: $e');
      rethrow;
    }
  }

  Future<int> deleteDriverAdvancePayment(int id) async {
    try {
      Database db = await database;
      return await db.delete('driver_advance_payments', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      Logger.error('Error deleting driver advance payment: $e');
      rethrow;
    }
  }

  // Utility methods
  Future<void> close() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
        Logger.info('Database closed successfully');
      }
    } catch (e) {
      Logger.error('Error closing database: $e');
    }
  }

  // Database health check
  Future<bool> isDatabaseHealthy() async {
    try {
      Database db = await database;
      await db.query('bills', limit: 1);
      await db.query('vehicles', limit: 1);
      await db.query('advance_payments', limit: 1);
      return true;
    } catch (e) {
      Logger.error('Database health check failed: $e');
      return false;
    }
  }

  // Get database info
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> bills = await db.query('bills');
      List<Map<String, dynamic>> vehicles = await db.query('vehicles');
      List<Map<String, dynamic>> payments = await db.query('advance_payments');
      
      return {
        'bills_count': bills.length,
        'vehicles_count': vehicles.length,
        'payments_count': payments.length,
        'database_path': db.path,
      };
    } catch (e) {
      Logger.error('Error getting database info: $e');
      rethrow;
    }
  }
} 
import 'database_helper.dart';
import '../models/bill.dart';
import '../models/vehicle.dart';
import '../models/advance_payment.dart';
import '../utils/logger.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  // Database initialization and health check
  Future<bool> initialize() async {
    try {
      await _databaseHelper.database;
      bool isHealthy = await _databaseHelper.isDatabaseHealthy();
      Logger.info('Database service initialized: $isHealthy');
      return isHealthy;
    } catch (e) {
      Logger.error('Error initializing database service: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      return await _databaseHelper.getDatabaseInfo();
    } catch (e) {
      Logger.error('Error getting database info: $e');
      rethrow;
    }
  }

  // Bill operations
  Future<bool> addBill(Bill bill) async {
    try {
      await _databaseHelper.insertBill(bill.toMap());
      return true;
    } catch (e) {
      Logger.error('Error adding bill: $e');
      return false;
    }
  }

  Future<List<Bill>> getAllBills() async {
    try {
      final billsData = await _databaseHelper.getAllBills();
      return billsData.map((data) => Bill.fromMap(data)).toList();
    } catch (e) {
      Logger.error('Error getting all bills: $e');
      return [];
    }
  }

  Future<List<Bill>> getBillsByDate(String date) async {
    try {
      final billsData = await _databaseHelper.getBillsByDate(date);
      return billsData.map((data) => Bill.fromMap(data)).toList();
    } catch (e) {
      Logger.error('Error getting bills by date: $e');
      return [];
    }
  }

  Future<List<Bill>> getBillsByVehicle(String vehicleNumber) async {
    try {
      final billsData = await _databaseHelper.getBillsByVehicle(vehicleNumber);
      return billsData.map((data) => Bill.fromMap(data)).toList();
    } catch (e) {
      Logger.error('Error getting bills by vehicle: $e');
      return [];
    }
  }

  Future<bool> updateBill(Bill bill) async {
    try {
      await _databaseHelper.updateBill(bill.toMap());
      return true;
    } catch (e) {
      Logger.error('Error updating bill: $e');
      return false;
    }
  }

  Future<bool> deleteBill(int id) async {
    try {
      await _databaseHelper.deleteBill(id);
      return true;
    } catch (e) {
      Logger.error('Error deleting bill: $e');
      return false;
    }
  }

  // Vehicle operations
  Future<bool> addVehicle(Vehicle vehicle) async {
    try {
      await _databaseHelper.insertVehicle(vehicle.toMap());
      return true;
    } catch (e) {
      Logger.error('Error adding vehicle: $e');
      return false;
    }
  }

  Future<List<Vehicle>> getAllVehicles() async {
    try {
      final vehiclesData = await _databaseHelper.getAllVehicles();
      return vehiclesData.map((data) => Vehicle.fromMap(data)).toList();
    } catch (e) {
      Logger.error('Error getting all vehicles: $e');
      return [];
    }
  }

  Future<bool> updateVehicle(Vehicle vehicle) async {
    try {
      await _databaseHelper.updateVehicle(vehicle.toMap());
      return true;
    } catch (e) {
      Logger.error('Error updating vehicle: $e');
      return false;
    }
  }

  Future<bool> deleteVehicle(int id) async {
    try {
      await _databaseHelper.deleteVehicle(id);
      return true;
    } catch (e) {
      Logger.error('Error deleting vehicle: $e');
      return false;
    }
  }

  // Advance payment operations
  Future<bool> addAdvancePayment(AdvancePayment payment) async {
    try {
      await _databaseHelper.insertAdvancePayment(payment.toMap());
      return true;
    } catch (e) {
      Logger.error('Error adding advance payment: $e');
      return false;
    }
  }

  Future<List<AdvancePayment>> getAllAdvancePayments() async {
    try {
      final paymentsData = await _databaseHelper.getAllAdvancePayments();
      return paymentsData.map((data) => AdvancePayment.fromMap(data)).toList();
    } catch (e) {
      Logger.error('Error getting all advance payments: $e');
      return [];
    }
  }

  Future<List<AdvancePayment>> getAdvancePaymentsByVehicle(String vehicleNumber) async {
    try {
      final paymentsData = await _databaseHelper.getAdvancePaymentsByVehicle(vehicleNumber);
      return paymentsData.map((data) => AdvancePayment.fromMap(data)).toList();
    } catch (e) {
      Logger.error('Error getting advance payments by vehicle: $e');
      return [];
    }
  }

  Future<bool> updateAdvancePayment(AdvancePayment payment) async {
    try {
      await _databaseHelper.updateAdvancePayment(payment.toMap());
      return true;
    } catch (e) {
      Logger.error('Error updating advance payment: $e');
      return false;
    }
  }

  Future<bool> deleteAdvancePayment(int id) async {
    try {
      await _databaseHelper.deleteAdvancePayment(id);
      return true;
    } catch (e) {
      Logger.error('Error deleting advance payment: $e');
      return false;
    }
  }

  // Utility operations
  Future<void> closeDatabase() async {
    try {
      await _databaseHelper.close();
      Logger.info('Database service closed');
    } catch (e) {
      Logger.error('Error closing database service: $e');
    }
  }

  // Data validation
  bool validateBill(Bill bill) {
    return bill.date.isNotEmpty &&
           bill.vehicleNumber.isNotEmpty &&
           bill.loadWeight > 0 &&
           bill.unloadWeight > 0 &&
           bill.rate > 0;
  }

  bool validateVehicle(Vehicle vehicle) {
    return vehicle.vehicleNumber.isNotEmpty;
  }

  bool validateAdvancePayment(AdvancePayment payment) {
    return payment.date.isNotEmpty &&
           payment.vehicleNumber.isNotEmpty &&
           payment.amount > 0;
  }

  // Bulk operations
  Future<bool> addMultipleVehicles(List<Vehicle> vehicles) async {
    try {
      for (Vehicle vehicle in vehicles) {
        if (validateVehicle(vehicle)) {
          await addVehicle(vehicle);
        }
      }
      return true;
    } catch (e) {
      Logger.error('Error adding multiple vehicles: $e');
      return false;
    }
  }

  Future<bool> addMultipleBills(List<Bill> bills) async {
    try {
      for (Bill bill in bills) {
        if (validateBill(bill)) {
          await addBill(bill);
        }
      }
      return true;
    } catch (e) {
      Logger.error('Error adding multiple bills: $e');
      return false;
    }
  }

  // Search operations
  Future<List<Bill>> searchBills(String query) async {
    try {
      final allBills = await getAllBills();
      return allBills.where((bill) =>
        bill.vehicleNumber.toLowerCase().contains(query.toLowerCase()) ||
        bill.date.contains(query)
      ).toList();
    } catch (e) {
      Logger.error('Error searching bills: $e');
      return [];
    }
  }

  Future<List<Vehicle>> searchVehicles(String query) async {
    try {
      final allVehicles = await getAllVehicles();
      return allVehicles.where((vehicle) =>
        vehicle.vehicleNumber.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      Logger.error('Error searching vehicles: $e');
      return [];
    }
  }
} 
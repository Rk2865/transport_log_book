import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../models/vehicle.dart';
import '../utils/logger.dart';

class ManageVehiclesScreen extends StatefulWidget {
  const ManageVehiclesScreen({super.key});

  @override
  State<ManageVehiclesScreen> createState() => _ManageVehiclesScreenState();
}

class _ManageVehiclesScreenState extends State<ManageVehiclesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _vehicleNumberController = TextEditingController();
  List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _databaseService.getAllVehicles();
      setState(() {
        _vehicles = vehicles;
      });
    } catch (e) {
      Logger.error('Error loading vehicles: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vehicles: $e')),
        );
      }
    }
  }

  Future<void> _addVehicle() async {
    if (_vehicleNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a vehicle number')),
      );
      return;
    }

    try {
      final vehicle = Vehicle(
        vehicleNumber: _vehicleNumberController.text.trim(),
        createdAt: DateTime.now().toIso8601String(),
      );
      
      // Validate vehicle before saving
      if (!_databaseService.validateVehicle(vehicle)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please check your input data')),
        );
        return;
      }
      
      bool success = await _databaseService.addVehicle(vehicle);
      
      if (success) {
        _vehicleNumberController.clear();
        _loadVehicles();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle added successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error adding vehicle')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding vehicle: $e')),
        );
      }
    }
  }

  Future<void> _removeVehicle(Vehicle vehicle) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Vehicle'),
          content: Text('Are you sure you want to delete vehicle ${vehicle.vehicleNumber}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  bool success = await _databaseService.deleteVehicle(vehicle.id!);
                  Navigator.of(context).pop();
                  
                  if (success) {
                    _loadVehicles();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vehicle deleted successfully!')),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error deleting vehicle')),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting vehicle: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
          'Manage Vehicles',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Vehicle Number'),
            _buildTextField('Enter Vehicle Number'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addVehicle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Add', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Vehicle List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _vehicles.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: Center(
                      child: Text(
                        'No vehicles added yet.\nAdd a vehicle using the form above.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: _vehicles.map((vehicle) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          vehicle.vehicleNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _removeVehicle(vehicle),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Delete'),
                        ),
                      ),
                    )).toList(),
                  ),
            const SizedBox(height: 20), // Add bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText) {
    return TextField(
      controller: _vehicleNumberController,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
    );
  }
} 
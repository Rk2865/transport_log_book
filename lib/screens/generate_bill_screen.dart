import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_service.dart';
import '../services/bill_generator.dart';
import '../utils/logger.dart';

class GenerateBillScreen extends StatefulWidget {
  const GenerateBillScreen({super.key});

  @override
  State<GenerateBillScreen> createState() => _GenerateBillScreenState();
}

class _GenerateBillScreenState extends State<GenerateBillScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedVehicle;
  List<String> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _databaseService.getAllVehicles();
      setState(() {
        _vehicles = vehicles.map((v) => v.vehicleNumber).toList();
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

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _generateBill() async {
    if (_dateController.text.isEmpty || _selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and vehicle')),
      );
      return;
    }

    try {
      final bills = await _databaseService.getBillsByDate(_dateController.text);
      final vehicleBills = bills.where((bill) => bill.vehicleNumber == _selectedVehicle).toList();
      
      if (vehicleBills.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No bills found for $_selectedVehicle on ${_dateController.text}')),
          );
        }
      } else {
        // Generate and download the bill
        final bill = vehicleBills.first; // Take the first bill if multiple exist
        try {
          await BillGenerator.generateBillPDF(bill);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bill generated successfully for $_selectedVehicle'),
                action: SnackBarAction(
                  label: 'View in Record',
                  onPressed: () {
                    Navigator.of(context).pop(); // Close current screen
                    Navigator.pushNamed(context, '/record'); // Navigate to record screen
                    // You can add a callback or parameter to automatically open download bills by date
                  },
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error generating bill: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating bill: $e')),
        );
      }
    }
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
          'Generate Bill',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Date'),
            _buildDateField(context, 'Date', Icons.calendar_today),
            const SizedBox(height: 20),
            _buildLabel('Vehicle No.'),
            _buildDropdownField('Select Vehicle'),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _generateBill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Generate & Download',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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

  Widget _buildDateField(BuildContext context, String hintText, IconData icon) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: _dateController,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[600]),
            suffixIcon: Icon(icon, color: Colors.grey),
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
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hintText) {
    return DropdownButtonFormField<String>(
      value: _selectedVehicle,
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
        suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
      items: _vehicles.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedVehicle = newValue;
        });
      },
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_service.dart';
import '../models/advance_payment.dart';
import '../utils/logger.dart';

class AdvancePaymentScreen extends StatefulWidget {
  const AdvancePaymentScreen({super.key});

  @override
  State<AdvancePaymentScreen> createState() => _AdvancePaymentScreenState();
}

class _AdvancePaymentScreenState extends State<AdvancePaymentScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedVehicle;
  List<String> _vehicles = [];
  final TextEditingController _amountController = TextEditingController();

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
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    if (_dateController.text.isEmpty || _selectedVehicle == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      final payment = AdvancePayment(
        date: _dateController.text,
        vehicleNumber: _selectedVehicle!,
        amount: double.parse(_amountController.text),
        createdAt: DateTime.now().toIso8601String(),
      );

      // Validate payment before saving
      if (!_databaseService.validateAdvancePayment(payment)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please check your input data')),
        );
        return;
      }

      bool success = await _databaseService.addAdvancePayment(payment);
      
      if (success) {
        _dateController.clear();
        _selectedVehicle = null;
        _amountController.clear();
        setState(() {});
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Advance payment saved successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error saving advance payment')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving advance payment: $e')),
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
          'Advance Payment',
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
            _buildLabel('Date'),
            _buildDateField(context, 'Select Date', Icons.calendar_today),
            const SizedBox(height: 20),
            _buildLabel('Vehicle Number'),
            _buildDropdownField('Select Vehicle'),
            const SizedBox(height: 20),
            _buildLabel('Amount'),
            _buildAmountField(),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitPayment,
                      child: const Text('Done'),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final currentContext = context;
                        final payments = await _databaseService.getAllAdvancePayments();
                        if (mounted) {
                          showDialog(
                            context: currentContext,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Advance Payments'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: payments.isEmpty
                                      ? const Text('No advance payments found.')
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: payments.length,
                                          itemBuilder: (context, index) {
                                            final payment = payments[index];
                                            return ListTile(
                                              title: Text(payment.vehicleNumber),
                                              subtitle: Text('Date: ${payment.date}'),
                                              trailing: Text('₹${payment.amount}'),
                                            );
                                          },
                                        ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        elevation: 0,
                      ),
                      child: const Text('View'),
                    ),
                  ),
                ),
              ],
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

  Widget _buildAmountField() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Enter Amount',
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixText: '₹ ',
        prefixStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500),
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
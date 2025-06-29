import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/driver.dart';

class DriverAdvancePaymentScreen extends StatefulWidget {
  const DriverAdvancePaymentScreen({super.key});

  @override
  State<DriverAdvancePaymentScreen> createState() => _DriverAdvancePaymentScreenState();
}

class _DriverAdvancePaymentScreenState extends State<DriverAdvancePaymentScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  Driver? _selectedDriver;
  List<Driver> _drivers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadDrivers() async {
    setState(() => _loading = true);
    try {
      final driverMaps = await _databaseHelper.getAllDrivers();
      setState(() {
        _drivers = driverMaps.map((e) => Driver.fromMap(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading drivers: $e')),
        );
      }
    }
  }

  Future<void> _submitPayment() async {
    if (_dateController.text.isEmpty || _selectedDriver == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }

      await _databaseHelper.insertDriverAdvancePayment({
        'driver_id': _selectedDriver!.id,
        'date': _dateController.text,
        'amount': amount,
      });

      _dateController.clear();
      _selectedDriver = null;
      _amountController.clear();
      setState(() {});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver advance payment saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving driver advance payment: $e')),
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
          'Driver Advance Payment',
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
            _buildLabel('Driver'),
            _buildDriverDropdownField('Select Driver'),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final payments = await _databaseHelper.getAllDriverAdvancePayments();
                        if (mounted) {
                          // Group payments by driver and date
                          Map<String, double> groupedPayments = {};
                          Map<String, String> driverNames = {};
                          
                          for (final payment in payments) {
                            final driverId = payment['driver_id'].toString();
                            final date = payment['date'];
                            final key = '$driverId-$date';
                            final amount = (payment['amount'] as num).toDouble();
                            
                            // Find driver name
                            final driver = _drivers.firstWhere(
                              (d) => d.id == payment['driver_id'],
                              orElse: () => Driver(truckNumber: 'Unknown', driverName: 'Unknown'),
                            );
                            driverNames[key] = '${driver.driverName} (${driver.truckNumber})';
                            
                            // Sum up amounts for same driver-date combination
                            groupedPayments[key] = (groupedPayments[key] ?? 0) + amount;
                          }
                          
                          final currentContext = context;
                          showDialog(
                            context: currentContext,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Driver Advance Payments'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: groupedPayments.isEmpty
                                      ? const Text('No driver advance payments found.')
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: groupedPayments.length,
                                          itemBuilder: (context, index) {
                                            final key = groupedPayments.keys.elementAt(index);
                                            final totalAmount = groupedPayments[key]!;
                                            final driverName = driverNames[key]!;
                                            final date = key.split('-')[1];
                                            
                                            return ListTile(
                                              title: Text(driverName),
                                              subtitle: Text('Date: $date'),
                                              trailing: Text('₹${totalAmount.toStringAsFixed(2)}'),
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
            const SizedBox(height: 20),
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
            _dateController.text = DateFormat('dd/MM/yy').format(pickedDate);
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

  Widget _buildDriverDropdownField(String hintText) {
    if (_loading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Row(
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 16),
            Text('Loading drivers...'),
          ],
        ),
      );
    }

    return DropdownButtonFormField<Driver>(
      value: _selectedDriver,
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
      items: _drivers.map<DropdownMenuItem<Driver>>((Driver driver) {
        return DropdownMenuItem<Driver>(
          value: driver,
          child: Text('${driver.driverName} (${driver.truckNumber})'),
        );
      }).toList(),
      onChanged: (Driver? newValue) {
        setState(() {
          _selectedDriver = newValue;
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
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/driver.dart';
import 'package:intl/intl.dart';
import 'driver_advance_payment_screen.dart';

class DriverKhataScreen extends StatefulWidget {
  const DriverKhataScreen({super.key});

  @override
  State<DriverKhataScreen> createState() => _DriverKhataScreenState();
}

class _DriverKhataScreenState extends State<DriverKhataScreen> {
  final TextEditingController _truckNumberController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Driver> _drivers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() => _loading = true);
    final db = DatabaseHelper();
    final driverMaps = await db.getAllDrivers();
    setState(() {
      _drivers = driverMaps.map((e) => Driver.fromMap(e)).toList();
      _loading = false;
    });
  }

  Future<void> _addDriver() async {
    if (_formKey.currentState!.validate()) {
      final db = DatabaseHelper();
      try {
        await db.insertDriver({
          'truck_number': _truckNumberController.text.trim(),
          'driver_name': _driverNameController.text.trim(),
        });
        _truckNumberController.clear();
        _driverNameController.clear();
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver added successfully')),
        );
        await _loadDrivers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add driver: \\${e.toString()}')),
        );
      }
    }
  }

  Future<void> _removeDriver(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Driver'),
        content: const Text('Are you sure you want to remove this driver? This will also delete all associated advance payments and entries.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final db = DatabaseHelper();
      try {
        // Delete all driver advance payments first
        final advancePayments = await db.getDriverAdvancePaymentsByDriver(id);
        for (final payment in advancePayments) {
          await db.deleteDriverAdvancePayment(payment['id']);
        }
        
        // Delete all driver entries
        final entries = await db.getDriverEntries(id);
        for (final entry in entries) {
          await db.deleteDriverEntry(entry['id']);
        }
        
        // Finally delete the driver
        await db.deleteDriver(id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver and all associated data removed')),
        );
        await _loadDrivers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove driver: ${e.toString()}')),
        );
      }
    }
  }

  void _showDriverSectionDialog(Driver driver) {
    final _dateController = TextEditingController();
    final _punjiController = TextEditingController();
    final _advanceController = TextEditingController();
    final _expensesController = TextEditingController();
    final _totalExpensesController = TextEditingController();
    final _noteController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    // Function to calculate total expenses
    void _calculateTotalExpenses() {
      final punji = double.tryParse(_punjiController.text) ?? 0;
      final advance = double.tryParse(_advanceController.text) ?? 0;
      final expenses = double.tryParse(_expensesController.text) ?? 0;
      _totalExpensesController.text = (punji + expenses - advance).toStringAsFixed(2);
    }

    // Function to load advance payment for the selected date
    Future<void> _loadAdvancePaymentForDate(String date) async {
      try {
        final db = DatabaseHelper();
        final advancePayments = await db.getDriverAdvancePaymentsByDriver(driver.id!);
        
        // Find all advance payments for the selected date and sum them up
        final paymentsForDate = advancePayments.where((payment) => payment['date'] == date).toList();
        
        if (paymentsForDate.isNotEmpty) {
          // Sum up all advance payments for this date
          double totalAdvance = 0;
          for (final payment in paymentsForDate) {
            totalAdvance += (payment['amount'] as num).toDouble();
          }
          _advanceController.text = totalAdvance.toString();
          // Trigger calculation
          _calculateTotalExpenses();
        } else {
          _advanceController.clear();
          _calculateTotalExpenses();
        }
      } catch (e) {
        print('Error loading advance payment: $e');
        _advanceController.clear();
        _calculateTotalExpenses();
      }
    }

    _punjiController.addListener(_calculateTotalExpenses);
    _advanceController.addListener(_calculateTotalExpenses);
    _expensesController.addListener(_calculateTotalExpenses);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Entry for ${driver.driverName}'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date (DD/MM/YY)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        _dateController.text = DateFormat('dd/MM/yy').format(picked);
                        await _loadAdvancePaymentForDate(_dateController.text);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter date';
                      final regex = RegExp(r'^\d{2}/\d{2}/\d{2}$');
                      if (!regex.hasMatch(value)) return 'Format: DD/MM/YY';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _punjiController,
                    decoration: const InputDecoration(
                      labelText: 'Driver Punji',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Enter punji' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _advanceController,
                    decoration: const InputDecoration(
                      labelText: 'Advance',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Enter advance' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _expensesController,
                    decoration: const InputDecoration(
                      labelText: 'Expenses',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Enter expenses' : null,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.note_add),
                      label: const Text('Note'),
                      onPressed: () {}, // Just a label, not a button
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Enter note',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _totalExpensesController,
                    decoration: const InputDecoration(
                      labelText: 'Total Expenses',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final punji = double.tryParse(_punjiController.text) ?? 0;
                  final advance = double.tryParse(_advanceController.text) ?? 0;
                  final expenses = double.tryParse(_expensesController.text) ?? 0;
                  final totalExpenses = punji + expenses - advance;
                  final db = DatabaseHelper();
                  await db.insertDriverEntry({
                    'driver_id': driver.id,
                    'date': _dateController.text,
                    'punji': punji,
                    'advance': advance,
                    'expenses': expenses,
                    'total_expenses': totalExpenses,
                    'note': _noteController.text.trim(),
                  });
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Entry added')),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<List<DriverEntry>> _getDriverEntries(int driverId) async {
    final db = DatabaseHelper();
    final entryMaps = await db.getDriverEntries(driverId);
    return entryMaps.map((e) => DriverEntry.fromMap(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Khata'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _truckNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Truck Number',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) => value == null || value.isEmpty ? 'Enter truck number' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _driverNameController,
                      decoration: const InputDecoration(
                        labelText: 'Driver Name',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _addDriver(),
                      validator: (value) => value == null || value.isEmpty ? 'Enter driver name' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addDriver,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Driver List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DriverAdvancePaymentScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text('Driver Advance Payment', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _drivers.isEmpty
                      ? const Center(child: Text('No drivers added.'))
                      : ListView.builder(
                          itemCount: _drivers.length,
                          itemBuilder: (context, index) {
                            final driver = _drivers[index];
                            return Card(
                              child: ExpansionTile(
                                title: Text(driver.driverName),
                                subtitle: Text('Truck: ${driver.truckNumber}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add, color: Colors.green),
                                      onPressed: () => _showDriverSectionDialog(driver),
                                      tooltip: 'Add Entry',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeDriver(driver.id!),
                                      tooltip: 'Remove Driver',
                                    ),
                                  ],
                                ),
                                children: [
                                  FutureBuilder<List<DriverEntry>>(
                                    future: _getDriverEntries(driver.id!),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Center(child: CircularProgressIndicator()),
                                        );
                                      }
                                      final entries = snapshot.data!;
                                      if (entries.isEmpty) {
                                        return const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text('No entries.'),
                                        );
                                      }
                                      return Column(
                                        children: entries.map((entry) => ListTile(
                                          title: Text('Date: ${entry.date}'),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Punji: ${entry.punji}'),
                                              Text('Advance: ${entry.advance}'),
                                              Text('Expenses: ${entry.expenses}'),
                                              Text('Total Expenses: ${entry.totalExpenses}'),
                                              if (entry.note != null && entry.note!.isNotEmpty)
                                                Text('Note: ${entry.note}'),
                                            ],
                                          ),
                                        )).toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_service.dart';
import '../models/bill.dart';

class NewBillScreen extends StatefulWidget {
  const NewBillScreen({super.key});

  @override
  State<NewBillScreen> createState() => _NewBillScreenState();
}

class _NewBillScreenState extends State<NewBillScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedVehicle;
  List<String> _vehicles = [];
  final TextEditingController _loadWeightController = TextEditingController();
  final TextEditingController _unloadWeightController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _shortWeightController = TextEditingController();
  final TextEditingController _shortRateController = TextEditingController();
  final TextEditingController _shortAmountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _expensesController = TextEditingController();
  final TextEditingController _roundOffController = TextEditingController();
  final TextEditingController _netBalanceController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
      print('Error loading vehicles: $e');
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
    _loadWeightController.dispose();
    _unloadWeightController.dispose();
    _rateController.dispose();
    _shortWeightController.dispose();
    _shortRateController.dispose();
    _shortAmountController.dispose();
    _amountController.dispose();
    _advanceController.dispose();
    _expensesController.dispose();
    _roundOffController.dispose();
    _netBalanceController.dispose();
    super.dispose();
  }

  void _calculateFields() {
    double loadWeightTon = double.tryParse(_loadWeightController.text) ?? 0;
    double unloadWeightTon = double.tryParse(_unloadWeightController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double shortRate = double.tryParse(_shortRateController.text) ?? 0;
    double advance = double.tryParse(_advanceController.text) ?? 0;
    double expenses = double.tryParse(_expensesController.text) ?? 0;
    double roundOff = double.tryParse(_roundOffController.text) ?? 0;

    double shortWeight = (loadWeightTon - unloadWeightTon) * 1000;
    double shortAmount = shortWeight * shortRate;
    double amount = unloadWeightTon * rate;
    double netBalance = amount - shortAmount - advance - expenses - roundOff;

    _shortWeightController.text = shortWeight.toStringAsFixed(2);
    _shortAmountController.text = shortAmount.toStringAsFixed(2);
    _amountController.text = amount.toStringAsFixed(2);
    _netBalanceController.text = netBalance.toStringAsFixed(2);
  }

  void _clearFields() {
    _dateController.clear();
    _selectedVehicle = null;
    _loadWeightController.clear();
    _unloadWeightController.clear();
    _rateController.clear();
    _shortWeightController.clear();
    _shortRateController.clear();
    _shortAmountController.clear();
    _amountController.clear();
    _advanceController.clear();
    _expensesController.clear();
    _roundOffController.clear();
    _netBalanceController.clear();
    setState(() {});
  }

  Future<void> _submitBill() async {
    if (_formKey.currentState!.validate()) {
      try {
        final bill = Bill(
          date: _dateController.text,
          vehicleNumber: _selectedVehicle!,
          loadWeight: double.parse(_loadWeightController.text),
          unloadWeight: double.parse(_unloadWeightController.text),
          shortWeight: double.parse(_shortWeightController.text),
          rate: double.parse(_rateController.text),
          shortRate: double.parse(_shortRateController.text),
          shortAmount: double.parse(_shortAmountController.text),
          amount: double.parse(_amountController.text),
          advance: double.parse(_advanceController.text),
          expenses: double.parse(_expensesController.text),
          roundOff: double.tryParse(_roundOffController.text) ?? 0.0,
          netBalance: double.parse(_netBalanceController.text),
          createdAt: DateTime.now().toIso8601String(),
        );

        // Validate bill before saving
        if (!_databaseService.validateBill(bill)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please check your input data')),
            );
          }
          return;
        }

        bool success = await _databaseService.addBill(bill);
        
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bill saved successfully!')),
            );
            _clearFields();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error saving bill')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving bill: $e')),
          );
        }
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
          'New Bill',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Date', mandatory: true),
              _buildDateField(context, 'Select Date', Icons.calendar_today),
              const SizedBox(height: 20),
              _buildLabel('Vehicle No.', mandatory: true),
              _buildDropdownField('Select Vehicle'),
              const SizedBox(height: 20),
              _buildLabel('Load Weight (Ton)', mandatory: true),
              _buildNumberField(_loadWeightController, 'Enter Load Weight', onChanged: (_) => setState(_calculateFields)),
              const SizedBox(height: 20),
              _buildLabel('Unload Weight (Ton)', mandatory: true),
              _buildNumberField(_unloadWeightController, 'Enter Unload Weight', onChanged: (_) => setState(_calculateFields)),
              const SizedBox(height: 20),
              _buildLabel('Short Weight (KG)'),
              _buildReadOnlyField(_shortWeightController, 'Auto'),
              const SizedBox(height: 20),
              _buildLabel('Rate (₹)', mandatory: true),
              _buildNumberField(_rateController, 'Enter Rate', onChanged: (_) => setState(_calculateFields)),
              const SizedBox(height: 20),
              _buildLabel('Short Rate (₹)', mandatory: true),
              _buildNumberField(_shortRateController, 'Enter Short Rate', onChanged: (_) => setState(_calculateFields)),
              const SizedBox(height: 20),
              _buildLabel('Short Amount (₹)'),
              _buildReadOnlyField(_shortAmountController, 'Auto'),
              const SizedBox(height: 20),
              _buildLabel('Amount (₹)'),
              _buildReadOnlyField(_amountController, 'Auto'),
              const SizedBox(height: 20),
              _buildLabel('Advance (₹)', mandatory: true),
              _buildNumberField(_advanceController, 'Enter Advance', onChanged: (_) => setState(_calculateFields)),
              const SizedBox(height: 20),
              _buildLabel('Expenses (₹)', mandatory: true),
              _buildNumberField(_expensesController, 'Enter Expenses', onChanged: (_) => setState(_calculateFields)),
              const SizedBox(height: 20),
              _buildLabel('Round Off (₹)'),
              _buildNumberField(_roundOffController, 'Enter Round Off', onChanged: (_) => setState(_calculateFields)),
              const SizedBox(height: 20),
              _buildLabel('Net Balance (₹)'),
              _buildReadOnlyField(_netBalanceController, 'Auto'),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitBill,
                  child: const Text('Submit'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool mandatory = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          if (mandatory)
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String hintText, {void Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
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
      validator: (value) {
        if (hintText.contains('Enter') && (value == null || value.isEmpty)) {
          return 'Required';
        }
        if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      enabled: false,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[50],
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
        child: TextFormField(
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a vehicle';
        }
        return null;
      },
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../database/database_service.dart';
import '../models/bill.dart';
import '../services/bill_generator.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Bill> _allBills = [];
  double _totalAmount = 0.0;
  double _totalNetBalance = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllBills();
  }

  Future<void> _loadAllBills() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bills = await _databaseService.getAllBills();
      double totalAmount = 0.0;
      double totalNetBalance = 0.0;

      for (var bill in bills) {
        totalAmount += bill.amount;
        totalNetBalance += bill.netBalance;
      }

      setState(() {
        _allBills = bills;
        _totalAmount = totalAmount;
        _totalNetBalance = totalNetBalance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bills: $e')),
        );
      }
    }
  }

  Future<void> _viewBills() async {
    if (_isLoading) return;

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            child: Container(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue[50]!,
                    Colors.white,
                    Colors.blue[50]!,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'All Bills',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Total: ${_allBills.length} bills',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _loadAllBills();
                              _viewBills();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content - Bills List
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: _allBills.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No bills found',
                                    style: TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Create your first bill to see it here',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _allBills.length,
                              itemBuilder: (context, index) {
                                final bill = _allBills[index];
                                return _buildBillCard(bill, index);
                              },
                            ),
                    ),
                  ),
                  
                  // Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ${_allBills.length} bills',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(Bill bill, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        title: Text(
          bill.vehicleNumber,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blue,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildInfoChip('Date', bill.date),
              _buildInfoChip('Load', '${bill.loadWeight}T'),
              _buildInfoChip('Unload', '${bill.unloadWeight}T'),
              _buildInfoChip('Amount', '₹${bill.amount}'),
              _buildInfoChip('Net Balance', '₹${bill.netBalance.toStringAsFixed(0)}'),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                onPressed: () => _deleteBill(bill.id!),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow('Bill ID', '${bill.id}'),
                _buildDetailRow('Load Weight', '${bill.loadWeight} Ton'),
                _buildDetailRow('Unload Weight', '${bill.unloadWeight} Ton'),
                _buildDetailRow('Short Weight', '${bill.shortWeight} KG'),
                _buildDetailRow('Rate', '₹${bill.rate}'),
                _buildDetailRow('Short Rate', '₹${bill.shortRate}'),
                _buildDetailRow('Amount', '₹${bill.amount}'),
                _buildDetailRow('Short Amount', '₹${bill.shortAmount}'),
                _buildDetailRow('Advance', '₹${bill.advance}'),
                _buildDetailRow('Expenses', '₹${bill.expenses}'),
                const Divider(),
                _buildDetailRow('Net Balance', '₹${bill.netBalance}', isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 9,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue[700] : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue[700] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _viewVehicles() async {
    try {
      final vehicles = await _databaseService.getAllVehicles();
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.directions_car, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Vehicles List'),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: vehicles.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No vehicles found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add vehicles to see them here',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = vehicles[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              title: Text(
                                vehicle.vehicleNumber,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Added: ${vehicle.createdAt.split('T')[0]}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vehicles: $e')),
        );
      }
    }
  }

  Future<void> _downloadGeneratedBill() async {
    // Show date picker to select date for bill generation
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final dateString = '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
      
      try {
        final bills = await _databaseService.getBillsByDate(dateString);
        
        if (mounted) {
          if (bills.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No bills found for date: $dateString')),
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  child: Container(
                    width: double.maxFinite,
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue[50]!,
                          Colors.white,
                          Colors.blue[50]!,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Vehicle Numbers',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Date: $dateString',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${bills.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Content
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: ListView.builder(
                              itemCount: bills.length,
                              itemBuilder: (context, index) {
                                final bill = bills[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        // Number badge
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue[400]!,
                                                Colors.blue[600]!,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.withValues(alpha: 0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        
                                        const SizedBox(width: 12),
                                        
                                        // Vehicle number
                                        Expanded(
                                          child: Text(
                                            bill.vehicleNumber,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                        
                                        // Action buttons
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green[50],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.download, color: Colors.green, size: 20),
                                                onPressed: () => _downloadBill(bill),
                                                padding: const EdgeInsets.all(8),
                                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.orange[50],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.share, color: Colors.orange, size: 20),
                                                onPressed: () => _shareBill(bill),
                                                padding: const EdgeInsets.all(8),
                                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        
                        // Footer
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: ${bills.length} vehicles',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text(
                                  'Close',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading bills: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteBill(int id) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Bill'),
          content: const Text('Are you sure you want to delete this bill? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        bool success = await _databaseService.deleteBill(id);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bill deleted successfully')),
            );
            Navigator.of(context).pop();
            _loadAllBills(); // Refresh the list
            _viewBills(); // Refresh the dialog
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error deleting bill')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting bill: $e')),
          );
        }
      }
    }
  }

  Future<void> _downloadBill(Bill bill) async {
    try {
      final file = await BillGenerator.generateBillPDF(bill);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bill downloaded successfully: ${file.path}'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () async {
                try {
                  await OpenFile.open(file.path);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error opening file: $e')),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading bill: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareBill(Bill bill) async {
    try {
      final file = await BillGenerator.generateBillPDF(bill);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Bill for ${bill.vehicleNumber} - ${bill.date}',
        subject: 'Sharma Enterprises Bill',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing bill: $e'),
            backgroundColor: Colors.red,
          ),
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
          'Record',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Summary Cards
            if (_allBills.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Bill Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Bills',
                            _allBills.length.toString(),
                            Icons.receipt_long,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Amount',
                            '₹${_totalAmount.toStringAsFixed(2)}',
                            Icons.account_balance_wallet,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSummaryCard(
                            'Net Balance',
                            '₹${_totalNetBalance.toStringAsFixed(2)}',
                            Icons.account_balance,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Action Buttons
            _buildRecordItem(
              'View All Bills',
              Icons.receipt_long,
              () => _viewBills(),
              subtitle: _allBills.isNotEmpty 
                  ? '${_allBills.length} bills • Total: ₹${_totalAmount.toStringAsFixed(2)}'
                  : 'No bills created yet',
            ),
            _buildRecordItem(
              'Vehicles List',
              Icons.directions_car,
              () => _viewVehicles(),
            ),
            _buildRecordItem(
              'Download Bills by Date',
              Icons.calendar_today,
              () => _downloadGeneratedBill(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(String title, IconData icon, VoidCallback onTap, {String? subtitle}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
} 
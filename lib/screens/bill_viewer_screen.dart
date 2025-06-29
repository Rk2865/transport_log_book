import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../models/bill.dart';
import '../services/bill_generator.dart';

class BillViewerScreen extends StatefulWidget {
  final Bill bill;

  const BillViewerScreen({super.key, required this.bill});

  @override
  State<BillViewerScreen> createState() => _BillViewerScreenState();
}

class _BillViewerScreenState extends State<BillViewerScreen> {
  bool _isGenerating = false;
  File? _generatedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Bill Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_generatedFile != null) ...[
            IconButton(
              icon: const Icon(Icons.share, color: Colors.blue),
              onPressed: _shareBill,
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new, color: Colors.green),
              onPressed: _openBill,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bill Preview Card
            _buildBillPreview(),
            const SizedBox(height: 20),
            
            // Action Buttons
            _buildActionButtons(),
            const SizedBox(height: 20),
            
            // Bill Details
            _buildBillDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildBillPreview() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Image.asset('assets/logo.png'),
                  const SizedBox(height: 4),
                  Text(
                    'MINIMAL SAFE BOX WORK',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Bill Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bill No: ${widget.bill.id ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Date: ${widget.bill.date}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text(
              'Vehicle: ${widget.bill.vehicleNumber}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Net Balance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NET BALANCE:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rs.${widget.bill.netBalance}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateAndDownloadBill,
            icon: _isGenerating 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(_isGenerating ? 'Generating...' : 'Download PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (_generatedFile != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _shareBill,
              icon: const Icon(Icons.share),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBillDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bill Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildDetailRow('Load Weight', '${widget.bill.loadWeight} Ton'),
            _buildDetailRow('Unload Weight', '${widget.bill.unloadWeight} Ton'),
            _buildDetailRow('Short Weight', '${widget.bill.shortWeight} KG'),
            _buildDetailRow('Rate', 'Rs.${widget.bill.rate}'),
            _buildDetailRow('Short Rate', 'Rs.${widget.bill.shortRate}'),
            _buildDetailRow('Amount', 'Rs.${widget.bill.amount}'),
            _buildDetailRow('Short Amount', 'Rs.${widget.bill.shortAmount}'),
            _buildDetailRow('Advance', 'Rs.${widget.bill.advance}'),
            _buildDetailRow('Expenses', 'Rs.${widget.bill.expenses}'),
            _buildDetailRow('Round Off', 'Rs.${widget.bill.roundOff}'),
            const Divider(),
            _buildDetailRow('Net Balance', 'Rs.${widget.bill.netBalance}', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndDownloadBill() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final file = await BillGenerator.generateBillPDF(widget.bill);
      setState(() {
        _generatedFile = file;
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bill generated successfully: ${file.path}'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: _openBill,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

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

  Future<void> _shareBill() async {
    if (_generatedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please generate the bill first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await Share.shareXFiles(
        [XFile(_generatedFile!.path)],
        text: 'Bill for ${widget.bill.vehicleNumber} - ${widget.bill.date}',
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

  Future<void> _openBill() async {
    if (_generatedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please generate the bill first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final result = await OpenFile.open(_generatedFile!.path);
      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening file: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 
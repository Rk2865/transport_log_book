import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/bill.dart';

class BillGenerator {
  static const double _width = 4.0 * 72.0; // 4 inches in points
  static const double _height = 6.0 * 72.0; // 6 inches in points

  static Future<File> generateBillPDF(Bill bill) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(_width, _height),
        build: (pw.Context context) {
          return pw.Container(
            width: _width,
            height: _height,
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with Sharma Enterprises
                _buildHeader(),
                pw.SizedBox(height: 8),
                
                // Bill Details
                _buildBillDetails(bill),
                pw.SizedBox(height: 8),
                
                // Vehicle and Date Info
                _buildVehicleAndDate(bill),
                pw.SizedBox(height: 8),
                
                // Weight Details
                _buildWeightDetails(bill),
                pw.SizedBox(height: 8),
                
                // Rate Details
                _buildRateDetails(bill),
                pw.SizedBox(height: 8),
                
                // Amount Details
                _buildAmountDetails(bill),
                pw.SizedBox(height: 8),
                
                // Net Balance
                _buildNetBalance(bill),
                pw.SizedBox(height: 8),
                
                // Footer
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );

    // Get the documents directory
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'bill_${bill.vehicleNumber}_${bill.date.replaceAll('/', '_')}.pdf';
    final file = File('${directory.path}/$fileName');
    
    // Save the PDF
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        children: [
          pw.Text(
            'SHARMA ENTERPRISES',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '88, Garden Reach Road, Khidirpur, Kolkata - 700023',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.normal,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            'Contact No.: 9831074426',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.normal,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            'Pro.: Ajay Kumar Sharma',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 2),
          pw.Container(
            height: 1,
            color: PdfColors.black,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBillDetails(Bill bill) {
    // Generate bill number in format yyyy-01, yyyy-02, etc.
    String generateBillNumber(int billId) {
      final year = DateTime.now().year;
      return '$year-${billId.toString().padLeft(2, '0')}';
    }
    
    return pw.Container(
      width: double.infinity,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'BILL NO: ${generateBillNumber(bill.id ?? 1)}',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'Date: ${bill.date}',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildVehicleAndDate(Bill bill) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Vehicle No: ${bill.vehicleNumber}',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildWeightDetails(Bill bill) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Load Weight:',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '${bill.loadWeight} Ton',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Unload Weight:',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '${bill.unloadWeight} Ton',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Short Weight:',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '${bill.shortWeight} KG',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildRateDetails(Bill bill) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Rate:',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Rs. ${bill.rate}',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Short Rate:',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Rs. ${bill.shortRate}',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAmountDetails(Bill bill) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        children: [
          _buildAmountRow('Amount:', bill.amount),
          _buildAmountRow('Advance:', bill.advance),
          _buildAmountRow('Expenses:', bill.expenses),
          _buildAmountRow('Round Off:', bill.roundOff),
        ],
      ),
    );
  }

  static pw.Widget _buildAmountRow(String label, double amount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 9),
        ),
        pw.Text(
          'Rs. $amount',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildNetBalance(Bill bill) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'NET BALANCE:',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'Rs. ${bill.netBalance}',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        children: [
          pw.SizedBox(height: 4),
          pw.Text(
            'Thank You for Your Business',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.normal,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Sharma Enterprises',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Future<String> getBillFileName(Bill bill) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'bill_${bill.vehicleNumber}_${bill.date.replaceAll('/', '_')}.pdf';
    return '${directory.path}/$fileName';
  }
} 
class AdvancePayment {
  final int? id;
  final String date;
  final String vehicleNumber;
  final double amount;
  final String createdAt;

  AdvancePayment({
    this.id,
    required this.date,
    required this.vehicleNumber,
    required this.amount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'vehicle_number': vehicleNumber,
      'amount': amount,
      'created_at': createdAt,
    };
  }

  factory AdvancePayment.fromMap(Map<String, dynamic> map) {
    return AdvancePayment(
      id: map['id'],
      date: map['date'],
      vehicleNumber: map['vehicle_number'],
      amount: map['amount'].toDouble(),
      createdAt: map['created_at'],
    );
  }
} 
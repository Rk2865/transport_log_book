class Driver {
  final int? id;
  final String truckNumber;
  final String driverName;

  Driver({this.id, required this.truckNumber, required this.driverName});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'truck_number': truckNumber,
      'driver_name': driverName,
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] as int?,
      truckNumber: map['truck_number'] as String,
      driverName: map['driver_name'] as String,
    );
  }
}

class DriverEntry {
  final int? id;
  final int driverId;
  final String date;
  final double punji;
  final double advance;
  final double expenses;
  final double totalExpenses;
  final String? note;

  DriverEntry({
    this.id,
    required this.driverId,
    required this.date,
    required this.punji,
    required this.advance,
    required this.expenses,
    required this.totalExpenses,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driver_id': driverId,
      'date': date,
      'punji': punji,
      'advance': advance,
      'expenses': expenses,
      'total_expenses': totalExpenses,
      'note': note,
    };
  }

  factory DriverEntry.fromMap(Map<String, dynamic> map) {
    return DriverEntry(
      id: map['id'] as int?,
      driverId: map['driver_id'] as int,
      date: map['date'] as String,
      punji: (map['punji'] as num).toDouble(),
      advance: (map['advance'] as num).toDouble(),
      expenses: (map['expenses'] as num).toDouble(),
      totalExpenses: (map['total_expenses'] as num).toDouble(),
      note: map['note'] as String?,
    );
  }
}

class DriverAdvancePayment {
  final int? id;
  final int driverId;
  final String date;
  final double amount;
  final String createdAt;

  DriverAdvancePayment({
    this.id,
    required this.driverId,
    required this.date,
    required this.amount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driver_id': driverId,
      'date': date,
      'amount': amount,
      'created_at': createdAt,
    };
  }

  factory DriverAdvancePayment.fromMap(Map<String, dynamic> map) {
    return DriverAdvancePayment(
      id: map['id'] as int?,
      driverId: map['driver_id'] as int,
      date: map['date'] as String,
      amount: (map['amount'] as num).toDouble(),
      createdAt: map['created_at'] as String,
    );
  }
} 
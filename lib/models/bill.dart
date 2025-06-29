class Bill {
  final int? id;
  final String date;
  final String vehicleNumber;
  final double loadWeight;
  final double unloadWeight;
  final double shortWeight;
  final double rate;
  final double shortRate;
  final double shortAmount;
  final double amount;
  final double advance;
  final double expenses;
  final double roundOff;
  final double netBalance;
  final String createdAt;

  Bill({
    this.id,
    required this.date,
    required this.vehicleNumber,
    required this.loadWeight,
    required this.unloadWeight,
    required this.shortWeight,
    required this.rate,
    required this.shortRate,
    required this.shortAmount,
    required this.amount,
    required this.advance,
    required this.expenses,
    required this.roundOff,
    required this.netBalance,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'vehicle_number': vehicleNumber,
      'load_weight': loadWeight,
      'unload_weight': unloadWeight,
      'short_weight': shortWeight,
      'rate': rate,
      'short_rate': shortRate,
      'short_amount': shortAmount,
      'amount': amount,
      'advance': advance,
      'expenses': expenses,
      'round_off': roundOff,
      'net_balance': netBalance,
      'created_at': createdAt,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      date: map['date'],
      vehicleNumber: map['vehicle_number'],
      loadWeight: map['load_weight'].toDouble(),
      unloadWeight: map['unload_weight'].toDouble(),
      shortWeight: map['short_weight'].toDouble(),
      rate: map['rate'].toDouble(),
      shortRate: map['short_rate'].toDouble(),
      shortAmount: map['short_amount'].toDouble(),
      amount: map['amount'].toDouble(),
      advance: map['advance'].toDouble(),
      expenses: map['expenses'].toDouble(),
      roundOff: map['round_off'] != null ? map['round_off'].toDouble() : 0.0,
      netBalance: map['net_balance'].toDouble(),
      createdAt: map['created_at'],
    );
  }
} 
class Vehicle {
  final int? id;
  final String vehicleNumber;
  final String createdAt;

  Vehicle({
    this.id,
    required this.vehicleNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_number': vehicleNumber,
      'created_at': createdAt,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      vehicleNumber: map['vehicle_number'],
      createdAt: map['created_at'],
    );
  }
} 
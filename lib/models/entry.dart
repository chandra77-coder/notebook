class Entry {
  final String id;
  final String serviceType;
  final String customerName;
  final double amount;
  final String note;
  final String paymentType; // Cash, Online, Due
  final String personId;
  final DateTime date;
  final String dayName;
  final bool isDeleted;

  Entry({
    required this.id,
    required this.serviceType,
    required this.customerName,
    required this.amount,
    required this.note,
    required this.paymentType,
    required this.personId,
    required this.date,
    required this.dayName,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceType': serviceType,
      'customerName': customerName,
      'amount': amount,
      'note': note,
      'paymentType': paymentType,
      'personId': personId,
      'date': date.toIso8601String(),
      'dayName': dayName,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'] as String,
      serviceType: map['serviceType'] as String,
      customerName: map['customerName'] as String,
      amount: map['amount'] as double,
      note: map['note'] as String,
      paymentType: map['paymentType'] as String,
      personId: map['personId'] as String,
      date: DateTime.parse(map['date'] as String),
      dayName: map['dayName'] as String,
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }

  Entry copyWith({
    String? id,
    String? serviceType,
    String? customerName,
    double? amount,
    String? note,
    String? paymentType,
    String? personId,
    DateTime? date,
    String? dayName,
    bool? isDeleted,
  }) {
    return Entry(
      id: id ?? this.id,
      serviceType: serviceType ?? this.serviceType,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      paymentType: paymentType ?? this.paymentType,
      personId: personId ?? this.personId,
      date: date ?? this.date,
      dayName: dayName ?? this.dayName,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

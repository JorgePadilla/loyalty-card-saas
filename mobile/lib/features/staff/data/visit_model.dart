class VisitModel {
  final int id;
  final String serviceName;
  final int amountCents;
  final int pointsEarned;
  final DateTime checkedInAt;
  final String? userName;
  final String? staffName;

  const VisitModel({
    required this.id,
    required this.serviceName,
    required this.amountCents,
    required this.pointsEarned,
    required this.checkedInAt,
    this.userName,
    this.staffName,
  });

  /// Formats cents into a dollar string, e.g. 2500 -> "$25.00".
  String get formattedAmount {
    final dollars = amountCents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id'] as int,
      serviceName: json['service_name'] as String,
      amountCents: json['amount_cents'] as int,
      pointsEarned: json['points_earned'] as int,
      checkedInAt: DateTime.parse(json['checked_in_at'] as String),
      userName: json['user_name'] as String?,
      staffName: json['staff_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': serviceName,
      'amount_cents': amountCents,
      'points_earned': pointsEarned,
      'checked_in_at': checkedInAt.toIso8601String(),
      'user_name': userName,
      'staff_name': staffName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisitModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'VisitModel(id: $id, service: $serviceName, amount: $formattedAmount, '
      'points: $pointsEarned)';
}

class PointTransactionModel {
  final int id;
  final String kind;
  final int points;
  final String description;
  final DateTime createdAt;

  const PointTransactionModel({
    required this.id,
    required this.kind,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  /// Positive transactions add points to the balance.
  bool get isPositive => kind == 'earned' || kind == 'bonus';

  /// Display-friendly label for the transaction kind.
  String get kindLabel {
    switch (kind) {
      case 'earned':
        return 'Earned';
      case 'redeemed':
        return 'Redeemed';
      case 'bonus':
        return 'Bonus';
      case 'adjusted':
        return 'Adjustment';
      case 'expired':
        return 'Expired';
      default:
        return kind[0].toUpperCase() + kind.substring(1);
    }
  }

  /// Signed display string, e.g. "+150" or "-500".
  String get pointsDisplay => isPositive ? '+$points' : '-$points';

  factory PointTransactionModel.fromJson(Map<String, dynamic> json) {
    return PointTransactionModel(
      id: json['id'] as int,
      kind: json['kind'] as String,
      points: json['points'] as int,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointTransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PointTransactionModel(id: $id, kind: $kind, points: $points)';
}

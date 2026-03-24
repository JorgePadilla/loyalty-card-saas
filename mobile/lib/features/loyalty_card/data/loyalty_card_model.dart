import 'package:flutter/material.dart';

class LoyaltyCardModel {
  final int id;
  final String qrCode;
  final String tier;
  final int currentPoints;
  final int totalPoints;
  final int visitsCount;
  final DateTime? lastVisitAt;

  const LoyaltyCardModel({
    required this.id,
    required this.qrCode,
    required this.tier,
    required this.currentPoints,
    required this.totalPoints,
    required this.visitsCount,
    this.lastVisitAt,
  });

  /// Map tier names to their display colors.
  Color get tierColor {
    switch (tier) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFC9A84C);
      case 'platinum':
        return const Color(0xFFE5E4E1);
      default:
        return const Color(0xFFC0C0C0);
    }
  }

  /// Human-readable tier label with first letter capitalized.
  String get tierLabel => tier[0].toUpperCase() + tier.substring(1);

  factory LoyaltyCardModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyCardModel(
      id: json['id'] as int,
      qrCode: json['qr_code'] as String,
      tier: json['tier'] as String,
      currentPoints: json['current_points'] as int,
      totalPoints: json['total_points'] as int,
      visitsCount: json['visits_count'] as int,
      lastVisitAt: json['last_visit_at'] != null
          ? DateTime.parse(json['last_visit_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qr_code': qrCode,
      'tier': tier,
      'current_points': currentPoints,
      'total_points': totalPoints,
      'visits_count': visitsCount,
      'last_visit_at': lastVisitAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoyaltyCardModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          qrCode == other.qrCode &&
          tier == other.tier &&
          currentPoints == other.currentPoints &&
          totalPoints == other.totalPoints &&
          visitsCount == other.visitsCount &&
          lastVisitAt == other.lastVisitAt;

  @override
  int get hashCode => Object.hash(
        id,
        qrCode,
        tier,
        currentPoints,
        totalPoints,
        visitsCount,
        lastVisitAt,
      );

  @override
  String toString() =>
      'LoyaltyCardModel(id: $id, tier: $tier, points: $currentPoints/$totalPoints)';
}

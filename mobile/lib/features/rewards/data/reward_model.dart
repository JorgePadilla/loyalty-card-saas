class RewardModel {
  final int id;
  final String name;
  final String description;
  final int pointsCost;
  final String rewardType;
  final String? tierRequired;
  final bool active;

  const RewardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.rewardType,
    this.tierRequired,
    required this.active,
  });

  /// Whether a tier gate exists for this reward.
  bool get hasTierRequirement => tierRequired != null && tierRequired!.isNotEmpty;

  /// Human-readable tier requirement label.
  String get tierRequiredLabel {
    if (tierRequired == null) return '';
    return tierRequired![0].toUpperCase() + tierRequired!.substring(1);
  }

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      pointsCost: json['points_cost'] as int,
      rewardType: json['reward_type'] as String,
      tierRequired: json['tier_required'] as String?,
      active: json['active'] as bool,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RewardModel(id: $id, name: $name, cost: $pointsCost)';
}

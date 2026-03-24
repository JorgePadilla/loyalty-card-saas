class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String? lastName;
  final String role;
  final int tenantId;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    this.lastName,
    required this.role,
    required this.tenantId,
  });

  /// Full display name — combines first and last name.
  String get fullName {
    if (lastName != null && lastName!.isNotEmpty) {
      return '$firstName $lastName';
    }
    return firstName;
  }

  /// True when the user's role is "customer".
  bool get isCustomer => role == 'customer';

  /// True when the user's role is "staff", "manager", or "owner".
  bool get isStaff => role == 'staff' || role == 'manager' || role == 'owner';

  /// Create a [UserModel] from a JSON map returned by the API.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String?,
      role: json['role'] as String,
      tenantId: json['tenant_id'] as int,
    );
  }

  /// Serialize this model back to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'tenant_id': tenantId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          role == other.role &&
          tenantId == other.tenantId;

  @override
  int get hashCode => Object.hash(id, email, firstName, lastName, role, tenantId);

  @override
  String toString() => 'UserModel(id: $id, email: $email, name: $fullName, role: $role)';
}

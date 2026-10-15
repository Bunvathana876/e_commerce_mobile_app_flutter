class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  // Parse user from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: json['email'] as String? ?? '',
      fullName: (json['full_name'] ?? json['name'] ?? '') as String,
      role: json['role'] as String? ?? 'customer',
      avatarUrl: (json['avatar_url'] ?? json['avatar']) as String?,
    );
  }

  // Convert user to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'avatar_url': avatarUrl,
    };
  }
}

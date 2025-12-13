class UserModel {
  final int userId;
  final String fullName;
  final String email;
  final String role;
  final String createdAt;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json["user_id"],
      fullName: json["full_name"] ?? "",
      email: json["email"] ?? "",
      role: json["role"] ?? "",
      createdAt: json["created_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "full_name": fullName,
      "email": email,
      "role": role,
      "created_at": createdAt,
    };
  }
}

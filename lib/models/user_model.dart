class User {
  final int id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String firstName;
  final String lastName;
  final bool isAdmin; // Only declare this ONCE
  final bool isGuest;
  final String? profilePicture;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.isAdmin,
    required this.isGuest,
    this.profilePicture,
    required this.createdAt,
  });

  // lib/models/user_model.dart

// lib/models/user_model.dart

factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] ?? 0,
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    phoneNumber: json['phone_number']?.toString(), // Safely convert to String
    firstName: json['first_name'] ?? '',
    lastName: json['last_name'] ?? '',
    // Use the logic for @mkobasmart.com admins
    isAdmin: (json['is_admin'] == true) || 
             (json['email'] ?? '').toString().toLowerCase().endsWith('@mkobasmart.com'),
    isGuest: json['is_guest'] ?? false,
    profilePicture: json['profile_picture'],
    createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'is_admin': isAdmin,
      'is_guest': isGuest,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName'.trim().isEmpty 
      ? username 
      : '$firstName $lastName'.trim();
}
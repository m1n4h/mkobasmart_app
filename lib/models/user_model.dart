class User {
  final int id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String firstName;
  final String lastName;
  final bool isAdmin;
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isAdmin: json['is_admin'] ?? false,
      isGuest: json['is_guest'] ?? false,
      profilePicture: json['profile_picture'],
      createdAt: DateTime.parse(json['created_at']),
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

  String get fullName => '$firstName $lastName'.trim();
}

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

  factory User.fromJson(Map<String, dynamic> json) {
    // 1. Extract email first so we can use it for the domain logic
    final emailStr = json['email'] ?? '';
    
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: emailStr,
      phoneNumber: json['phone_number'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      // 2. Logic: User is Admin if the DB says so OR the email domain is @mkobasmart.com
      isAdmin: (json['is_admin'] == true) || emailStr.toLowerCase().endsWith('@mkobasmart.com'),
      isGuest: json['is_guest'] ?? false,
      profilePicture: json['profile_picture'],
      // 3. Added a safety check for the date parsing
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
class User {
  final String id;
  final String phone;
  final String email;

  User({
    required this.id,
    this.phone = '',
    this.email = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class User {
  final String id;
  final String phone;
  final String email;
  final String nickname;

  User({
    required this.id,
    this.phone = '',
    this.email = '',
    this.nickname = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
    );
  }
}

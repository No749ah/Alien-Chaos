class User {
  final int? id;
  final String name;
  final double cookies;

  User({this.id, required this.name, required this.cookies});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cookies': cookies,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      cookies: map['cookies'],
    );
  }
}

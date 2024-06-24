class User {
  final int? id;
  final String name;
  final int cookies;

  User({this.id, required this.name, required this.cookies});

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    cookies: json['cookies'],
  );

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'cookies': cookies,
    };
    if (id != null) {
      map['id'] = id as Object;
    }
    return map;
  }

  User copyWith({int? id, String? name, int? cookies}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      cookies: cookies ?? this.cookies,
    );
  }
}

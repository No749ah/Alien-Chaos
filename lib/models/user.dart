class User {
  final int? id;
  final String name;
  int aliens;

  User({this.id, required this.name, required this.aliens});

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    aliens: json['aliens'],
  );

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'aliens': aliens,
    };
    if (id != null) {
      map['id'] = id as Object;
    }
    return map;
  }

  User copyWith({int? id, String? name, int? aliens}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      aliens: aliens ?? this.aliens,
    );
  }
}

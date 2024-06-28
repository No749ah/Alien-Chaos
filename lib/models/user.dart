class User {
  final int? id;
  final String name;
  int aliens;
  double prestige;

  User({
    this.id,
    required this.name,
    required this.aliens,
    required this.prestige
  });

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    aliens: json['aliens'],
    prestige: json['prestige'],
  );

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'aliens': aliens,
      'prestige': prestige,
    };
    if (id != null) {
      map['id'] = id as Object;
    }
    return map;
  }

  User copyWith({int? id, String? name, int? aliens, double? prestige}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      aliens: aliens ?? this.aliens,
      prestige: prestige ?? this.prestige
    );
  }
}

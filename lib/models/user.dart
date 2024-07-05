class User {
  final int? id;
  String name;
  double aliens;
  DateTime spinDate;
  double prestige;

  User({
    this.id,
    required this.name,
    required this.aliens,
    required this.prestige,
    required this.spinDate,
  });

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    aliens: json['aliens'],
    prestige: json['prestige'],
    spinDate: DateTime.parse(json['spinDate']),
  );

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'aliens': aliens,
      'prestige': prestige,
      'spinDate': spinDate.toIso8601String()
    };
    if (id != null) {
      map['id'] = id as Object;
    }
    return map;
  }

  User copyWith({int? id, String? name, double? aliens, double? prestige, DateTime? spinDate}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      aliens: aliens ?? this.aliens,
      prestige: prestige ?? this.prestige,
      spinDate: spinDate ?? this.spinDate
    );
  }
}

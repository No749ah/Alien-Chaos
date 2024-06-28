class PowerUp {
  final int id;
  final String name;
  final String display_name;
  final String type;
  final int value;
  final double multiplier;
  final double baseCost;
  int purchaseCount;

  PowerUp({
    required this.id,
    required this.name,
    required this.display_name,
    required this.type,
    required this.value,
    required this.baseCost,
    required this.multiplier,
    this.purchaseCount = 0,
  });

  factory PowerUp.fromMap(Map<String, dynamic> json) => PowerUp(
    id: json['id'],
    name: json['name'],
    display_name: json['display_name'],
    type: json['type'],
    value: json['value'],
    multiplier: json['multiplier'],
    baseCost: json['cost'],
    purchaseCount: json['purchase_count'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'display_name': display_name,
      'type': type,
      'value': value,
      'cost': baseCost,
      'multiplier': multiplier,
      'purchase_count': purchaseCount,
    };
  }
}

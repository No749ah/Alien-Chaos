class PowerUp {
  final int id;
  final String name;
  final String display_name;
  final String type;
  final double baseCost;
  final double multiplier;
  final int purchasable;
  int purchaseCount;

  PowerUp({
    required this.id,
    required this.name,
    required this.display_name,
    required this.type,
    required this.baseCost,
    required this.multiplier,
    required this.purchasable,
    this.purchaseCount = 0,
  });

  factory PowerUp.fromMap(Map<String, dynamic> json) => PowerUp(
    id: json['id'],
    name: json['name'],
    display_name: json['display_name'],
    type: json['type'],
    baseCost: json['cost'],
    multiplier: json['multiplier'],
    purchasable: json['purchasable'],
    purchaseCount: json['purchase_count'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'display_name': display_name,
      'type': type,
      'cost': baseCost,
      'multiplier': multiplier,
      'purchasable': purchasable,
      'purchase_count': purchaseCount,
    };
  }
}

class PowerUp {
  final int id;
  final String name;
  final String type;
  final int value;
  final double baseCost;
  int purchaseCount;

  PowerUp({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.baseCost,
    this.purchaseCount = 0,
  });

  factory PowerUp.fromMap(Map<String, dynamic> json) => PowerUp(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    value: json['value'],
    baseCost: json['cost'],
    purchaseCount: json['purchase_count'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'value': value,
      'cost': baseCost,
      'purchase_count': purchaseCount,
    };
  }
}

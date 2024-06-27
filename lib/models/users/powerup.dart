class PowerUp {
  final String name;
  final String type; // 'click' or 'second'
  final int value;
  final int baseCost;
  int purchaseCount;
  final int id;

  PowerUp(this.name, this.type, this.value, this.baseCost, this.purchaseCount, this.id);
}
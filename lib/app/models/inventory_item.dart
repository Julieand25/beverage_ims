enum ItemCategory { bahan, pembungkusan, lain }

enum ItemUnit { g, ml, unit, kg, l }

class InventoryItem {
  final String id;
  String name;
  ItemCategory category;
  ItemUnit unit;
  double stock;
  double minStock;
  double costPerUnit;
  String emoji;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.stock,
    required this.minStock,
    required this.costPerUnit,
    this.emoji = '',
  });

  bool get isLowStock => stock <= minStock;
  bool get isNearlyOut => minStock > 0 && stock < minStock * 0.5;
  double get stockValue => stock * costPerUnit;
}

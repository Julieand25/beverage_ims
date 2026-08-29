import 'inventory_item.dart';

class RecipeIngredient {
  String inventoryItemId;
  double quantity;

  RecipeIngredient({
    required this.inventoryItemId,
    required this.quantity,
  });
}

class Recipe {
  final String id;
  String name;
  double sellingPrice;
  String emoji;
  List<RecipeIngredient> ingredients;

  Recipe({
    required this.id,
    required this.name,
    required this.sellingPrice,
    required this.ingredients,
    this.emoji = '☕',
  });

  double costPerServing(List<InventoryItem> inventory) {
    double total = 0;
    for (final ing in ingredients) {
      final item = inventory.firstWhere(
        (i) => i.id == ing.inventoryItemId,
        orElse: () => InventoryItem(
          id: '',
          name: '',
          category: ItemCategory.bahan,
          unit: ItemUnit.g,
          stock: 0,
          minStock: 0,
          costPerUnit: 0,
        ),
      );
      total += item.costPerUnit * ing.quantity;
    }
    return total;
  }

  double grossProfit(List<InventoryItem> inventory) =>
      sellingPrice - costPerServing(inventory);
}

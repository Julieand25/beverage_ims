import 'package:flutter/material.dart';
import 'models/inventory_item.dart';
import 'models/recipe.dart';

class RecipeProvider extends ChangeNotifier {
  final List<Recipe> _recipes = [
    Recipe(
      id: 'r1',
      name: 'Matcha Latte',
      sellingPrice: 8.00,
      ingredients: [
        RecipeIngredient(inventoryItemId: '1', quantity: 5),
        RecipeIngredient(inventoryItemId: '2', quantity: 150),
        RecipeIngredient(inventoryItemId: '3', quantity: 20),
        RecipeIngredient(inventoryItemId: '4', quantity: 1),
        RecipeIngredient(inventoryItemId: '6', quantity: 1),
      ],
    ),
    Recipe(
      id: 'r2',
      name: 'Milk Tea',
      sellingPrice: 6.00,
      ingredients: [
        RecipeIngredient(inventoryItemId: '2', quantity: 120),
        RecipeIngredient(inventoryItemId: '3', quantity: 25),
        RecipeIngredient(inventoryItemId: '4', quantity: 1),
        RecipeIngredient(inventoryItemId: '6', quantity: 1),
      ],
    ),
    Recipe(
      id: 'r3',
      name: 'Americano',
      sellingPrice: 5.00,
      ingredients: [
        RecipeIngredient(inventoryItemId: '4', quantity: 1),
        RecipeIngredient(inventoryItemId: '6', quantity: 1),
      ],
    ),
  ];

  String _searchQuery = '';

  String get searchQuery => _searchQuery;
  List<Recipe> get recipes => List.unmodifiable(_recipes);

  List<Recipe> filteredRecipes(List<InventoryItem> inventory) {
    var result = _recipes;
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((r) =>
              r.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return result;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addRecipe({
    required String name,
    required double sellingPrice,
    required List<RecipeIngredient> ingredients,
  }) {
    _recipes.add(Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      sellingPrice: sellingPrice,
      ingredients: ingredients,
    ));
    notifyListeners();
  }

  void updateRecipe({
    required String id,
    required String name,
    required double sellingPrice,
    required List<RecipeIngredient> ingredients,
  }) {
    final index = _recipes.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _recipes[index].name = name;
    _recipes[index].sellingPrice = sellingPrice;
    _recipes[index].ingredients = ingredients;
    notifyListeners();
  }

  void deleteRecipe(String id) {
    _recipes.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}

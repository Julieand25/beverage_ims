import 'package:flutter/material.dart';
import 'models/recipe.dart';
import 'repositories/recipe_repository.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _repo;
  List<Recipe> _recipes = [];
  String _searchQuery = '';
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<Recipe> get recipes => List.unmodifiable(_recipes);

  List<Recipe> filteredRecipes() {
    var result = _recipes;
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((r) =>
              r.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return result;
  }

  RecipeProvider({required RecipeRepository repo}) : _repo = repo {
    loadAll();
  }

  Future<void> loadAll() async {
    _recipes = await _repo.getAll();
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addRecipe({
    required String name,
    required double sellingPrice,
    required List<RecipeIngredient> ingredients,
    required String userId,
  }) async {
    final recipe = Recipe(
      id: '',
      name: name,
      sellingPrice: sellingPrice,
      ingredients: ingredients,
    );
    final created = await _repo.addRecipe(recipe, userId: userId);
    _recipes.add(created);
    notifyListeners();
  }

  Future<void> updateRecipe({
    required String id,
    required String name,
    required double sellingPrice,
    required List<RecipeIngredient> ingredients,
  }) async {
    final recipe = Recipe(
      id: id,
      name: name,
      sellingPrice: sellingPrice,
      ingredients: ingredients,
    );
    final updated = await _repo.updateRecipe(recipe);
    final index = _recipes.indexWhere((r) => r.id == id);
    if (index != -1) {
      _recipes[index] = updated;
    }
    notifyListeners();
  }

  Future<void> deleteRecipe(String id) async {
    await _repo.deleteRecipe(id);
    _recipes.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}

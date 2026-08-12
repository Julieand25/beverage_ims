import 'package:flutter/material.dart';
import 'models/audit_log.dart';
import 'models/recipe.dart';
import 'repositories/audit_repository.dart';
import 'repositories/recipe_repository.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _repo;
  final AuditRepository _auditRepo;
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

  RecipeProvider({required this._repo, required this._auditRepo}) {
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
    required String userName,
  }) async {
    final recipe = Recipe(
      id: '',
      name: name,
      sellingPrice: sellingPrice,
      ingredients: ingredients,
    );
    final created = await _repo.addRecipe(recipe, userId: userId);
    _recipes.add(created);
    _auditRepo.addLog(AuditLog(
      userId: userId,
      userName: userName,
      action: 'ADD_RECIPE',
      targetType: 'recipe',
      targetId: created.id,
      details: {
        'name': name,
        'ingredients': ingredients.length.toString(),
      },
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> updateRecipe({
    required String id,
    required String name,
    required double sellingPrice,
    required List<RecipeIngredient> ingredients,
    required String userId,
    required String userName,
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
    _auditRepo.addLog(AuditLog(
      userId: userId,
      userName: userName,
      action: 'EDIT_RECIPE',
      targetType: 'recipe',
      targetId: id,
      details: {
        'name': name,
        'ingredients': ingredients.length.toString(),
      },
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> deleteRecipe({
    required String id,
    required String userId,
    required String userName,
  }) async {
    final recipe = _recipes.firstWhere((r) => r.id == id);
    await _repo.deleteRecipe(id);
    _recipes.removeWhere((r) => r.id == id);
    _auditRepo.addLog(AuditLog(
      userId: userId,
      userName: userName,
      action: 'DELETE_RECIPE',
      targetType: 'recipe',
      targetId: id,
      details: {'name': recipe.name},
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}

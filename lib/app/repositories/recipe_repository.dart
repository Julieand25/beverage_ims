import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getAll({String? query});
  Future<Recipe> addRecipe(Recipe recipe, {required String userId});
  Future<Recipe> updateRecipe(Recipe recipe);
  Future<void> deleteRecipe(String id);
}

class SupabaseRecipeRepository implements RecipeRepository {
  final SupabaseClient _client;

  const SupabaseRecipeRepository(this._client);

  Recipe _fromJson(Map<String, dynamic> json, List<Map<String, dynamic>> ingredients) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      sellingPrice: (json['selling_price'] as num).toDouble(),
      ingredients: ingredients
          .map((i) => RecipeIngredient(
                inventoryItemId: i['inventory_item_id'] as String,
                quantity: (i['quantity'] as num).toDouble(),
              ))
          .toList(),
    );
  }

  @override
  Future<List<Recipe>> getAll({String? query}) async {
    var q = _client.from('recipes').select();

    if (query != null && query.isNotEmpty) {
      q = q.ilike('name', '%$query%');
    }

    final recipes = (await q) as List;

    final result = <Recipe>[];
    for (final r in recipes) {
      final recipeJson = r as Map<String, dynamic>;
      final ingredients = await _client
          .from('recipe_ingredients')
          .select()
          .eq('recipe_id', recipeJson['id']);
      result.add(_fromJson(recipeJson, (ingredients as List).cast<Map<String, dynamic>>()));
    }

    return result;
  }

  @override
  Future<Recipe> addRecipe(Recipe recipe, {required String userId}) async {
    final recipeData = await _client.from('recipes').insert({
      'name': recipe.name,
      'selling_price': recipe.sellingPrice,
      'created_by': userId,
    }).select().single();

    final recipeId = recipeData['id'] as String;

    for (final ing in recipe.ingredients) {
      await _client.from('recipe_ingredients').insert({
        'recipe_id': recipeId,
        'inventory_item_id': ing.inventoryItemId,
        'quantity': ing.quantity,
      });
    }

    final ingredients = await _client
        .from('recipe_ingredients')
        .select()
        .eq('recipe_id', recipeId);

    return _fromJson(recipeData, (ingredients as List).cast<Map<String, dynamic>>());
  }

  @override
  Future<Recipe> updateRecipe(Recipe recipe) async {
    await _client.from('recipes').update({
      'name': recipe.name,
      'selling_price': recipe.sellingPrice,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', recipe.id);

    await _client.from('recipe_ingredients').delete().eq('recipe_id', recipe.id);

    for (final ing in recipe.ingredients) {
      await _client.from('recipe_ingredients').insert({
        'recipe_id': recipe.id,
        'inventory_item_id': ing.inventoryItemId,
        'quantity': ing.quantity,
      });
    }

    final recipeData = await _client.from('recipes').select().eq('id', recipe.id).single();
    final ingredients = await _client
        .from('recipe_ingredients')
        .select()
        .eq('recipe_id', recipe.id);

    return _fromJson(recipeData, (ingredients as List).cast<Map<String, dynamic>>());
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await _client.from('recipe_ingredients').delete().eq('recipe_id', id);
    await _client.from('recipes').delete().eq('id', id);
  }
}

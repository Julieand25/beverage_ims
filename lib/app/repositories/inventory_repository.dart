import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory_item.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getAll({ItemCategory? category, String? query});
  Future<InventoryItem> addItem(InventoryItem item, {required String userId});
  Future<InventoryItem> restockItem(String itemId, double addedQty, double totalCost, {required String userId, double? minStock, String? purchaseDate, String? note});
  Future<InventoryItem> adjustStock(String itemId, double changeQty, {required String userId, required double costPerUnit, required String note});
  Future<InventoryItem> updateItem(String id, {String? name, ItemCategory? category, ItemUnit? unit, double? minStock, double? costPerUnit, String? emoji});
  Future<int> getRecipeUsageCount(String itemId);
  Future<void> deleteItem(String id);
}

class SupabaseInventoryRepository implements InventoryRepository {
  final SupabaseClient _client;

  const SupabaseInventoryRepository(this._client);

  ItemCategory _parseCategory(String cat) {
    switch (cat) {
      case 'bahan':
        return ItemCategory.bahan;
      case 'pembungkusan':
        return ItemCategory.pembungkusan;
      case 'lain':
        return ItemCategory.lain;
      default:
        return ItemCategory.bahan;
    }
  }

  ItemUnit _parseUnit(String unit) {
    switch (unit) {
      case 'g':
        return ItemUnit.g;
      case 'ml':
        return ItemUnit.ml;
      case 'unit':
        return ItemUnit.unit;
      case 'kg':
        return ItemUnit.kg;
      case 'l':
        return ItemUnit.l;
      default:
        return ItemUnit.g;
    }
  }

  String _defaultEmoji(ItemCategory category) {
    switch (category) {
      case ItemCategory.bahan:
        return '🍚';
      case ItemCategory.pembungkusan:
        return '🥡';
      case ItemCategory.lain:
        return '📦';
    }
  }

  InventoryItem _fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: _parseCategory(json['category'] as String),
        unit: _parseUnit(json['unit'] as String),
        stock: (json['stock'] as num).toDouble(),
        minStock: (json['min_stock'] as num).toDouble(),
        costPerUnit: (json['cost_per_unit'] as num).toDouble(),
        emoji: (json['emoji'] as String?) ?? _defaultEmoji(_parseCategory(json['category'] as String)),
      );

  @override
  Future<List<InventoryItem>> getAll({ItemCategory? category, String? query}) async {
    var q = _client.from('inventory_items').select();

    if (category != null) {
      q = q.eq('category', category.name);
    }
    if (query != null && query.isNotEmpty) {
      q = q.ilike('name', '%$query%');
    }

    final response = await q;
    return (response as List).map((j) => _fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<InventoryItem> addItem(InventoryItem item, {required String userId}) async {
    final response = await _client.from('inventory_items').insert({
      'name': item.name,
      'category': item.category.name,
      'unit': item.unit.name,
      'stock': item.stock,
      'min_stock': item.minStock,
      'cost_per_unit': item.costPerUnit,
      'emoji': item.emoji,
      'created_by': userId,
    }).select().single();

    return _fromJson(response);
  }

  @override
  Future<InventoryItem> restockItem(String itemId, double addedQty, double totalCost, {required String userId, double? minStock, String? purchaseDate, String? note}) async {
    final result = await _client.rpc('restock_item_atomic', params: {
      'p_item_id': itemId,
      'p_added_qty': addedQty,
      'p_total_cost': totalCost,
      'p_user_id': userId,
      'p_min_stock': minStock,
      'p_purchase_date': purchaseDate,
      'p_note': note,
    });

    return _fromJson((result as List).first as Map<String, dynamic>);
  }

  @override
  Future<InventoryItem> adjustStock(String itemId, double changeQty, {required String userId, required double costPerUnit, required String note}) async {
    final result = await _client.rpc('adjust_stock_atomic', params: {
      'p_item_id': itemId,
      'p_change_qty': changeQty,
      'p_cost_per_unit': costPerUnit,
      'p_user_id': userId,
      'p_note': note,
    });

    return _fromJson((result as List).first as Map<String, dynamic>);
  }

  @override
  Future<InventoryItem> updateItem(String id, {String? name, ItemCategory? category, ItemUnit? unit, double? minStock, double? costPerUnit, String? emoji}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (category != null) data['category'] = category.name;
    if (unit != null) data['unit'] = unit.name;
    if (minStock != null) data['min_stock'] = minStock;
    if (costPerUnit != null) data['cost_per_unit'] = costPerUnit;
    if (emoji != null) data['emoji'] = emoji;
    data['updated_at'] = DateTime.now().toIso8601String();

    final result = await _client.from('inventory_items').update(data).eq('id', id).select().single();
    return _fromJson(result);
  }

  @override
  Future<int> getRecipeUsageCount(String itemId) async {
    final result = await _client.from('recipe_ingredients').select().eq('inventory_item_id', itemId);
    return (result as List).length;
  }

  @override
  Future<void> deleteItem(String id) async {
    await _client.from('inventory_items').delete().eq('id', id);
  }
}

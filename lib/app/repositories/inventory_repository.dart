import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory_item.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getAll({ItemCategory? category, String? query});
  Future<InventoryItem> addItem(InventoryItem item, {required String userId});
  Future<InventoryItem> restockItem(String itemId, double addedQty, double totalCost, {required String userId});
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

  InventoryItem _fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: _parseCategory(json['category'] as String),
        unit: _parseUnit(json['unit'] as String),
        stock: (json['stock'] as num).toDouble(),
        minStock: (json['min_stock'] as num).toDouble(),
        costPerUnit: (json['cost_per_unit'] as num).toDouble(),
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
      'created_by': userId,
    }).select().single();

    return _fromJson(response);
  }

  @override
  Future<InventoryItem> restockItem(String itemId, double addedQty, double totalCost, {required String userId}) async {
    final response = await _client.from('inventory_items').select().eq('id', itemId).single();
    final currentStock = (response['stock'] as num).toDouble();
    final currentCostPerUnit = (response['cost_per_unit'] as num).toDouble();
    final currentValue = currentStock * currentCostPerUnit;
    final newStock = currentStock + addedQty;
    final newCostPerUnit = (currentValue + totalCost) / newStock;

    await _client.from('inventory_items').update({
      'stock': newStock,
      'cost_per_unit': newCostPerUnit,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', itemId);

    await _client.from('stock_movements').insert({
      'inventory_item_id': itemId,
      'type': 'restock',
      'quantity': addedQty,
      'cost_per_unit': totalCost / addedQty,
      'total_cost': totalCost,
      'user_id': userId,
    });

    final updated = await _client.from('inventory_items').select().eq('id', itemId).single();
    return _fromJson(updated);
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SalesRepository {
  Future<void> recordSale({
    required String recipeId,
    required String recipeName,
    required int quantity,
    required double unitPrice,
    required double totalAmount,
    required String userId,
  });
  Future<Map<String, dynamic>> getDailyStats();
  Future<List<Map<String, dynamic>>> getBestSellers();
  Future<Map<String, dynamic>> getMonthlyStats();
  Future<List<Map<String, dynamic>>> getStockMovements();
}

class SupabaseSalesRepository implements SalesRepository {
  final SupabaseClient _client;

  const SupabaseSalesRepository(this._client);

  @override
  Future<void> recordSale({
    required String recipeId,
    required String recipeName,
    required int quantity,
    required double unitPrice,
    required double totalAmount,
    required String userId,
  }) async {
    await _client.from('sales').insert({
      'recipe_id': recipeId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'recorded_by': userId,
    });

    final ingredients = await _client
        .from('recipe_ingredients')
        .select()
        .eq('recipe_id', recipeId);

    for (final ing in (ingredients as List)) {
      final itemId = (ing as Map<String, dynamic>)['inventory_item_id'] as String;
      final qtyPerCup = (ing['quantity'] as num).toDouble();
      final totalDeduct = qtyPerCup * quantity;

      final item = await _client
          .from('inventory_items')
          .select()
          .eq('id', itemId)
          .single();

      final newStock = (item['stock'] as num).toDouble() - totalDeduct;

      await _client
          .from('inventory_items')
          .update({'stock': newStock, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', itemId);

      await _client.from('stock_movements').insert({
        'inventory_item_id': itemId,
        'type': 'sale',
        'quantity': -totalDeduct,
        'user_id': userId,
      });
    }
  }

  @override
  Future<Map<String, dynamic>> getDailyStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

    final salesToday = await _client
        .from('sales')
        .select()
        .gte('sold_at', startOfDay)
        .lte('sold_at', endOfDay);

    double totalSales = 0;
    int totalCups = 0;
    for (final s in (salesToday as List)) {
      totalSales += (s['total_amount'] as num).toDouble();
      totalCups += (s['quantity'] as num).toInt();
    }

    final cogs = await _computeSalesCOGS(salesToday);

    return {
      'total_sales': totalSales,
      'total_cups': totalCups,
      'total_cogs': cogs,
      'total_profit': totalSales - cogs,
    };
  }

  Future<double> _computeSalesCOGS(List sales) async {
    if (sales.isEmpty) return 0;

    final recipeIds = sales
        .map((s) => (s as Map<String, dynamic>)['recipe_id'] as String)
        .toSet()
        .toList();

    final ingredients = await _client
        .from('recipe_ingredients')
        .select('recipe_id, inventory_item_id, quantity')
        .inFilter('recipe_id', recipeIds);

    if ((ingredients as List).isEmpty) return 0;

    final itemIds = ingredients
        .map((i) => (i as Map<String, dynamic>)['inventory_item_id'] as String)
        .toSet()
        .toList();

    final items = await _client
        .from('inventory_items')
        .select('id, cost_per_unit')
        .inFilter('id', itemIds);

    final costMap = {
      for (final i in (items as List))
        (i as Map<String, dynamic>)['id'] as String:
            (i['cost_per_unit'] as num).toDouble()
    };

    final recipeIngredients = <String, List<Map<String, dynamic>>>{};
    for (final ing in ingredients) {
      final map = ing as Map<String, dynamic>;
      recipeIngredients.putIfAbsent(map['recipe_id'] as String, () => []).add(map);
    }

    double total = 0;
    for (final s in sales) {
      final sm = s as Map<String, dynamic>;
      final rid = sm['recipe_id'] as String;
      final qty = (sm['quantity'] as num).toInt();
      for (final ing in recipeIngredients[rid] ?? const <Map<String, dynamic>>[]) {
        final itemId = ing['inventory_item_id'] as String;
        final perCup = (ing['quantity'] as num).toDouble();
        total += perCup * qty * (costMap[itemId] ?? 0);
      }
    }
    return total;
  }

  @override
  Future<List<Map<String, dynamic>>> getBestSellers() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

    final salesToday = await _client
        .from('sales')
        .select()
        .gte('sold_at', startOfDay)
        .lte('sold_at', endOfDay);

    final Map<String, Map<String, dynamic>> grouped = {};
    for (final s in (salesToday as List)) {
      final rId = s['recipe_id'] as String;
      if (!grouped.containsKey(rId)) {
        final recipe = await _client.from('recipes').select().eq('id', rId).maybeSingle();
        grouped[rId] = {
          'recipe_id': rId,
          'recipe_name': recipe?['name'] ?? 'Unknown',
          'total_cups': 0,
          'total_revenue': 0.0,
        };
      }
      grouped[rId]!['total_cups'] = (grouped[rId]!['total_cups'] as int) + (s['quantity'] as num).toInt();
      grouped[rId]!['total_revenue'] = (grouped[rId]!['total_revenue'] as double) + (s['total_amount'] as num).toDouble();
    }

    final sorted = grouped.values.toList()
      ..sort((a, b) => (b['total_cups'] as int).compareTo(a['total_cups'] as int));

    return sorted.take(3).toList();
  }

  @override
  Future<Map<String, dynamic>> getMonthlyStats() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59).toIso8601String();

    final salesThisMonth = await _client
        .from('sales')
        .select()
        .gte('sold_at', startOfMonth)
        .lte('sold_at', endOfMonth);

    final cogs = await _computeSalesCOGS(salesThisMonth);

    double totalRevenue = 0;
    final Map<int, Map<String, double>> weekly = {};
    for (final s in (salesThisMonth as List)) {
      totalRevenue += (s['total_amount'] as num).toDouble();
      final date = DateTime.parse(s['sold_at'] as String);
      final weekNum = ((date.day - 1) ~/ 7) + 1;
      weekly.putIfAbsent(weekNum, () => {'revenue': 0, 'cost': 0});
      weekly[weekNum]!['revenue'] = (weekly[weekNum]!['revenue']! + (s['total_amount'] as num).toDouble());
    }

    final cogsPerSale = await _computeCogsPerSale(salesThisMonth);
    for (final entry in cogsPerSale.entries) {
      final s = (salesThisMonth as List)[entry.key] as Map<String, dynamic>;
      final date = DateTime.parse(s['sold_at'] as String);
      final weekNum = ((date.day - 1) ~/ 7) + 1;
      weekly[weekNum]!['cost'] = (weekly[weekNum]!['cost'] ?? 0) + entry.value;
    }

    return {
      'total_revenue': totalRevenue,
      'total_cogs': cogs,
      'total_profit': totalRevenue - cogs,
      'weekly': weekly,
    };
  }

  Future<Map<int, double>> _computeCogsPerSale(List sales) async {
    final result = <int, double>{};
    if (sales.isEmpty) return result;

    final recipeIds = sales
        .map((s) => (s as Map<String, dynamic>)['recipe_id'] as String)
        .toSet()
        .toList();

    final ingredients = await _client
        .from('recipe_ingredients')
        .select('recipe_id, inventory_item_id, quantity')
        .inFilter('recipe_id', recipeIds);

    if ((ingredients as List).isEmpty) return result;

    final itemIds = ingredients
        .map((i) => (i as Map<String, dynamic>)['inventory_item_id'] as String)
        .toSet()
        .toList();

    final items = await _client
        .from('inventory_items')
        .select('id, cost_per_unit')
        .inFilter('id', itemIds);

    final costMap = {
      for (final i in (items as List))
        (i as Map<String, dynamic>)['id'] as String:
            (i['cost_per_unit'] as num).toDouble()
    };

    final recipeIngredients = <String, List<Map<String, dynamic>>>{};
    for (final ing in ingredients) {
      final map = ing as Map<String, dynamic>;
      recipeIngredients.putIfAbsent(map['recipe_id'] as String, () => []).add(map);
    }

    for (var idx = 0; idx < (sales as List).length; idx++) {
      final sm = sales[idx] as Map<String, dynamic>;
      final rid = sm['recipe_id'] as String;
      final qty = (sm['quantity'] as num).toInt();
      double saleCogs = 0;
      for (final ing in recipeIngredients[rid] ?? const <Map<String, dynamic>>[]) {
        final itemId = ing['inventory_item_id'] as String;
        final perCup = (ing['quantity'] as num).toDouble();
        saleCogs += perCup * qty * (costMap[itemId] ?? 0);
      }
      result[idx] = saleCogs;
    }
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getStockMovements() async {
    final response = await _client
        .from('stock_movements')
        .select('*, inventory_items(name)')
        .order('moved_at', ascending: false)
        .limit(30);

    return (response as List).cast<Map<String, dynamic>>();
  }
}

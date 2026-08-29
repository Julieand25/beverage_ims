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
  Future<Map<String, dynamic>> getDailyStats({required DateTime date});
  Future<List<Map<String, dynamic>>> getBestSellers({required DateTime date});
  Future<List<Map<String, dynamic>>> getDailyTransactions({required DateTime date});
  Future<Map<String, dynamic>> getMonthlyStats({required DateTime month});
  Future<List<Map<String, dynamic>>> getStockMovements({DateTime? startDate, DateTime? endDate});
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
    await _client.rpc('record_sale_atomic', params: {
      'p_recipe_id': recipeId,
      'p_quantity': quantity,
      'p_unit_price': unitPrice,
      'p_total_amount': totalAmount,
      'p_user_id': userId,
    });
  }

  @override
  Future<Map<String, dynamic>> getDailyStats({required DateTime date}) async {
    final startOfDay = DateTime(date.year, date.month, date.day).toUtc().toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toUtc().toIso8601String();

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

    final cogs = await _computeSalesCOGS(startOfDay, endOfDay);

    return {
      'total_sales': totalSales,
      'total_cups': totalCups,
      'total_cogs': cogs,
      'total_profit': totalSales - cogs,
    };
  }

  Future<double> _computeSalesCOGS(String start, String end) async {
    final movements = await _client
        .from('stock_movements')
        .select('quantity, cost_per_unit')
        .eq('type', 'sale')
        .gte('moved_at', start)
        .lte('moved_at', end);

    double total = 0;
    for (final m in (movements as List)) {
      total += (m['quantity'] as num).toDouble().abs() * (m['cost_per_unit'] as num? ?? 0).toDouble();
    }
    return total;
  }

  @override
  Future<List<Map<String, dynamic>>> getBestSellers({required DateTime date}) async {
    final startOfDay = DateTime(date.year, date.month, date.day).toUtc().toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toUtc().toIso8601String();

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
          'emoji': recipe?['emoji'],
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
  Future<List<Map<String, dynamic>>> getDailyTransactions({required DateTime date}) async {
    final startOfDay = DateTime(date.year, date.month, date.day).toUtc().toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toUtc().toIso8601String();

    final transactions = await _client
        .from('sales')
        .select('*, recipes(name)')
        .gte('sold_at', startOfDay)
        .lte('sold_at', endOfDay)
        .order('sold_at', ascending: false);

    return (transactions as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> getMonthlyStats({required DateTime month}) async {
    final startOfMonth = DateTime(month.year, month.month, 1).toUtc().toIso8601String();
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toUtc().toIso8601String();

    final salesThisMonth = await _client
        .from('sales')
        .select()
        .gte('sold_at', startOfMonth)
        .lte('sold_at', endOfMonth);

    double totalRevenue = 0;
    final Map<int, Map<String, double>> weekly = {};
    for (final s in (salesThisMonth as List)) {
      totalRevenue += (s['total_amount'] as num).toDouble();
      final date = DateTime.parse(s['sold_at'] as String);
      final weekNum = ((date.day - 1) ~/ 7) + 1;
      weekly.putIfAbsent(weekNum, () => {'revenue': 0, 'cost': 0});
      weekly[weekNum]!['revenue'] = (weekly[weekNum]!['revenue']! + (s['total_amount'] as num).toDouble());
    }

    final monthMovements = await _client
        .from('stock_movements')
        .select('quantity, cost_per_unit, moved_at')
        .eq('type', 'sale')
        .gte('moved_at', startOfMonth)
        .lte('moved_at', endOfMonth);

    double totalCogs = 0;
    for (final m in (monthMovements as List)) {
      final cogs = (m['quantity'] as num).toDouble().abs() * (m['cost_per_unit'] as num? ?? 0).toDouble();
      totalCogs += cogs;
      final date = DateTime.parse(m['moved_at'] as String);
      final weekNum = ((date.day - 1) ~/ 7) + 1;
      weekly.putIfAbsent(weekNum, () => {'revenue': 0, 'cost': 0});
      weekly[weekNum]!['cost'] = (weekly[weekNum]!['cost'] ?? 0) + cogs;
    }

    return {
      'total_revenue': totalRevenue,
      'total_cogs': totalCogs,
      'total_profit': totalRevenue - totalCogs,
      'weekly': weekly,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getStockMovements({DateTime? startDate, DateTime? endDate}) async {
    PostgrestFilterBuilder filter = _client
        .from('stock_movements')
        .select('*, inventory_items(name)');

    if (startDate != null) {
      filter = filter.gte('moved_at', startDate.toUtc().toIso8601String());
    }
    if (endDate != null) {
      filter = filter.lte('moved_at', DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59).toUtc().toIso8601String());
    }

    PostgrestTransformBuilder query = filter;
    if (startDate == null && endDate == null) {
      query = query.limit(30);
    }

    final response = await query.order('moved_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>();
  }
}

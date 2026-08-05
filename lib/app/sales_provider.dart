import 'package:flutter/material.dart';
import 'repositories/sales_repository.dart';

class SalesProvider extends ChangeNotifier {
  final SalesRepository _repo;

  double _todaySales = 0;
  int _todayCups = 0;
  double _todayCogs = 0;
  double _todayProfit = 0;
  List<Map<String, dynamic>> _bestSellers = [];
  double _monthlyRevenue = 0;
  double _monthlyCogs = 0;
  double _monthlyProfit = 0;
  Map<int, Map<String, double>> _weeklyStats = {};
  List<Map<String, dynamic>> _stockMovements = [];
  bool _isLoading = true;

  double get todaySales => _todaySales;
  int get todayCups => _todayCups;
  double get todayCogs => _todayCogs;
  double get todayProfit => _todayProfit;
  List<Map<String, dynamic>> get bestSellers => _bestSellers;
  double get monthlyRevenue => _monthlyRevenue;
  double get monthlyCogs => _monthlyCogs;
  double get monthlyProfit => _monthlyProfit;
  Map<int, Map<String, double>> get weeklyStats => _weeklyStats;
  List<Map<String, dynamic>> get stockMovements => _stockMovements;
  bool get isLoading => _isLoading;

  SalesProvider({required this._repo}) {
    loadAll();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    await Future.wait([
      loadDailyStats(),
      loadBestSellers(),
      loadMonthlyStats(),
      loadStockMovements(),
    ]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadDailyStats() async {
    final stats = await _repo.getDailyStats();
    _todaySales = (stats['total_sales'] as num).toDouble();
    _todayCups = stats['total_cups'] as int;
    _todayCogs = (stats['total_cogs'] as num).toDouble();
    _todayProfit = (stats['total_profit'] as num).toDouble();
    notifyListeners();
  }

  Future<void> loadBestSellers() async {
    _bestSellers = await _repo.getBestSellers();
    notifyListeners();
  }

  Future<void> loadMonthlyStats() async {
    final stats = await _repo.getMonthlyStats();
    _monthlyRevenue = (stats['total_revenue'] as num).toDouble();
    _monthlyCogs = (stats['total_cogs'] as num).toDouble();
    _monthlyProfit = (stats['total_profit'] as num).toDouble();
    _weeklyStats = (stats['weekly'] as Map).map((k, v) => MapEntry(k as int, (v as Map).map((kk, vv) => MapEntry(kk as String, (vv as num).toDouble()))));
    notifyListeners();
  }

  Future<void> loadStockMovements() async {
    _stockMovements = await _repo.getStockMovements();
    notifyListeners();
  }

  Future<void> recordSale({
    required String recipeId,
    required String recipeName,
    required int quantity,
    required double unitPrice,
    required double totalAmount,
    required String userId,
    required String userName,
  }) async {
    await _repo.recordSale(
      recipeId: recipeId,
      recipeName: recipeName,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      userId: userId,
    );
    await loadAll();
  }
}

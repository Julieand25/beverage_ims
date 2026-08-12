import 'package:flutter/material.dart';
import 'models/audit_log.dart';
import 'repositories/audit_repository.dart';
import 'repositories/sales_repository.dart';

class SalesProvider extends ChangeNotifier {
  final SalesRepository _repo;
  final AuditRepository _auditRepo;

  double _todaySales = 0;
  int _todayCups = 0;
  double _todayCogs = 0;
  double _todayProfit = 0;
  List<Map<String, dynamic>> _bestSellers = [];
  List<Map<String, dynamic>> _dailyTransactions = [];
  double _yesterdaySales = 0;
  int _yesterdayCups = 0;
  double _yesterdayCogs = 0;
  double _yesterdayProfit = 0;
  double _monthlyRevenue = 0;
  double _monthlyCogs = 0;
  double _monthlyProfit = 0;
  Map<int, Map<String, double>> _weeklyStats = {};
  double _lastMonthRevenue = 0;
  double _lastMonthCogs = 0;
  double _lastMonthProfit = 0;
  List<Map<String, dynamic>> _stockMovements = [];
  bool _isLoading = true;

  double get todaySales => _todaySales;
  int get todayCups => _todayCups;
  double get todayCogs => _todayCogs;
  double get todayProfit => _todayProfit;
  List<Map<String, dynamic>> get bestSellers => _bestSellers;
  List<Map<String, dynamic>> get dailyTransactions => _dailyTransactions;
  double get yesterdaySales => _yesterdaySales;
  int get yesterdayCups => _yesterdayCups;
  double get yesterdayCogs => _yesterdayCogs;
  double get yesterdayProfit => _yesterdayProfit;
  double get monthlyRevenue => _monthlyRevenue;
  double get monthlyCogs => _monthlyCogs;
  double get monthlyProfit => _monthlyProfit;
  Map<int, Map<String, double>> get weeklyStats => _weeklyStats;
  double get lastMonthRevenue => _lastMonthRevenue;
  double get lastMonthCogs => _lastMonthCogs;
  double get lastMonthProfit => _lastMonthProfit;
  List<Map<String, dynamic>> get stockMovements => _stockMovements;
  bool get isLoading => _isLoading;

  SalesProvider({required this._repo, required this._auditRepo}) {
    loadAll();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    await Future.wait([
      loadDailyStats(),
      loadBestSellers(),
      loadDailyTransactions(),
      loadMonthlyStats(),
      loadStockMovements(),
    ]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadDailyStats({DateTime? date}) async {
    final stats = await _repo.getDailyStats(date: date ?? DateTime.now());
    _todaySales = (stats['total_sales'] as num).toDouble();
    _todayCups = stats['total_cups'] as int;
    _todayCogs = (stats['total_cogs'] as num).toDouble();
    _todayProfit = (stats['total_profit'] as num).toDouble();
    notifyListeners();
  }

  Future<void> loadBestSellers({DateTime? date}) async {
    _bestSellers = await _repo.getBestSellers(date: date ?? DateTime.now());
    notifyListeners();
  }

  Future<void> loadDailyTransactions({DateTime? date}) async {
    _dailyTransactions = await _repo.getDailyTransactions(date: date ?? DateTime.now());
    notifyListeners();
  }

  Future<void> loadDailyComparison(DateTime date) async {
    await Future.wait([
      loadDailyStats(date: date),
      loadBestSellers(date: date),
      loadDailyTransactions(date: date),
    ]);

    final yesterday = date.subtract(const Duration(days: 1));
    final yStats = await _repo.getDailyStats(date: yesterday);
    _yesterdaySales = (yStats['total_sales'] as num).toDouble();
    _yesterdayCups = yStats['total_cups'] as int;
    _yesterdayCogs = (yStats['total_cogs'] as num).toDouble();
    _yesterdayProfit = (yStats['total_profit'] as num).toDouble();
    notifyListeners();
  }

  Future<void> loadMonthlyStats({DateTime? month}) async {
    final stats = await _repo.getMonthlyStats(month: month ?? DateTime.now());
    _monthlyRevenue = (stats['total_revenue'] as num).toDouble();
    _monthlyCogs = (stats['total_cogs'] as num).toDouble();
    _monthlyProfit = (stats['total_profit'] as num).toDouble();
    _weeklyStats = (stats['weekly'] as Map).map((k, v) => MapEntry(k as int, (v as Map).map((kk, vv) => MapEntry(kk as String, (vv as num).toDouble()))));
    notifyListeners();
  }

  Future<void> loadMonthlyComparison(DateTime month) async {
    await loadMonthlyStats(month: month);

    final prevMonth = DateTime(month.year, month.month - 1, 1);
    final pStats = await _repo.getMonthlyStats(month: prevMonth);
    _lastMonthRevenue = (pStats['total_revenue'] as num).toDouble();
    _lastMonthCogs = (pStats['total_cogs'] as num).toDouble();
    _lastMonthProfit = (pStats['total_profit'] as num).toDouble();
    notifyListeners();
  }

  Future<void> loadStockMovements({DateTime? startDate, DateTime? endDate}) async {
    _stockMovements = await _repo.getStockMovements(startDate: startDate, endDate: endDate);
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
    _auditRepo.addLog(AuditLog(
      userId: userId,
      userName: userName,
      action: 'RECORD_SALE',
      targetType: 'sales',
      targetId: recipeId,
      details: {'recipe': recipeName, 'qty': quantity, 'amount': totalAmount.toStringAsFixed(2)},
      timestamp: DateTime.now(),
    ));
    await loadAll();
  }
}

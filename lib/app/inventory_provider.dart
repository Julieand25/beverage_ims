import 'package:flutter/material.dart';
import 'models/audit_log.dart';
import 'models/inventory_item.dart';
import 'repositories/audit_repository.dart';
import 'repositories/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryRepository _repo;
  final AuditRepository _auditRepo;
  List<InventoryItem> _items = [];
  String _searchQuery = '';
  ItemCategory? _selectedCategory;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  ItemCategory? get selectedCategory => _selectedCategory;
  List<InventoryItem> get items => List.unmodifiable(_items);

  List<InventoryItem> get filteredItems {
    var result = _items.where((item) {
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !item.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
    return result;
  }

  InventoryProvider({required this._repo, required this._auditRepo}) {
    loadAll();
  }

  Future<void> loadAll() async {
    _items = await _repo.getAll();
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(ItemCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<InventoryItem?> addItem({
    required String name,
    required ItemCategory category,
    required ItemUnit unit,
    required double stock,
    required double minStock,
    required double costPerUnit,
    required String userId,
    required String userName,
    String emoji = '',
  }) async {
    final item = InventoryItem(
      id: '',
      name: name,
      category: category,
      unit: unit,
      stock: stock,
      minStock: minStock,
      costPerUnit: costPerUnit,
      emoji: emoji,
    );
    final created = await _repo.addItem(item, userId: userId);
    _items.add(created);
    _auditRepo.addLog(AuditLog(
      userId: userId,
      userName: userName,
      action: 'ADD_ITEM',
      targetType: 'inventory',
      targetId: created.id,
      details: {'name': name, 'category': category.name, 'unit': unit.name},
      timestamp: DateTime.now(),
    ));
    notifyListeners();
    return created;
  }

  Future<InventoryItem?> addItemQuick({
    required String name,
    required ItemCategory category,
    required ItemUnit unit,
    required String userId,
    required String userName,
    String emoji = '',
  }) async {
    return addItem(
      name: name,
      category: category,
      unit: unit,
      stock: 0,
      minStock: 0,
      costPerUnit: 0,
      userId: userId,
      userName: userName,
      emoji: emoji,
    );
  }

  Future<void> restockItem({
    required String itemId,
    required double addedQty,
    required double totalCost,
    required String userId,
    required String userName,
    double? minStock,
    String? purchaseDate,
    String? note,
  }) async {
    final item = _items.firstWhere((i) => i.id == itemId);
    final updated = await _repo.restockItem(itemId, addedQty, totalCost, userId: userId, minStock: minStock, purchaseDate: purchaseDate, note: note);
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index].stock = updated.stock;
      _items[index].costPerUnit = updated.costPerUnit;
      _items[index].minStock = updated.minStock;
    }
    _auditRepo.addLog(AuditLog(
      userId: userId,
      userName: userName,
      action: 'RESTOCK_ITEM',
      targetType: 'inventory',
      targetId: itemId,
      details: {'name': item.name, 'qty': addedQty.toString(), 'total_cost': totalCost.toStringAsFixed(2)},
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> adjustStock({
    required String itemId,
    required double changeQty,
    required String userId,
    required String userName,
    required double costPerUnit,
    required String note,
  }) async {
    final item = _items.firstWhere((i) => i.id == itemId);
    final updated = await _repo.adjustStock(itemId, changeQty, userId: userId, costPerUnit: costPerUnit, note: note);
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index].stock = updated.stock;
    }
    _auditRepo.addLog(AuditLog(
      userId: userId,
      userName: userName,
      action: 'STOCK_ADJUST',
      targetType: 'inventory',
      targetId: itemId,
      details: {'name': item.name, 'change': changeQty.toString(), 'note': note},
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> updateItem({
    required String id,
    required String userId,
    required String userName,
    String? name,
    ItemCategory? category,
    ItemUnit? unit,
    double? minStock,
    double? costPerUnit,
    String? emoji,
  }) async {
    final old = _items.firstWhere((i) => i.id == id);
    final updated = await _repo.updateItem(id, name: name, category: category, unit: unit, minStock: minStock, costPerUnit: costPerUnit, emoji: emoji);
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index] = updated;
    }
    final changes = <String, String>{};
    if (name != null && name != old.name) changes['name'] = '${old.name} → $name';
    if (category != null && category != old.category) changes['category'] = category.name;
    if (minStock != null && minStock != old.minStock) changes['min_stock'] = minStock.toString();
    _auditRepo.addLog(AuditLog(
      userId: userId,
      userName: userName,
      action: 'EDIT_ITEM',
      targetType: 'inventory',
      targetId: id,
      details: {'name': updated.name, 'changes': changes},
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<int> getRecipeUsageCount(String itemId) async {
    return _repo.getRecipeUsageCount(itemId);
  }

  Future<void> deleteItem({
    required String id,
    required String userId,
    required String userName,
  }) async {
    final item = _items.firstWhere((i) => i.id == id);
    await _repo.deleteItem(id);
    _items.removeWhere((i) => i.id == id);
    _auditRepo.addLog(AuditLog(
      userId: userId,
      userName: userName,
      action: 'DELETE_ITEM',
      targetType: 'inventory',
      targetId: id,
      details: {'name': item.name, 'category': item.category.name},
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'models/inventory_item.dart';
import 'repositories/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryRepository _repo;
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

  InventoryProvider({required this._repo}) {
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
  }) async {
    final item = InventoryItem(
      id: '',
      name: name,
      category: category,
      unit: unit,
      stock: stock,
      minStock: minStock,
      costPerUnit: costPerUnit,
    );
    final created = await _repo.addItem(item, userId: userId);
    _items.add(created);
    notifyListeners();
    return created;
  }

  Future<InventoryItem?> addItemQuick({
    required String name,
    required ItemCategory category,
    required ItemUnit unit,
    required String userId,
  }) async {
    return addItem(
      name: name,
      category: category,
      unit: unit,
      stock: 0,
      minStock: 0,
      costPerUnit: 0,
      userId: userId,
    );
  }

  Future<void> restockItem({
    required String itemId,
    required double addedQty,
    required double totalCost,
    required String userId,
    double? minStock,
  }) async {
    final updated = await _repo.restockItem(itemId, addedQty, totalCost, userId: userId, minStock: minStock);
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index].stock = updated.stock;
      _items[index].costPerUnit = updated.costPerUnit;
      _items[index].minStock = updated.minStock;
    }
    notifyListeners();
  }
}

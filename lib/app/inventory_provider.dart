import 'package:flutter/material.dart';
import 'models/inventory_item.dart';

class InventoryProvider extends ChangeNotifier {
  final List<InventoryItem> _items = [
    InventoryItem(
      id: '1',
      name: 'Matcha Powder',
      category: ItemCategory.bahan,
      unit: ItemUnit.g,
      stock: 300,
      minStock: 500,
      costPerUnit: 0.065,
    ),
    InventoryItem(
      id: '2',
      name: 'Susu UHT',
      category: ItemCategory.bahan,
      unit: ItemUnit.ml,
      stock: 2000,
      minStock: 1000,
      costPerUnit: 0.008,
    ),
    InventoryItem(
      id: '3',
      name: 'Sirap Gula',
      category: ItemCategory.bahan,
      unit: ItemUnit.ml,
      stock: 150,
      minStock: 500,
      costPerUnit: 0.012,
    ),
    InventoryItem(
      id: '4',
      name: 'Cawan 16oz',
      category: ItemCategory.pembungkusan,
      unit: ItemUnit.unit,
      stock: 100,
      minStock: 50,
      costPerUnit: 0.48,
    ),
    InventoryItem(
      id: '5',
      name: 'Lids',
      category: ItemCategory.pembungkusan,
      unit: ItemUnit.unit,
      stock: 30,
      minStock: 100,
      costPerUnit: 0.12,
    ),
    InventoryItem(
      id: '6',
      name: 'Straws',
      category: ItemCategory.pembungkusan,
      unit: ItemUnit.unit,
      stock: 500,
      minStock: 200,
      costPerUnit: 0.05,
    ),
    InventoryItem(
      id: '7',
      name: 'Ice / Ais',
      category: ItemCategory.lain,
      unit: ItemUnit.kg,
      stock: 10,
      minStock: 5,
      costPerUnit: 1.50,
    ),
  ];

  String _searchQuery = '';
  ItemCategory? _selectedCategory;

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

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(ItemCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void addItem({
    required String name,
    required ItemCategory category,
    required ItemUnit unit,
    required double stock,
    required double minStock,
    required double costPerUnit,
  }) {
    _items.add(InventoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      unit: unit,
      stock: stock,
      minStock: minStock,
      costPerUnit: costPerUnit,
    ));
    notifyListeners();
  }

  void restockItem({
    required String itemId,
    required double addedQty,
    required double totalCost,
  }) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;
    final item = _items[index];
    final currentValue = item.stock * item.costPerUnit;
    final newStock = item.stock + addedQty;
    item.costPerUnit = (currentValue + totalCost) / newStock;
    item.stock = newStock;
    notifyListeners();
  }
}

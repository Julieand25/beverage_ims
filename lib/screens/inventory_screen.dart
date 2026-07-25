import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/inventory_provider.dart';
import '../app/models/inventory_item.dart';
import '../app/translations.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final provider = context.watch<InventoryProvider>();
    const backgroundColor = Color(0xFFF9F9F9);
    const primaryGreen = Color(0xFF5BA154);
    const textDark = Color(0xFF2C3E50);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: textDark),
          onPressed: () {},
        ),
        title: SizedBox(
          height: 36,
          child: TextField(
            onChanged: (v) => provider.setSearchQuery(v),
            decoration: InputDecoration(
              hintText: t.searchItem,
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: primaryGreen, size: 28),
            onPressed: () => _showAddItemDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _CategoryPills(provider: provider),
          Expanded(
            child: provider.filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'Tiada barang dijumpai',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.filteredItems.length + 1,
                    itemBuilder: (context, index) {
                      if (index == provider.filteredItems.length) {
                        return _RestockBanner(
                          onTap: () => _showRestockDialog(context),
                        );
                      }
                      return _InventoryCard(
                        item: provider.filteredItems[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final t = Translations.of(context);
    final nameCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final minStockCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    var category = ItemCategory.bahan;
    var unit = ItemUnit.g;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(t.addNewItem, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                _dialogField(t.itemName, nameCtrl),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: _dialogInputDecoration(t.category),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ItemCategory>(
                      value: category,
                      isDense: true,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: ItemCategory.bahan, child: Text('Bahan')),
                        DropdownMenuItem(value: ItemCategory.pembungkusan, child: Text('Pembungkusan')),
                        DropdownMenuItem(value: ItemCategory.lain, child: Text('Lain-lain')),
                      ],
                      onChanged: (v) => setDialogState(() => category = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: _dialogInputDecoration(t.unit),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ItemUnit>(
                      value: unit,
                      isDense: true,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: ItemUnit.g, child: Text('g')),
                        DropdownMenuItem(value: ItemUnit.ml, child: Text('ml')),
                        DropdownMenuItem(value: ItemUnit.unit, child: Text('unit')),
                        DropdownMenuItem(value: ItemUnit.kg, child: Text('kg')),
                        DropdownMenuItem(value: ItemUnit.l, child: Text('L')),
                      ],
                      onChanged: (v) => setDialogState(() => unit = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _dialogField(t.initialStock, stockCtrl, isNumber: true),
                const SizedBox(height: 12),
                _dialogField(t.minStock, minStockCtrl, isNumber: true),
                const SizedBox(height: 12),
                _dialogField(t.costPerUnit, costCtrl, isNumber: true),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5BA154)),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                context.read<InventoryProvider>().addItem(
                  name: nameCtrl.text.trim(),
                  category: category,
                  unit: unit,
                  stock: double.tryParse(stockCtrl.text) ?? 0,
                  minStock: double.tryParse(minStockCtrl.text) ?? 0,
                  costPerUnit: double.tryParse(costCtrl.text) ?? 0,
                );
                Navigator.pop(ctx);
              },
              child: Text(t.save, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestockDialog(BuildContext context) {
    final t = Translations.of(context);
    final qtyCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final provider = context.read<InventoryProvider>();
    var selectedId = provider.items.isNotEmpty ? provider.items.first.id : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(t.addStock, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                InputDecorator(
                  decoration: _dialogInputDecoration(t.item),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedId,
                      isDense: true,
                      isExpanded: true,
                      items: provider.items
                          .map((i) => DropdownMenuItem(
                                value: i.id,
                                child: Text('${i.name} (${i.stock.toStringAsFixed(0)} ${_unitLabel(i.unit)})'),
                              ))
                          .toList(),
                      onChanged: (v) => setDialogState(() => selectedId = v),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _dialogField(t.addedQty, qtyCtrl, isNumber: true),
                const SizedBox(height: 12),
                _dialogField(t.totalCost, costCtrl, isNumber: true),
                const SizedBox(height: 12),
                _dialogField(t.note, noteCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5BA154)),
              onPressed: () {
                if (selectedId == null) return;
                final addedQty = double.tryParse(qtyCtrl.text) ?? 0;
                final totalCost = double.tryParse(costCtrl.text) ?? 0;
                if (addedQty <= 0) return;
                provider.restockItem(
                  itemId: selectedId!,
                  addedQty: addedQty,
                  totalCost: totalCost,
                );
                Navigator.pop(ctx);
              },
              child: Text(t.save, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPills extends StatelessWidget {
  final InventoryProvider provider;
  const _CategoryPills({required this.provider});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    const primaryGreen = Color(0xFF5BA154);

    final pills = [
      _PillData(t.all, null),
      _PillData(t.ingredients, ItemCategory.bahan),
      _PillData(t.packaging, ItemCategory.pembungkusan),
      _PillData(t.others, ItemCategory.lain),
    ];

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: pills.map((p) {
          final selected = provider.selectedCategory == p.category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => provider.setCategory(p.category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? primaryGreen : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Text(
                  p.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF2C3E50),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PillData {
  final String label;
  final ItemCategory? category;
  const _PillData(this.label, this.category);
}

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  const _InventoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    const textDark = Color(0xFF2C3E50);
    const primaryGreen = Color(0xFF5BA154);
    const softRedBg = Color(0xFFFDF0F0);
    const softGreenBg = Color(0xFFEAF5EA);

    final iconData = _categoryIcon(item.category);
    final bgColor = item.isLowStock ? softRedBg : softGreenBg;
    final statusColor = item.isLowStock ? Colors.red : primaryGreen;
    final statusText = item.isLowStock ? t.lowStock : t.sufficient;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${t.stockValue}: RM ${item.stockValue.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 1),
                Text(
                  'RM ${item.costPerUnit.toStringAsFixed(3)}/${_unitLabel(item.unit)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.stock.toStringAsFixed(0)} ${_unitLabel(item.unit)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RestockBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _RestockBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    const primaryGreen = Color(0xFF5BA154);

    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_shipping_outlined, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.restock,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: Text(
              '+ ${t.addStock}',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _categoryIcon(ItemCategory category) {
  switch (category) {
    case ItemCategory.bahan:
      return Icons.inventory_2_outlined;
    case ItemCategory.pembungkusan:
      return Icons.inventory_outlined;
    case ItemCategory.lain:
      return Icons.category_outlined;
  }
}

String _unitLabel(ItemUnit unit) {
  switch (unit) {
    case ItemUnit.g:
      return 'g';
    case ItemUnit.ml:
      return 'ml';
    case ItemUnit.unit:
      return 'unit';
    case ItemUnit.kg:
      return 'kg';
    case ItemUnit.l:
      return 'L';
  }
}

InputDecoration _dialogInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontSize: 13),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    isDense: true,
  );
}

Widget _dialogField(String label, TextEditingController ctrl, {bool isNumber = false}) {
  return TextField(
    controller: ctrl,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: _dialogInputDecoration(label),
  );
}

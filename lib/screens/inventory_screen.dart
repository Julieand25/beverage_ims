import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/auth_provider.dart';
import '../app/inventory_provider.dart';
import '../app/models/inventory_item.dart';
import '../app/translations.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  void _showRestockDialog(BuildContext context, {InventoryItem? selectedItem}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return _RestockDialog(initialItem: selectedItem);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final provider = context.watch<InventoryProvider>();
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;
    final colors = Theme.of(context).extension<AppColors>()!;
    const pinkAccent = Color(0xFFFF7B89);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.inventoryTitle,
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                  icon: Icon(Icons.filter_list, color: colors.gray, size: 22),
                  onSelected: (v) {
                    switch (v) {
                      case '_all':
                        provider.setCategory(null);
                      case 'bahan':
                        provider.setCategory(ItemCategory.bahan);
                      case 'pembungkusan':
                        provider.setCategory(ItemCategory.pembungkusan);
                      case 'lain':
                        provider.setCategory(ItemCategory.lain);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem<String>(value: '_all', child: Text(t.all)),
                    PopupMenuItem<String>(value: 'bahan', child: Text(t.ingredients)),
                    PopupMenuItem<String>(value: 'pembungkusan', child: Text(t.packaging)),
                    PopupMenuItem<String>(value: 'lain', child: Text(t.others)),
                  ],
                ),
                const SizedBox(width: 12),
                if (isAdmin)
                GestureDetector(
                  onTap: () => _showAddItemDialog(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: pinkAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: TextField(
                onChanged: (v) => provider.setSearchQuery(v),
                decoration: InputDecoration(
                  hintText: t.searchItem ?? 'Cari bahan...',
                  hintStyle: TextStyle(fontSize: 14, color: colors.gray),
                  prefixIcon: Icon(Icons.search, size: 20, color: colors.gray),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              t.ingredients,
              style: TextStyle(fontSize: 13, color: colors.gray),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ClipRect(
              clipBehavior: Clip.hardEdge,
              child: provider.filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        t.emptyInventory,
                        style: TextStyle(color: colors.gray, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = provider.filteredItems[index];
                        return GestureDetector(
                          onTap: isAdmin ? () => _showRestockDialog(context, selectedItem: item) : null,
                          child: _InventoryCard(item: item),
                        );
                      },
                    ),
            ),
          ),
          ],
        ),
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
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final auth = context.read<AuthProvider>();
                if (auth.currentUser == null) return;
                await context.read<InventoryProvider>().addItem(
                      name: nameCtrl.text.trim(),
                      category: category,
                      unit: unit,
                      stock: double.tryParse(stockCtrl.text) ?? 0,
                      minStock: double.tryParse(minStockCtrl.text) ?? 0,
                      costPerUnit: double.tryParse(costCtrl.text) ?? 0,
                      userId: auth.currentUser!.id,
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

class _RestockDialog extends StatefulWidget {
  final InventoryItem? initialItem;
  const _RestockDialog({this.initialItem});

  @override
  State<_RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends State<_RestockDialog> {
  String? selectedItemId;
  late TextEditingController qtyCtrl;
  late TextEditingController costCtrl;
  late TextEditingController minStockCtrl;
  late TextEditingController dateCtrl;
  late TextEditingController noteCtrl;
  String selectedUnit = 'Kotak';

  @override
  void initState() {
    super.initState();
    final provider = context.read<InventoryProvider>();

    if (widget.initialItem != null) {
      selectedItemId = widget.initialItem!.id;
      qtyCtrl = TextEditingController(text: widget.initialItem!.stock.toStringAsFixed(0));
      costCtrl = TextEditingController(text: widget.initialItem!.costPerUnit.toStringAsFixed(2));
      minStockCtrl = TextEditingController(text: widget.initialItem!.minStock.toStringAsFixed(0));
      selectedUnit = _unitLabel(widget.initialItem!.unit);
    } else {
      selectedItemId = provider.items.isNotEmpty ? provider.items.first.id : null;
      qtyCtrl = TextEditingController(text: '10');
      costCtrl = TextEditingController(text: '7.80');
      minStockCtrl = TextEditingController(text: '0');
    }

    dateCtrl = TextEditingController(text: '16/07/2026');
    noteCtrl = TextEditingController(text: 'Dibeli dari Eco Shop');
  }

  @override
  void dispose() {
    qtyCtrl.dispose();
    costCtrl.dispose();
    minStockCtrl.dispose();
    dateCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final provider = context.watch<InventoryProvider>();
    final colors = Theme.of(context).extension<AppColors>()!;
    const primaryGreen = Color(0xFF5BA154);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: colors.card,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  t.addStock,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, color: colors.gray, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 18),

            Text(
              t.chooseIngredient,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.text),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colors.inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedItemId,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: colors.gray),
                  style: TextStyle(fontSize: 14, color: colors.text, fontWeight: FontWeight.w600),
                  items: provider.items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(item.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedItemId = val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              t.quantity,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.text),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.text),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      fillColor: colors.inputBg,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: colors.inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedUnit,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: colors.gray),
                        style: TextStyle(fontSize: 14, color: colors.text, fontWeight: FontWeight.w600),
                        items: <String>['Kotak', 'g', 'kg', 'ml', 'L', 'unit'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedUnit = val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Text(
              t.purchasePriceLabel,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.text),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: costCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.text),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                fillColor: colors.inputBg,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              t.minStock,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.text),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: minStockCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.text),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                fillColor: colors.inputBg,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              t.purchaseDate,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.text),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: dateCtrl,
              readOnly: true,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.text),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null) {
                  setState(() {
                    dateCtrl.text =
                        "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                  });
                }
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                fillColor: colors.inputBg,
                filled: true,
                suffixIcon: Icon(Icons.calendar_today_outlined, color: colors.gray, size: 20),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              t.noteOptional,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.text),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: noteCtrl,
              style: TextStyle(fontSize: 14, color: colors.text),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                fillColor: colors.inputBg,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                    if (selectedItemId != null) {
                      final addedQty = double.tryParse(qtyCtrl.text) ?? 0;
                      final cost = double.tryParse(costCtrl.text) ?? 0;
                      final minStock = double.tryParse(minStockCtrl.text);
                      if (addedQty > 0) {
                        final auth = context.read<AuthProvider>();
                        if (auth.currentUser != null) {
                          await provider.restockItem(
                            itemId: selectedItemId!,
                            addedQty: addedQty,
                            totalCost: addedQty * cost,
                            userId: auth.currentUser!.id,
                            minStock: minStock,
                            purchaseDate: dateCtrl.text,
                            note: noteCtrl.text,
                          );
                        }
                      }
                    }
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  t.save,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  const _InventoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    const softGreenBg = Color(0xFFE8F5E9);
    const textGreen = Color(0xFF4CAF50);
    const softOrangeBg = Color(0xFFFFF3E0);
    const textOrange = Color(0xFFFB8C00);

    final isLow = item.isLowStock;
    final statusBgColor = isLow ? softOrangeBg : softGreenBg;
    final statusTextColor = isLow ? textOrange : textGreen;
    final statusText = isLow ? t.lowStock : t.sufficient;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.stock.toStringAsFixed(0)} ${_unitLabel(item.unit)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Harga: RM${item.costPerUnit.toStringAsFixed(2)} / ${_unitLabel(item.unit)}',
                  style: TextStyle(fontSize: 11, color: colors.gray),
                ),
              ],
            ),
          ),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: colors.gray,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
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

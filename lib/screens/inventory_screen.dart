import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/inventory_provider.dart';
import '../app/models/inventory_item.dart';
import '../app/translations.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  // Open the "Tambah / Edit Stok" dialog matched to image_aceec4.png
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

    const backgroundColor = Color(0xFFF9F9F9);
    const pinkAccent = Color(0xFFFF7B89);
    const textDark = Color(0xFF2C3E50);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textDark, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          'Inventori Bahan',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Filter Icon + Add Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<ItemCategory?>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                  icon: provider.selectedCategory != null
                      ? const Icon(Icons.filter_list_alt, color: pinkAccent, size: 22)
                      : const Icon(Icons.filter_list, color: textDark, size: 22),
                  onSelected: (v) => provider.setCategory(v),
                  itemBuilder: (_) => const [
                    PopupMenuItem<ItemCategory?>(value: null, child: Text('Semua')),
                    PopupMenuItem<ItemCategory?>(value: ItemCategory.bahan, child: Text('Bahan')),
                    PopupMenuItem<ItemCategory?>(value: ItemCategory.pembungkusan, child: Text('Pembungkusan')),
                    PopupMenuItem<ItemCategory?>(value: ItemCategory.lain, child: Text('Lain-lain')),
                  ],
                ),
                const SizedBox(width: 12),
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

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: TextField(
                onChanged: (v) => provider.setSearchQuery(v),
                decoration: InputDecoration(
                  hintText: t.searchItem ?? 'Cari bahan...',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          // List of Ingredients / Stock Items
          Expanded(
            child: ClipRect(
              clipBehavior: Clip.hardEdge,
              child: provider.filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'Tiada barang dijumpai',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = provider.filteredItems[index];
                        return GestureDetector(
                          onTap: () => _showRestockDialog(context, selectedItem: item),
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
}

// ---------------------------------------------------------------------------
// RESTOCK & EDIT DIALOG SCREEN (Matching image_aceec4.png)
// ---------------------------------------------------------------------------
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
      selectedUnit = _unitLabel(widget.initialItem!.unit);
    } else {
      selectedItemId = provider.items.isNotEmpty ? provider.items.first.id : null;
      qtyCtrl = TextEditingController(text: '10');
      costCtrl = TextEditingController(text: '7.80');
    }

    dateCtrl = TextEditingController(text: '16/07/2026');
    noteCtrl = TextEditingController(text: 'Dibeli dari Eco Shop');
  }

  @override
  void dispose() {
    qtyCtrl.dispose();
    costCtrl.dispose();
    dateCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    const textDark = Color(0xFF2C3E50);
    const primaryGreen = Color(0xFF5BA154);
    const borderColor = Color(0xFFE2E8F0);
    const inputBgColor = Color(0xFFFAFAFA);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header with Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Text(
                  'Tambah Stok',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Colors.grey, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Field 1: Pilih Bahan Dropdown
            const Text(
              'Pilih Bahan',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: inputBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedItemId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  style: const TextStyle(fontSize: 14, color: textDark, fontWeight: FontWeight.w600),
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

            // Field 2: Kuantiti + Unit Dropdown
            const Text(
              'Kuantiti',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      fillColor: inputBgColor,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: borderColor),
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
                      color: inputBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedUnit,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                        style: const TextStyle(fontSize: 14, color: textDark, fontWeight: FontWeight.w600),
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

            // Field 3: Harga Beli Seunit (RM)
            const Text(
              'Harga Beli Seunit (RM)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: costCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                fillColor: inputBgColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: borderColor),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Field 4: Tarikh Beli
            const Text(
              'Tarikh Beli',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: dateCtrl,
              readOnly: true,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark),
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
                fillColor: inputBgColor,
                filled: true,
                suffixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: borderColor),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Field 5: Nota (pilihan)
            const Text(
              'Nota (pilihan)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: noteCtrl,
              style: const TextStyle(fontSize: 14, color: textDark),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                fillColor: inputBgColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: borderColor),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Save Button (Simpan)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedItemId != null) {
                    final addedQty = double.tryParse(qtyCtrl.text) ?? 0;
                    final cost = double.tryParse(costCtrl.text) ?? 0;
                    if (addedQty > 0) {
                      provider.restockItem(
                        itemId: selectedItemId!,
                        addedQty: addedQty,
                        totalCost: addedQty * cost,
                      );
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
                child: const Text(
                  'Simpan',
                  style: TextStyle(
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



// ---------------------------------------------------------------------------
// Inventory Card (Matching image_ad4254.png)
// ---------------------------------------------------------------------------
class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  const _InventoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF2C3E50);
    const softGreenBg = Color(0xFFE8F5E9);
    const textGreen = Color(0xFF4CAF50);
    const softOrangeBg = Color(0xFFFFF3E0);
    const textOrange = Color(0xFFFB8C00);

    final isLow = item.isLowStock;
    final statusBgColor = isLow ? softOrangeBg : softGreenBg;
    final statusTextColor = isLow ? textOrange : textGreen;
    final statusText = isLow ? 'Rendah' : 'Cukup';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Emoji / Icon Graphic Box
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _itemEmoji(item.name),
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(width: 12),

          // Name & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.stock.toStringAsFixed(0)} ${_unitLabel(item.unit)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Harga: RM${item.costPerUnit.toStringAsFixed(2)} / ${_unitLabel(item.unit)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Status Badge + Chevron Arrow Right
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
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Returns emoji based on item name for custom visual presentation
  String _itemEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('susu')) return '🥛';
    if (lower.contains('matcha')) return '🍵';
    if (lower.contains('pearl')) return '🧋';
    if (lower.contains('gula') || lower.contains('sirap')) return '🍾';
    if (lower.contains('cawan') || lower.contains('cup')) return '🥤';
    if (lower.contains('straw')) return '🥤';
    return '📦';
  }
}

// Helpers
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
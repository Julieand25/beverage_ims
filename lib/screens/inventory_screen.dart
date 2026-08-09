import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/auth_provider.dart';
import '../app/inventory_provider.dart';
import '../app/models/inventory_item.dart';
import '../app/translations.dart';

class InventoryScreen extends StatefulWidget {
  final String? focusItemId;

  const InventoryScreen({super.key, this.focusItemId});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _scrollController = ScrollController();
  bool _didFocusItem = false;

  void _showRestockDialog({InventoryItem? selectedItem}) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return _RestockDialog(initialItem: selectedItem);
      },
    );
  }

  void _scrollToItem(String itemId) {
    final provider = context.read<InventoryProvider>();
    final index = provider.filteredItems.indexWhere((i) => i.id == itemId);
    if (index == -1) return;
    final offset = index * 180.0;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _tryFocusItem() {
    if (_didFocusItem) return;
    final itemId = widget.focusItemId;
    if (itemId == null) return;
    _didFocusItem = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToItem(itemId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showEditItemDialog(BuildContext context, InventoryItem item) {
    final t = Translations.of(context);
    final nameCtrl = TextEditingController(text: item.name);
    final minStockCtrl = TextEditingController(text: item.minStock.toStringAsFixed(0));
    final costCtrl = TextEditingController(text: item.costPerUnit.toStringAsFixed(2));
    var category = item.category;
    var unit = item.unit;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(t.edit, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                await context.read<InventoryProvider>().updateItem(
                  id: item.id,
                  name: nameCtrl.text.trim(),
                  category: category,
                  unit: unit,
                  minStock: double.tryParse(minStockCtrl.text) ?? item.minStock,
                  costPerUnit: double.tryParse(costCtrl.text) ?? item.costPerUnit,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(t.save, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustStockDialog(BuildContext context, InventoryItem item) {
    final t = Translations.of(context);
    final qtyCtrl = TextEditingController(text: '1');
    final noteCtrl = TextEditingController();
    final colors = Theme.of(context).extension<AppColors>()!;
    var isAdd = true;
    var selectedUnit = _unitLabel(item.unit);
    const primaryGreen = Color(0xFF5BA154);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Text(
                '${item.name}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.text),
              ),
              const Spacer(),
              Text(
                '${item.stock.toStringAsFixed(0)} ${_unitLabel(item.unit)}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.gray),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => isAdd = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isAdd ? primaryGreen.withAlpha(30) : colors.gray.withAlpha(15),
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                            border: Border.all(color: isAdd ? primaryGreen : Colors.transparent),
                          ),
                          child: Center(
                            child: Text('+ ${t.addStock}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isAdd ? primaryGreen : colors.gray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => isAdd = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isAdd ? const Color(0xFFD32F2F).withAlpha(30) : colors.gray.withAlpha(15),
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                            border: Border.all(color: !isAdd ? const Color(0xFFD32F2F) : Colors.transparent),
                          ),
                          child: Center(
                            child: Text('- ${t.delete}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: !isAdd ? const Color(0xFFD32F2F) : colors.gray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        decoration: InputDecoration(
                          labelText: t.quantity,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedUnit,
                            isDense: true,
                            isExpanded: true,
                            style: TextStyle(fontSize: 14, color: colors.text),
                            items: ['g', 'kg', 'ml', 'L', 'unit']
                              .where((u) {
                                if (u == 'g' || u == 'kg') return item.unit == ItemUnit.g || item.unit == ItemUnit.kg;
                                if (u == 'ml' || u == 'L') return item.unit == ItemUnit.ml || item.unit == ItemUnit.l;
                                return u == 'unit';
                              })
                              .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                              .toList(),
                            onChanged: (v) => setDialogState(() => selectedUnit = v!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    labelText: t.noteOptional,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              onPressed: () async {
                final qty = double.tryParse(qtyCtrl.text) ?? 0;
                if (qty <= 0) return;
                final changeQty = isAdd
                    ? _toBaseQuantity(qty, selectedUnit, item.unit)
                    : -_toBaseQuantity(qty, selectedUnit, item.unit);
                final auth = context.read<AuthProvider>();
                if (auth.currentUser == null) return;
                await context.read<InventoryProvider>().adjustStock(
                  itemId: item.id,
                  changeQty: changeQty,
                  userId: auth.currentUser!.id,
                  costPerUnit: item.costPerUnit,
                  note: noteCtrl.text.isNotEmpty ? noteCtrl.text : (isAdd ? 'Manual add' : 'Manual deduction'),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(t.save, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, InventoryItem item) {
    final t = Translations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t.delete),
        content: FutureBuilder<int>(
          future: context.read<InventoryProvider>().getRecipeUsageCount(item.id),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            if (count > 0) {
              return Text(
                t.isMs
                    ? '${item.name} digunakan dalam $count resipi. Tidak boleh dipadam.'
                    : '${item.name} is used in $count recipe(s). Cannot delete.',
              );
            }
            return Text('${t.deleteConfirm} "${item.name}"?');
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          FutureBuilder<int>(
            future: context.read<InventoryProvider>().getRecipeUsageCount(item.id),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              if (count > 0) {
                return TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('OK'),
                );
              }
              return TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<InventoryProvider>().deleteItem(item.id);
                },
                child: Text(t.delete, style: const TextStyle(color: Colors.red)),
              );
            },
          ),
        ],
      ),
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

    if (!_didFocusItem && widget.focusItemId != null && !provider.isLoading) {
      _tryFocusItem();
    }

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
                  hintText: t.searchItem,
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
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = provider.filteredItems[index];
                          return GestureDetector(
                            key: ValueKey('item_${item.id}'),
                            onTap: isAdmin ? () => _showRestockDialog(selectedItem: item) : null,
                            child: _InventoryCard(
                              item: item,
                              isAdmin: isAdmin,
                              onEdit: () => _showEditItemDialog(context, item),
                              onAdjust: () => _showAdjustStockDialog(context, item),
                              onDelete: () => _confirmDeleteItem(context, item),
                            ),
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
  String selectedUnit = 'g';

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
    final selectedItem = selectedItemId != null
        ? provider.items.firstWhere((i) => i.id == selectedItemId)
        : null;
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
                      if (val != null) {
                        final item = provider.items.firstWhere((i) => i.id == val);
                        selectedUnit = _unitLabel(item.unit);
                      }
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
                        items: <String>['g', 'kg', 'ml', 'L', 'unit'].map((String value) {
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
              t.totalPurchaseAmount,
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
              selectedItem != null ? '${t.minStock} (${_unitLabel(selectedItem.unit)})' : t.minStock,
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
                      final enteredQty = double.tryParse(qtyCtrl.text) ?? 0;
                      final totalCost = double.tryParse(costCtrl.text) ?? 0;
                      final enteredMinStock = double.tryParse(minStockCtrl.text);
                      final minStock = enteredMinStock != null && selectedItem != null
                          ? _toBaseQuantity(enteredMinStock, selectedUnit, selectedItem.unit)
                          : enteredMinStock;
                      if (enteredQty != 0) {
                        final item = provider.items.firstWhere((i) => i.id == selectedItemId);
                        final addedQty = _toBaseQuantity(enteredQty, selectedUnit, item.unit);
                        final auth = context.read<AuthProvider>();
                        if (auth.currentUser != null) {
                          await provider.restockItem(
                            itemId: selectedItemId!,
                            addedQty: addedQty,
                            totalCost: totalCost,
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
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onAdjust;
  final VoidCallback? onDelete;

  const _InventoryCard({
    required this.item,
    this.isAdmin = false,
    this.onEdit,
    this.onAdjust,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    const softGreenBg = Color(0xFFE8F5E9);
    const textGreen = Color(0xFF4CAF50);
    const softOrangeBg = Color(0xFFFFF3E0);
    const textOrange = Color(0xFFFB8C00);
    const softRedBg = Color(0xFFFFEBEE);
    const textRed = Color(0xFFD32F2F);

    final isLow = item.isLowStock;
    final isOut = item.stock <= 0;
    final statusBgColor = isOut ? softRedBg : (isLow ? softOrangeBg : softGreenBg);
    final statusTextColor = isOut ? textRed : (isLow ? textOrange : textGreen);
    final statusText = isOut ? t.nearlyOut : (isLow ? t.lowStock : t.sufficient);

    final ratio = item.minStock > 0 ? (item.stock / item.minStock).clamp(0.0, 1.5) : 1.5;
    final barColor = isOut ? textRed : (isLow ? textOrange : textGreen);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colors.text,
                  ),
                ),
              ),
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
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${item.stock.toStringAsFixed(0)} ${_unitLabel(item.unit)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.text,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'RM ${item.stockValue.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12, color: colors.gray),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: colors.gray.withAlpha(40),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${t.minStock}: ${item.minStock.toStringAsFixed(0)} ${_unitLabel(item.unit)}',
                style: TextStyle(fontSize: 11, color: colors.gray),
              ),
              Text(
                'RM${item.costPerUnit.toStringAsFixed(2)} / ${_unitLabel(item.unit)}',
                style: TextStyle(fontSize: 11, color: colors.gray),
              ),
            ],
          ),
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    color: const Color(0xFF5BA154),
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 4),
                  _ActionButton(
                    icon: Icons.add_circle_outline,
                    color: const Color(0xFF1976D2),
                    onTap: onAdjust,
                  ),
                  const SizedBox(width: 4),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    color: const Color(0xFFD32F2F),
                    onTap: onDelete,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
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

double _toBaseQuantity(double qty, String fromUnit, ItemUnit baseUnit) {
  const massUnits = {'g': 1.0, 'kg': 1000.0};
  const volUnits = {'ml': 1.0, 'L': 1000.0};
  final baseLabel = _unitLabel(baseUnit);

  if (massUnits.containsKey(fromUnit) && massUnits.containsKey(baseLabel)) {
    return qty * massUnits[fromUnit]! / massUnits[baseLabel]!;
  }
  if (volUnits.containsKey(fromUnit) && volUnits.containsKey(baseLabel)) {
    return qty * volUnits[fromUnit]! / volUnits[baseLabel]!;
  }
  return qty;
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

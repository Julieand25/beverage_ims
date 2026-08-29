import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/auth_provider.dart';
import '../app/inventory_provider.dart';
import '../app/models/inventory_item.dart';
import '../app/translations.dart';
import '../app/widgets/emoji_picker.dart';

class InventoryScreen extends StatefulWidget {
  final String? focusItemId;

  const InventoryScreen({super.key, this.focusItemId});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _scrollController = ScrollController();
  bool _didFocusItem = false;


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
    var category = item.category;
    var unit = item.unit;
    var emoji = item.emoji.isNotEmpty ? item.emoji : _defaultEmoji(category);
    const primaryGreen = Color(0xFF5BA154);
    final colors = Theme.of(context).extension<AppColors>()!;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(t.editItem, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                _dialogField(t.itemName, nameCtrl, labelColor: colors.text),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      t.chooseEmoji,
                      style: TextStyle(fontSize: 12, color: colors.gray),
                    ),
                    const SizedBox(width: 8),
                    Text(emoji, style: const TextStyle(fontSize: 18)),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 8),
                EmojiPicker(
                  selected: emoji,
                  size: 30,
                  onChanged: (v) => setDialogState(() => emoji = v),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: _dialogInputDecoration(t.category, colors.text),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ItemCategory>(
                      value: category,
                      isDense: true,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(value: ItemCategory.bahan, child: Text('Ingredients', style: TextStyle(color: colors.text))),
                        DropdownMenuItem(value: ItemCategory.pembungkusan, child: Text('Packaging', style: TextStyle(color: colors.text))),
                        DropdownMenuItem(value: ItemCategory.lain, child: Text('Others', style: TextStyle(color: colors.text))),
                      ],
                      onChanged: (v) => setDialogState(() {
                        category = v!;
                        if (emoji == _defaultEmoji(ItemCategory.bahan) ||
                            emoji == _defaultEmoji(ItemCategory.pembungkusan) ||
                            emoji == _defaultEmoji(ItemCategory.lain)) {
                          emoji = _defaultEmoji(v);
                        }
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: _dialogInputDecoration(t.unit, colors.text),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ItemUnit>(
                      value: unit,
                      isDense: true,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(value: ItemUnit.g, child: Text('g', style: TextStyle(color: colors.text))),
                        DropdownMenuItem(value: ItemUnit.ml, child: Text('ml', style: TextStyle(color: colors.text))),
                        DropdownMenuItem(value: ItemUnit.unit, child: Text('unit', style: TextStyle(color: colors.text))),
                        DropdownMenuItem(value: ItemUnit.kg, child: Text('kg', style: TextStyle(color: colors.text))),
                        DropdownMenuItem(value: ItemUnit.l, child: Text('L', style: TextStyle(color: colors.text))),
                      ],
                      onChanged: (v) => setDialogState(() => unit = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _dialogField('${t.minStock} (${_unitLabel(item.unit)})', minStockCtrl, isNumber: true, labelColor: colors.text),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final auth = context.read<AuthProvider>();
                if (auth.currentUser == null) return;
                await context.read<InventoryProvider>().updateItem(
                  id: item.id,
                  userId: auth.currentUser!.id,
                  userName: auth.currentUser!.name,
                  name: nameCtrl.text.trim(),
                  category: category,
                  unit: unit,
                  minStock: double.tryParse(minStockCtrl.text) ?? item.minStock,
                  emoji: emoji,
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
    final itemCountCtrl = TextEditingController(text: '1');
    final perItemSizeCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final colors = Theme.of(context).extension<AppColors>()!;
    var isAdd = true;
    var isTotalPrice = true;
    var sizeUnit = item.unit;
    var currentStep = 0;
    const primaryGreen = Color(0xFF5BA154);
    const redColor = Color(0xFFD32F2F);

    double calcCostPerUnit() {
      final count = double.tryParse(itemCountCtrl.text) ?? 1;
      final rawSize = double.tryParse(perItemSizeCtrl.text) ?? 0;
      final sizeInBase = _toBaseQuantity(rawSize, _unitLabel(sizeUnit), item.unit);
      final totalQty = count * sizeInBase;
      final price = double.tryParse(priceCtrl.text) ?? 0;
      if (isTotalPrice) return totalQty > 0 ? price / totalQty : 0.0;
      return sizeInBase > 0 ? price / sizeInBase : 0.0;
    }

    double calcChangeQty() {
      final count = double.tryParse(itemCountCtrl.text) ?? 0;
      final rawSize = double.tryParse(perItemSizeCtrl.text) ?? 0;
      final sizeInBase = _toBaseQuantity(rawSize, _unitLabel(sizeUnit), item.unit);
      final baseQty = count * sizeInBase;
      return isAdd ? baseQty : -baseQty;
    }

    bool canProceed() {
      if (currentStep == 1) {
        final count = double.tryParse(itemCountCtrl.text) ?? 0;
        final size = double.tryParse(perItemSizeCtrl.text) ?? 0;
        final price = double.tryParse(priceCtrl.text) ?? 0;
        return count > 0 && size > 0 && price > 0;
      }
      return true;
    }

    void doSave() async {
      var changeQty = calcChangeQty();
      if (changeQty == 0) return;

      final count = itemCountCtrl.text;
      final size = perItemSizeCtrl.text;
      final suLabel = _unitLabel(sizeUnit);
      final qtyText = '$count × $size$suLabel';

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(t.confirmAdjustTitle),
          content: Text(isAdd
              ? t.confirmAdjustAdd(qtyText, item.name)
              : t.confirmAdjustRemove(qtyText, item.name)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.save, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final auth = context.read<AuthProvider>();
      if (auth.currentUser == null) return;

      final afterStock = item.stock + changeQty;
      if (!isAdd && afterStock < 0) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(t.stockClampedTitle),
            content: Text(t.stockClampedBody(item.name)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(t.save, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        changeQty = -item.stock;
      }

      final cost = calcCostPerUnit();
      await context.read<InventoryProvider>().adjustStock(
        itemId: item.id,
        changeQty: changeQty,
        userId: auth.currentUser!.id,
        userName: auth.currentUser!.name,
        costPerUnit: cost > 0 ? cost : item.costPerUnit,
        note: noteCtrl.text.isNotEmpty ? noteCtrl.text : (isAdd ? 'Manual add' : 'Manual deduction'),
      );
      Navigator.of(context, rootNavigator: true).pop();
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final changeQty = calcChangeQty();
          final newCostPerUnit = calcCostPerUnit();
          final afterStock = item.stock + changeQty;
          final currentValue = item.stock * item.costPerUnit;
          final afterValue = afterStock * (newCostPerUnit > 0 ? newCostPerUnit : item.costPerUnit);

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${t.manageStock} - ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextSpan(text: '${item.emoji.isNotEmpty ? '${item.emoji} ' : ''}${item.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                ],
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: _buildAdjustStep(
                currentStep,
                t,
                itemCountCtrl,
                perItemSizeCtrl,
                priceCtrl,
                noteCtrl,
                item,
                isAdd,
                isTotalPrice,
                sizeUnit,
                primaryGreen,
                redColor,
                colors,
                setDialogState,
                (v) => isAdd = v,
                (v) => isTotalPrice = v,
                (v) => sizeUnit = v,
                changeQty,
                afterStock,
                currentValue,
                afterValue,
              ),
            ),
            actions: [
              if (currentStep > 0)
                TextButton(
                  onPressed: () => setDialogState(() => currentStep--),
                  child: Text(t.back),
                )
              else
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(t.cancel),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  disabledBackgroundColor: primaryGreen.withAlpha(100),
                ),
                onPressed: canProceed()
                    ? () {
                        if (currentStep < 2) {
                          setDialogState(() => currentStep++);
                        } else {
                          doSave();
                        }
                      }
                    : null,
                child: Text(currentStep < 2 ? t.next : t.save,
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, InventoryItem item) {
    final t = Translations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(t.deleteItemConfirm(item.name), style: TextStyle(color: colors.text)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final auth = context.read<AuthProvider>();
              if (auth.currentUser != null) {
                context.read<InventoryProvider>().deleteItem(
                  id: item.id,
                  userId: auth.currentUser!.id,
                  userName: auth.currentUser!.name,
                );
              }
            },
            child: Text(t.delete, style: const TextStyle(color: Colors.red)),
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
              'Items',
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
                          return _InventoryCard(
                            key: ValueKey('item_${item.id}'),
                            item: item,
                            isAdmin: isAdmin,
                            onEdit: () => _showEditItemDialog(context, item),
                            onAdjust: () => _showAdjustStockDialog(context, item),
                            onDelete: () => _confirmDeleteItem(context, item),
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
    final minStockCtrl = TextEditingController();
    final itemCountCtrl = TextEditingController(text: '1');
    final perItemSizeCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();
    var category = ItemCategory.bahan;
    var unit = ItemUnit.g;
    var emoji = _defaultEmoji(category);
    var isTotalPrice = true;
    var currentStep = 0;
    const primaryGreen = Color(0xFF5BA154);
    final colors = Theme.of(context).extension<AppColors>()!;

    bool canProceed() {
      if (currentStep == 0) return nameCtrl.text.trim().isNotEmpty;
      if (currentStep == 1) {
        final p = double.tryParse(priceCtrl.text);
        return p != null && p > 0;
      }
      if (currentStep == 2) {
        final m = double.tryParse(minStockCtrl.text);
        return m != null && m >= 0;
      }
      return true;
    }

    void doSave() async {
      if (nameCtrl.text.trim().isEmpty) return;
      final auth = context.read<AuthProvider>();
      if (auth.currentUser == null) return;
      final itemCount = double.tryParse(itemCountCtrl.text) ?? 1;
      final perItemSize = double.tryParse(perItemSizeCtrl.text) ?? 0;
      final price = double.tryParse(priceCtrl.text) ?? 0;
      final totalQty = itemCount * perItemSize;
      final costPerUnit = isTotalPrice
          ? (totalQty > 0 ? price / totalQty : 0.0)
          : (perItemSize > 0 ? price / perItemSize : 0.0);
      await context.read<InventoryProvider>().addItem(
            name: nameCtrl.text.trim(),
            category: category,
            unit: unit,
            stock: 0,
            minStock: double.tryParse(minStockCtrl.text) ?? 0,
            costPerUnit: costPerUnit,
            userId: auth.currentUser!.id,
            userName: auth.currentUser!.name,
            emoji: emoji,
          );
      Navigator.of(context, rootNavigator: true).pop();
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(t.addNewItem, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: _buildStep(
              currentStep,
              t,
              nameCtrl,
              minStockCtrl,
              itemCountCtrl,
              perItemSizeCtrl,
              priceCtrl,
              category,
              unit,
              emoji,
              isTotalPrice,
              primaryGreen,
              colors,
              setDialogState,
              (v) => category = v,
              (v) => unit = v,
              (v) => emoji = v,
              (v) => isTotalPrice = v,
            ),
          ),
          actions: [
            if (currentStep > 0)
              TextButton(
                onPressed: () => setDialogState(() => currentStep--),
                child: Text(t.back),
              )
            else
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(t.cancel),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                disabledBackgroundColor: primaryGreen.withAlpha(100),
              ),
              onPressed: canProceed()
                  ? () {
                      if (currentStep < 2) {
                        setDialogState(() => currentStep++);
                      } else {
                        doSave();
                      }
                    }
                  : null,
              child: Text(currentStep < 2 ? t.next : t.save,
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    int step,
    Translations t,
    TextEditingController nameCtrl,
    TextEditingController minStockCtrl,
    TextEditingController itemCountCtrl,
    TextEditingController perItemSizeCtrl,
    TextEditingController priceCtrl,
    ItemCategory category,
    ItemUnit unit,
    String emoji,
    bool isTotalPrice,
    Color accentColor,
    AppColors colors,
    void Function(VoidCallback) setDialogState,
    void Function(ItemCategory) setCategory,
    void Function(ItemUnit) setUnit,
    void Function(String) setEmoji,
    void Function(bool) setIsTotalPrice,
  ) {
    final unitLabel = _unitLabel(unit);
    switch (step) {
      case 0:
        return ListView(
          shrinkWrap: true,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: _dialogInputDecoration(t.itemName, colors.text),
              onChanged: (_) => setDialogState(() {}),
            ),
            const SizedBox(height: 12),
            Text(
              t.chooseEmoji,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.text),
            ),
            const SizedBox(height: 8),
            EmojiPicker(
              selected: emoji,
              size: 30,
              onChanged: (v) => setDialogState(() => setEmoji(v)),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: _dialogInputDecoration(t.category, colors.text),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ItemCategory>(
                  value: category,
                  isDense: true,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: ItemCategory.bahan, child: Text('Ingredients', style: TextStyle(color: colors.text))),
                    DropdownMenuItem(value: ItemCategory.pembungkusan, child: Text('Packaging', style: TextStyle(color: colors.text))),
                    DropdownMenuItem(value: ItemCategory.lain, child: Text('Others', style: TextStyle(color: colors.text))),
                  ],
                  onChanged: (v) => setDialogState(() {
                    setCategory(v!);
                    setEmoji(_defaultEmoji(v));
                  }),
                ),
              ),
            ),
          ],
        );
      case 1:
        return ListView(
          shrinkWrap: true,
          children: [
            _dialogField(t.itemsPerPack, itemCountCtrl, isNumber: true, labelColor: colors.text),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: perItemSizeCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.text),
                    decoration: _dialogInputDecoration('${t.qtyPerItem} ($unitLabel)', colors.text),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: InputDecorator(
                    decoration: _dialogInputDecoration('', colors.text),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ItemUnit>(
                        value: unit,
                        isDense: true,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(value: ItemUnit.g, child: Text('g', style: TextStyle(color: colors.text))),
                          DropdownMenuItem(value: ItemUnit.ml, child: Text('ml', style: TextStyle(color: colors.text))),
                          DropdownMenuItem(value: ItemUnit.unit, child: Text('unit', style: TextStyle(color: colors.text))),
                          DropdownMenuItem(value: ItemUnit.kg, child: Text('kg', style: TextStyle(color: colors.text))),
                          DropdownMenuItem(value: ItemUnit.l, child: Text('L', style: TextStyle(color: colors.text))),
                        ],
                        onChanged: (v) => setDialogState(() => setUnit(v!)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setDialogState(() => setIsTotalPrice(true)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isTotalPrice ? accentColor.withAlpha(30) : Colors.grey.withAlpha(15),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                        border: Border.all(color: isTotalPrice ? accentColor : Colors.transparent),
                      ),
                      child: Center(
                        child: Text(t.totalPrice,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                              color: isTotalPrice ? accentColor : Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setDialogState(() => setIsTotalPrice(false)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !isTotalPrice ? accentColor.withAlpha(30) : Colors.grey.withAlpha(15),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                        border: Border.all(color: !isTotalPrice ? accentColor : Colors.transparent),
                      ),
                      child: Center(
                        child: Text(t.pricePerItem,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                              color: !isTotalPrice ? accentColor : Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.text),
              decoration: _dialogInputDecoration(isTotalPrice ? t.totalPaidLabel : t.priceEachLabel, colors.text),
              onChanged: (_) => setDialogState(() {}),
            ),
          ],
        );
      case 2:
        return ListView(
          shrinkWrap: true,
          children: [
            TextField(
              controller: minStockCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.text),
              decoration: _dialogInputDecoration('${t.minStock} ($unitLabel)', colors.text),
              onChanged: (_) => setDialogState(() {}),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAdjustStep(
    int step,
    Translations t,
    TextEditingController itemCountCtrl,
    TextEditingController perItemSizeCtrl,
    TextEditingController priceCtrl,
    TextEditingController noteCtrl,
    InventoryItem item,
    bool isAdd,
    bool isTotalPrice,
    ItemUnit sizeUnit,
    Color primaryGreen,
    Color redColor,
    AppColors colors,
    void Function(VoidCallback) setDialogState,
    void Function(bool) setIsAdd,
    void Function(bool) setIsTotalPrice,
    void Function(ItemUnit) setSizeUnit,
    double changeQty,
    double afterStock,
    double currentValue,
    double afterValue,
  ) {

    switch (step) {
      case 0:
        return ListView(
          shrinkWrap: true,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setDialogState(() => setIsAdd(true)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isAdd ? primaryGreen.withAlpha(30) : colors.gray.withAlpha(15),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                        border: Border.all(color: isAdd ? primaryGreen : Colors.transparent),
                      ),
                      child: Center(
                        child: Text('+ ${t.addStock}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                              color: isAdd ? primaryGreen : colors.gray),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setDialogState(() => setIsAdd(false)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !isAdd ? redColor.withAlpha(30) : colors.gray.withAlpha(15),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                        border: Border.all(color: !isAdd ? redColor : Colors.transparent),
                      ),
                      child: Center(
                        child: Text('- ${t.removeStock}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                              color: !isAdd ? redColor : colors.gray),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case 1:
        return ListView(
          shrinkWrap: true,
          children: [
            TextField(
              controller: itemCountCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.text),
              decoration: _dialogInputDecoration(t.itemsPerPack, colors.text),
              onChanged: (_) => setDialogState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: perItemSizeCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.text),
                    decoration: _dialogInputDecoration(t.qtyPerItem, colors.text),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: InputDecorator(
                    decoration: _dialogInputDecoration('', colors.text),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ItemUnit>(
                        value: sizeUnit,
                        isDense: true,
                        isExpanded: true,
                        items: [ItemUnit.g, ItemUnit.kg, ItemUnit.ml, ItemUnit.l, ItemUnit.unit]
                          .where((u) {
                            if (u == ItemUnit.g || u == ItemUnit.kg) return item.unit == ItemUnit.g || item.unit == ItemUnit.kg;
                            if (u == ItemUnit.ml || u == ItemUnit.l) return item.unit == ItemUnit.ml || item.unit == ItemUnit.l;
                            return u == ItemUnit.unit;
                          })
                          .map((u) => DropdownMenuItem(value: u, child: Text(_unitLabel(u), style: TextStyle(color: colors.text))))
                          .toList(),
                        onChanged: (v) => setDialogState(() => setSizeUnit(v!)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setDialogState(() => setIsTotalPrice(true)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isTotalPrice ? primaryGreen.withAlpha(30) : colors.gray.withAlpha(15),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                        border: Border.all(color: isTotalPrice ? primaryGreen : Colors.transparent),
                      ),
                      child: Center(
                        child: Text(t.totalPrice,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                              color: isTotalPrice ? primaryGreen : colors.gray),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setDialogState(() => setIsTotalPrice(false)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !isTotalPrice ? primaryGreen.withAlpha(30) : colors.gray.withAlpha(15),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                        border: Border.all(color: !isTotalPrice ? primaryGreen : Colors.transparent),
                      ),
                      child: Center(
                        child: Text(t.pricePerItem,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                              color: !isTotalPrice ? primaryGreen : colors.gray),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.text),
              decoration: _dialogInputDecoration(isTotalPrice ? t.totalPaidLabel : t.priceEachLabel, colors.text),
              onChanged: (_) => setDialogState(() {}),
            ),

          ],
        );
      case 2:
        return ListView(
          shrinkWrap: true,
          children: [
            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(
                labelText: t.noteOptional,
                labelStyle: TextStyle(fontSize: 13, color: colors.text),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
              maxLines: 2,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onAdjust;
  final VoidCallback? onDelete;

  const _InventoryCard({
    super.key,
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

    final isNearlyOut = item.isNearlyOut;
    final isLow = item.isLowStock && !item.isNearlyOut;
    final statusBgColor = isNearlyOut ? softRedBg : (isLow ? softOrangeBg : softGreenBg);
    final statusTextColor = isNearlyOut ? textRed : (isLow ? textOrange : textGreen);
    final statusText = isNearlyOut ? t.nearlyOut : (isLow ? t.lowStock : t.sufficient);

    final ratio = item.minStock > 0 ? (item.stock / item.minStock).clamp(0.0, 1.5) : 1.5;
    final barColor = isNearlyOut ? textRed : (isLow ? textOrange : textGreen);

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
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.emoji.isNotEmpty ? item.emoji : _defaultEmoji(item.category),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 10),
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

String _defaultEmoji(ItemCategory category) {
  switch (category) {
    case ItemCategory.bahan:
      return '🍚';
    case ItemCategory.pembungkusan:
      return '🥡';
    case ItemCategory.lain:
      return '📦';
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

InputDecoration _dialogInputDecoration(String label, Color labelColor) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(fontSize: 13, color: labelColor),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    isDense: true,
  );
}

Widget _dialogField(
  String label,
  TextEditingController ctrl, {
  bool isNumber = false,
  required Color labelColor,
}) {
  return TextField(
    controller: ctrl,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: _dialogInputDecoration(label, labelColor),
  );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/auth_provider.dart';
import '../app/inventory_provider.dart';
import '../app/models/inventory_item.dart';
import '../app/models/recipe.dart';
import '../app/recipe_provider.dart';
import '../app/sales_provider.dart';
import '../app/translations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showRecordSaleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final recipes = context.read<RecipeProvider>().recipes;
        return _RecordSaleModal(recipes: recipes);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    final sales = context.watch<SalesProvider>();
    final inventory = context.watch<InventoryProvider>();
    const primaryGreen = Color(0xFF5BA154);
    const pinkAccent = Color(0xFFE27387);

    // Compute inventory value
    double inventoryValue = 0;
    for (final item in inventory.items) {
      inventoryValue += item.stockValue;
    }

    // Get low stock items (top 3)
    final lowStockItems = inventory.items.where((i) => i.isLowStock).take(3).toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.dashboard,
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            t.greeting,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.greetingSubtitle,
                        style: TextStyle(fontSize: 13, color: colors.gray),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage('assets/character.png'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3.0,
                children: [
                  _StatCard(
                    icon: Icons.receipt_long,
                    iconColor: primaryGreen,
                    bgColor: colors.subtleGreen,
                    title: t.salesToday,
                    value: 'RM ${sales.todaySales.toStringAsFixed(2)}',
                    valueColor: primaryGreen,
                  ),
                  _StatCard(
                    icon: Icons.monetization_on_outlined,
                    iconColor: pinkAccent,
                    bgColor: colors.subtlePurple,
                    title: t.grossProfit,
                    value: 'RM ${sales.todayProfit.toStringAsFixed(2)}',
                    valueColor: pinkAccent,
                  ),
                  _StatCard(
                    icon: Icons.local_cafe_outlined,
                    iconColor: const Color(0xFF8E44AD),
                    bgColor: colors.subtlePurple,
                    title: t.cupsSold,
                    value: '${sales.todayCups} ${t.cupsUnit}',
                    valueColor: colors.text,
                  ),
                  _StatCard(
                    icon: Icons.inventory_2_outlined,
                    iconColor: Colors.blue,
                    bgColor: colors.subtleBlue,
                    title: t.inventoryValue,
                    value: 'RM ${inventoryValue.toStringAsFixed(2)}',
                    valueColor: Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t.stockStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/inventori'),
                          child: Text(
                            t.viewAll,
                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    if (lowStockItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          t.allStockSufficient,
                          style: TextStyle(fontSize: 13, color: colors.gray),
                        ),
                      )
                    else
                      ...lowStockItems.map((item) {
                        final unitLabel = _unitLabel(item.unit);
                        return Column(
                          children: [
                            _StockItemRow(
                              name: item.name,
                              qty: '${item.stock.toStringAsFixed(0)} $unitLabel',
                              statusText: item.stock <= 0 ? t.nearlyOut : t.low,
                              statusColor: item.stock <= 0 ? Colors.red : Colors.orange,
                              statusBgColor: item.stock <= 0 ? colors.subtleRed : const Color(0xFFFFF3E0),
                            ),
                            const Divider(height: 16, thickness: 0.5),
                          ],
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showRecordSaleDialog(context),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    t.recordSale,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t.bestSellingMenu,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/laporan'),
                          child: Text(
                            t.viewReport,
                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    SizedBox(
                      height: 90,
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: sales.bestSellers.isEmpty
                                ? [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 30),
                                      child: Text(
                                        t.noSalesToday,
                                        style: TextStyle(fontSize: 12, color: colors.gray),
                                      ),
                                    )
                                  ]
                                : sales.bestSellers.map((b) {
                                    final name = b['recipe_name'] as String;
                                    final cups = b['total_cups'] as int;
                                    final emoji = name.contains('Matcha') ? '🍵' : name.contains('Milk') ? '🧋' : '☕';
                                    return Row(
                                      children: [
                                        _TopMenuItemCard(
                                          iconEmoji: emoji,
                                          title: name,
                                          count: '$cups ${t.cupUnit}',
                                        ),
                                        if (b != sales.bestSellers.last) const SizedBox(width: 10),
                                      ],
                                    );
                                  }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordSaleModal extends StatefulWidget {
  final List<Recipe> recipes;
  const _RecordSaleModal({required this.recipes});

  @override
  State<_RecordSaleModal> createState() => _RecordSaleModalState();
}

class _RecordSaleModalState extends State<_RecordSaleModal> {
  String? _selectedRecipeId;
  String selectedUnit = 'Cup';
  final TextEditingController quantityController = TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController(text: '0');
  bool _isSaving = false;

  double get totalSales {
    final double qty = double.tryParse(quantityController.text) ?? 0;
    final double price = double.tryParse(priceController.text) ?? 0;
    return qty * price;
  }

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = Translations.of(context);
    const saveButtonColor = Color(0xFFFF7B89);
    final recipes = widget.recipes;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colors.card,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Center(
                    child: Text(
                        t.recordSaleTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: -2,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: colors.gray, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                t.selectMenu,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.text),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRecipeId,
                    isExpanded: true,
                    hint: Text(t.selectMenuHint, style: TextStyle(fontSize: 14, color: colors.gray)),
                    icon: Icon(Icons.keyboard_arrow_down, color: colors.gray),
                    style: TextStyle(fontSize: 14, color: colors.text, fontWeight: FontWeight.w500),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => _selectedRecipeId = newValue);
                      }
                    },
                    items: recipes.map((r) => DropdownMenuItem<String>(
                      value: r.id,
                      child: Text(r.name),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                t.qtySold,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.text),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(fontWeight: FontWeight.bold, color: colors.text),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedUnit,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down, color: colors.gray),
                          style: TextStyle(fontSize: 14, color: colors.text, fontWeight: FontWeight.w500),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => selectedUnit = newValue);
                            }
                          },
                          items: <String>['Cup', 'Botol', 'Peket']
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                t.unitPriceLabel,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.text),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                style: TextStyle(fontWeight: FontWeight.bold, color: colors.text),
                decoration: InputDecoration(
                  fillColor: colors.inputBg,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.border),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFF5C0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.totalSalesLabel,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.gray),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RM ${totalSales.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colors.text),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving || _selectedRecipeId == null
                      ? null
                      : () async {
                          final qty = int.tryParse(quantityController.text) ?? 0;
                          final price = double.tryParse(priceController.text) ?? 0;
                          if (qty <= 0 || price <= 0) return;

                          setState(() => _isSaving = true);
                          final auth = context.read<AuthProvider>();
                          final salesProvider = context.read<SalesProvider>();
                          final selectedRecipe = widget.recipes.firstWhere((r) => r.id == _selectedRecipeId);

                          await salesProvider.recordSale(
                            recipeId: selectedRecipe.id,
                            recipeName: selectedRecipe.name,
                            quantity: qty,
                            unitPrice: price,
                            totalAmount: qty * price,
                            userId: auth.currentUser!.id,
                            userName: auth.currentUser!.name,
                          );

                          if (!mounted) return;
                          setState(() => _isSaving = false);
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: saveButtonColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          t.saveRecord,
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FFFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB2F5EA)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF319795), width: 1.5),
                      ),
                      child: const Icon(Icons.check, size: 14, color: Color(0xFF319795)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.autoDeductNotice,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2C7A7B)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String value;
  final Color valueColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: colors.gray),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StockItemRow extends StatelessWidget {
  final String name;
  final String qty;
  final String statusText;
  final Color statusColor;
  final Color statusBgColor;

  const _StockItemRow({
    required this.name,
    required this.qty,
    required this.statusText,
    required this.statusColor,
    required this.statusBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: colors.text,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            qty,
            style: TextStyle(fontSize: 12, color: colors.gray),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusBgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ),
      ],
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

class _TopMenuItemCard extends StatelessWidget {
  final String iconEmoji;
  final String title;
  final String count;

  const _TopMenuItemCard({
    required this.iconEmoji,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      width: 130,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Text(iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      count,
                      style: TextStyle(fontSize: 11, color: colors.gray),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

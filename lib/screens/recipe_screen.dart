import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/inventory_provider.dart';
import '../app/models/inventory_item.dart';
import '../app/models/recipe.dart';
import '../app/recipe_provider.dart';
import '../app/translations.dart';

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final recipeProvider = context.watch<RecipeProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();
    const backgroundColor = Color(0xFFF9F9F9);
    const textDark = Color(0xFF2C3E50);

    final recipes = recipeProvider.filteredRecipes(inventoryProvider.items);

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
            onChanged: (v) => recipeProvider.setSearchQuery(v),
            decoration: InputDecoration(
              hintText: t.searchRecipe,
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              prefixIcon:
                  const Icon(Icons.search, size: 20, color: Colors.grey),
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Resipi Minuman',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: Color(0xFF5BA154), size: 28),
                  onPressed: () => _showRecipeDialog(context),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Tetapkan sukatan',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            child: recipes.isEmpty
                ? Center(
                    child: Text(
                      'Tiada resipi dijumpai',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) => _RecipeCard(
                      recipe: recipes[index],
                      inventory: inventoryProvider.items,
                      onTap: () => _showDetailSheet(context, recipes[index]),
                      onDelete: () =>
                          _confirmDelete(context, recipes[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Recipe recipe) {
    final t = Translations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t.deleteRecipe),
        content: Text('${t.deleteConfirm} "${recipe.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          TextButton(
            onPressed: () {
              context.read<RecipeProvider>().deleteRecipe(recipe.id);
              Navigator.pop(ctx);
            },
            child: Text(t.deleteRecipe,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDetailSheet(BuildContext context, Recipe recipe) {
    final t = Translations.of(context);
    final inventory = context.read<InventoryProvider>().items;

    const primaryPink = Color(0xFFFF6B81);
    const lightPinkBg = Color(0xFFFFF0F2);
    const textDark = Color(0xFF2C3E50);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final itemMap = {for (final i in inventory) i.id: i};

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle top bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Text(
                recipe.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 16),

              // Top Image + Price Card Section
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('🍵', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: lightPinkBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.sellingPrice,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'RM${recipe.sellingPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 32,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _showRecipeDialog(context, recipe: recipe);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryPink,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                t.editRecipe,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ingredients Header
              Text(
                '${t.ingredientsTitle} (1 ${t.perCup.trim()})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),

              // Ingredients List
              ...recipe.ingredients.map((ing) {
                final item = itemMap[ing.inventoryItemId];
                if (item == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Text('🟢', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textDark,
                          ),
                        ),
                      ),
                      Text(
                        '${ing.quantity.toStringAsFixed(0)}${_unitLabel(item.unit)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Notice Footer Box
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: lightPinkBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Resipi ini akan digunakan setiap kali jualan direkod.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: primaryPink,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRecipeDialog(BuildContext context, {Recipe? recipe}) {
    final t = Translations.of(context);
    final inventory = context.read<InventoryProvider>().items;
    final recipeProvider = context.read<RecipeProvider>();
    final isEdit = recipe != null;

    final nameCtrl =
        TextEditingController(text: isEdit ? recipe.name : '');
    final priceCtrl = TextEditingController(
        text: isEdit ? recipe.sellingPrice.toStringAsFixed(2) : '');

    final ingredientCtrls = <_IngredientRow>[];
    if (isEdit) {
      for (final ing in recipe.ingredients) {
        ingredientCtrls.add(_IngredientRow(
          itemId: ing.inventoryItemId,
          qtyCtrl: TextEditingController(
              text: ing.quantity.toStringAsFixed(0)),
        ));
      }
    } else {
      ingredientCtrls.add(_IngredientRow());
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          double calcCost() {
            double total = 0;
            for (final row in ingredientCtrls) {
              if (row.itemId == null) continue;
              final item = inventory.firstWhere(
                (i) => i.id == row.itemId,
                orElse: () => InventoryItem(
                    id: '',
                    name: '',
                    category: ItemCategory.bahan,
                    unit: ItemUnit.g,
                    stock: 0,
                    minStock: 0,
                    costPerUnit: 0),
              );
              final qty = double.tryParse(row.qtyCtrl.text) ?? 0;
              total += item.costPerUnit * qty;
            }
            return total;
          }

          final cost = calcCost();
          final price = double.tryParse(priceCtrl.text) ?? 0;
          final profit = price - cost;

          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text(
              isEdit ? t.editRecipe : t.newRecipe,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: _inputDecoration(t.beverageName),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(t.sellingPrice),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.ingredientsTitle.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...ingredientCtrls.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final row = entry.value;
                    final selectedItem = row.itemId != null
                        ? inventory.firstWhere(
                            (i) => i.id == row.itemId,
                            orElse: () => InventoryItem(
                                id: '',
                                name: '',
                                category: ItemCategory.bahan,
                                unit: ItemUnit.g,
                                stock: 0,
                                minStock: 0,
                                costPerUnit: 0),
                          )
                        : null;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: InputDecorator(
                              decoration: _inputDecoration(''),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: row.itemId,
                                  isDense: true,
                                  isExpanded: true,
                                  hint: const Text('Pilih...',
                                      style: TextStyle(fontSize: 13)),
                                  items: inventory
                                      .map((i) => DropdownMenuItem(
                                            value: i.id,
                                            child: Text(i.name,
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                          ))
                                      .toList(),
                                  onChanged: (v) => setDialogState(
                                      () => row.itemId = v!),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: row.qtyCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setDialogState(() {}),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                suffixText: selectedItem != null
                                    ? _unitLabel(selectedItem.unit)
                                    : null,
                              ),
                            ),
                          ),
                          if (ingredientCtrls.length > 1)
                            IconButton(
                              icon: const Icon(Icons.close,
                                  size: 18, color: Colors.red),
                              onPressed: () {
                                setDialogState(() {
                                  row.qtyCtrl.dispose();
                                  ingredientCtrls.removeAt(idx);
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  TextButton.icon(
                    onPressed: () => setDialogState(() {
                      ingredientCtrls.add(_IngredientRow());
                    }),
                    icon: const Icon(Icons.add,
                        size: 18, color: Color(0xFF5BA154)),
                    label: Text(
                      t.addIngredient,
                      style: const TextStyle(color: Color(0xFF5BA154)),
                    ),
                  ),
                  const Divider(height: 20),
                  _costRow(t.totalCostLabel, cost, Colors.black87),
                  _costRow(t.sellingPrice, price, const Color(0xFF5BA154)),
                  _costRow(
                    t.grossProfitLabel,
                    profit,
                    profit >= 0 ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5BA154)),
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final ingredients = <RecipeIngredient>[];
                  for (final row in ingredientCtrls) {
                    if (row.itemId == null) continue;
                    final qty = double.tryParse(row.qtyCtrl.text) ?? 0;
                    if (qty <= 0) continue;
                    ingredients.add(RecipeIngredient(
                      inventoryItemId: row.itemId!,
                      quantity: qty,
                    ));
                  }
                  if (ingredients.isEmpty) return;

                  if (isEdit) {
                    recipeProvider.updateRecipe(
                      id: recipe.id,
                      name: nameCtrl.text.trim(),
                      sellingPrice: price,
                      ingredients: ingredients,
                    );
                  } else {
                    recipeProvider.addRecipe(
                      name: nameCtrl.text.trim(),
                      sellingPrice: price,
                      ingredients: ingredients,
                    );
                  }
                  Navigator.pop(ctx);
                },
                child: Text(t.save,
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final List<InventoryItem> inventory;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecipeCard({
    required this.recipe,
    required this.inventory,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final cost = recipe.costPerServing(inventory);
    final profit = recipe.grossProfit(inventory);
    const textDark = Color(0xFF2C3E50);
    const primaryGreen = Color(0xFF5BA154);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('☕', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${t.sellingPrice}: RM ${recipe.sellingPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${t.cost}: RM ${cost.toStringAsFixed(2)}${t.perCup}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  '${t.grossProfitLabel}: RM ${profit.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: profit >= 0 ? primaryGreen : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.grey),
            onPressed: onTap,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 20, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label.isNotEmpty ? label : null,
    labelStyle: const TextStyle(fontSize: 13),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    isDense: true,
  );
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

Widget _costRow(String label, double value, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          'RM ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _IngredientRow {
  String? itemId;
  final TextEditingController qtyCtrl;

  _IngredientRow({this.itemId, TextEditingController? qtyCtrl})
      : qtyCtrl = qtyCtrl ?? TextEditingController();
}
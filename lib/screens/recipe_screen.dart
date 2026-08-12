import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/auth_provider.dart';
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
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final colors = Theme.of(context).extension<AppColors>()!;
    const pinkAccent = Color(0xFFFF7B89);

    final recipes = recipeProvider.filteredRecipes();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.recipeTitle,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isAdmin)
                    GestureDetector(
                      onTap: () => _showRecipeDialog(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: pinkAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
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
                  onChanged: (v) => recipeProvider.setSearchQuery(v),
                  decoration: InputDecoration(
                    hintText: t.searchRecipe,
                    hintStyle: TextStyle(fontSize: 14, color: colors.gray),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: colors.gray,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                t.setMeasurement,
                style: TextStyle(fontSize: 13, color: colors.gray),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ClipRect(
                clipBehavior: Clip.hardEdge,
                child: recipes.isEmpty
                    ? Center(
                        child: Text(
                          t.emptyRecipe,
                          style: TextStyle(color: colors.gray, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: recipes.length,
                        itemBuilder: (context, index) => _RecipeCard(
                          recipe: recipes[index],
                          inventory: inventoryProvider.items,
                          onTap: () =>
                              _showDetailSheet(context, recipes[index]),
                          onDelete: isAdmin
                              ? () => _confirmDelete(context, recipes[index])
                              : null,
                        ),
                      ),
              ),
            ),
          ],
        ),
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
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              if (auth.currentUser == null) return;
              try {
                await context.read<RecipeProvider>().deleteRecipe(recipe.id);
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete recipe: $error')),
                  );
                }
                return;
              }
              if (!context.mounted) return;
              Navigator.pop(ctx);
            },
            child: Text(
              t.deleteRecipe,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailSheet(BuildContext context, Recipe recipe) {
    final t = Translations.of(context);
    final inventory = context.read<InventoryProvider>().items;
    final colors = Theme.of(context).extension<AppColors>()!;
    final isAdmin = context.read<AuthProvider>().isAdmin;

    const primaryPink = Color(0xFFFF6B81);
    const lightPinkBg = Color(0xFFFFF0F2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final itemMap = {for (final i in inventory) i.id: i};

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.gray.withAlpha(80),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  recipe.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'RM ${recipe.sellingPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5BA154),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (isAdmin)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (ctx.mounted) Navigator.pop(ctx);
                        _showRecipeDialog(context, recipe: recipe);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPink,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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
                const SizedBox(height: 24),

                Text(
                  '${t.ingredientsTitle} (1 ${t.perCup.trim()})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 12),

                ...recipe.ingredients.map((ing) {
                  final item = itemMap[ing.inventoryItemId];
                  if (item == null) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colors.text,
                            ),
                          ),
                        ),
                        Text(
                          '${ing.quantity.toStringAsFixed(0)}${_unitLabel(item.unit)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.gray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: lightPinkBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.recipeNote,
                          style: TextStyle(fontSize: 12, color: colors.gray),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.favorite, size: 16, color: primaryPink),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRecipeDialog(BuildContext context, {Recipe? recipe}) async {
    final t = Translations.of(context);
    final inventory = context.read<InventoryProvider>().items;
    final recipeProvider = context.read<RecipeProvider>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final isEdit = recipe != null;

    final nameCtrl = TextEditingController(text: isEdit ? recipe.name : '');
    final priceCtrl = TextEditingController(
      text: isEdit ? recipe.sellingPrice.toStringAsFixed(2) : '',
    );

    final ingredientCtrls = <_IngredientRow>[];
    var isSaving = false;
    if (isEdit) {
      for (final ing in recipe.ingredients) {
        ingredientCtrls.add(
          _IngredientRow(
            itemId: ing.inventoryItemId,
            qtyCtrl: TextEditingController(
              text: ing.quantity.toStringAsFixed(0),
            ),
          ),
        );
      }
    } else {}

    try {
      await showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isEdit ? t.editRecipe : t.newRecipe,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            t.ingredientsTitle.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colors.gray,
                            ),
                          ),
                          Text(
                            ingredientCtrls.length.toString(),
                            style: TextStyle(fontSize: 12, color: colors.gray),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (ingredientCtrls.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            t.noIngredientsHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.gray,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        ...ingredientCtrls.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final row = entry.value;
                          return row.isNew
                              ? _buildNewIngredientCard(
                                  row,
                                  idx,
                                  ingredientCtrls,
                                  setDialogState,
                                  t,
                                  colors,
                                )
                              : _buildExistingIngredientCard(
                                  row,
                                  idx,
                                  ingredientCtrls,
                                  inventory,
                                  setDialogState,
                                  t,
                                  colors,
                                );
                        }),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => setDialogState(
                                () => ingredientCtrls.add(_IngredientRow()),
                              ),
                              icon: const Icon(Icons.list_alt, size: 16),
                              label: Text(
                                t.addFromInventory,
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF5BA154),
                                side: const BorderSide(
                                  color: Color(0xFF5BA154),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => setDialogState(
                                () => ingredientCtrls.add(
                                  _IngredientRow(isNew: true),
                                ),
                              ),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 16,
                              ),
                              label: Text(
                                t.createNewIngredient,
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFF7B89),
                                side: const BorderSide(
                                  color: Color(0xFFFF7B89),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final name = nameCtrl.text.trim();
                                  final price = double.tryParse(priceCtrl.text);
                                  final authUser = context
                                      .read<AuthProvider>()
                                      .currentUser;

                                  if (name.isEmpty ||
                                      price == null ||
                                      price <= 0 ||
                                      authUser == null) {
                                    return;
                                  }

                                  setDialogState(() => isSaving = true);
                                  try {
                                    final inventoryProvider = context
                                        .read<InventoryProvider>();

                                    for (final row in ingredientCtrls) {
                                      if (!row.isNew) continue;
                                      final ingredientName = row.nameCtrl.text
                                          .trim();
                                      if (ingredientName.isEmpty) continue;

                                      final created = await inventoryProvider
                                          .addItemQuick(
                                            name: ingredientName,
                                            category: row.newCategory,
                                            unit: row.newUnit,
                                            userId: authUser.id,
                                            userName: authUser.name,
                                          );
                                      if (created == null) {
                                        throw StateError(
                                          'Unable to create ingredient "$ingredientName"',
                                        );
                                      }
                                      row.itemId = created.id;
                                    }

                                    final ingredients = <RecipeIngredient>[];
                                    for (final row in ingredientCtrls) {
                                      final itemId = row.itemId;
                                      final quantity = double.tryParse(
                                        row.qtyCtrl.text,
                                      );
                                      if (itemId == null ||
                                          quantity == null ||
                                          quantity <= 0) {
                                        continue;
                                      }
                                      ingredients.add(
                                        RecipeIngredient(
                                          inventoryItemId: itemId,
                                          quantity: quantity,
                                        ),
                                      );
                                    }

                                    if (ingredients.isEmpty) {
                                      throw StateError(
                                        'Add at least one ingredient',
                                      );
                                    }

                                    if (isEdit) {
                                      await recipeProvider.updateRecipe(
                                        id: recipe.id,
                                        name: name,
                                        sellingPrice: price,
                                        ingredients: ingredients,
                                      );
                                    } else {
                                      await recipeProvider.addRecipe(
                                        name: name,
                                        sellingPrice: price,
                                        ingredients: ingredients,
                                        userId: authUser.id,
                                      );
                                    }

                                    if (!ctx.mounted) return;
                                    Navigator.of(ctx).pop();
                                  } catch (error) {
                                    if (ctx.mounted) {
                                      setDialogState(() => isSaving = false);
                                    }
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to save recipe: $error',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5BA154),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
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
              ),
            );
          },
        ),
      );
    } finally {
      nameCtrl.dispose();
      priceCtrl.dispose();
      for (final row in ingredientCtrls) {
        row.dispose();
      }
    }
  }

  Widget _buildExistingIngredientCard(
    _IngredientRow row,
    int idx,
    List<_IngredientRow> ctrls,
    List<InventoryItem> inventory,
    void Function(void Function()) setDialogState,
    Translations t,
    AppColors colors,
  ) {
    final suffix = row.itemId != null
        ? _unitLabel(
            inventory
                .firstWhere(
                  (i) => i.id == row.itemId,
                  orElse: () => InventoryItem(
                    id: '',
                    name: '',
                    category: ItemCategory.bahan,
                    unit: ItemUnit.g,
                    stock: 0,
                    minStock: 0,
                    costPerUnit: 0,
                  ),
                )
                .unit,
          )
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF5BA154)),
        borderRadius: BorderRadius.circular(12),
      ),
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
                  hint: Text(
                    t.selectHint,
                    style: const TextStyle(fontSize: 13),
                  ),
                  items: inventory
                      .map(
                        (i) => DropdownMenuItem(
                          value: i.id,
                          child: Text(
                            i.name,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setDialogState(() {
                    row.itemId = v;
                    row.isNew = false;
                  }),
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
                  horizontal: 8,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixText: suffix,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: () => setDialogState(() {
              row.dispose();
              ctrls.removeAt(idx);
            }),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildNewIngredientCard(
    _IngredientRow row,
    int idx,
    List<_IngredientRow> ctrls,
    void Function(void Function()) setDialogState,
    Translations t,
    AppColors colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF5BA154)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.red),
                onPressed: () => setDialogState(() {
                  row.dispose();
                  ctrls.removeAt(idx);
                }),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          TextField(
            controller: row.nameCtrl,
            decoration: _inputDecoration(t.itemName),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.unit,
                      style: TextStyle(fontSize: 11, color: colors.gray),
                    ),
                    const SizedBox(height: 4),
                    InputDecorator(
                      decoration: _inputDecoration(''),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ItemUnit>(
                          value: row.newUnit,
                          isDense: true,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 13),
                          items: ItemUnit.values
                              .map(
                                (u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(
                                    _unitLabel(u),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setDialogState(() => row.newUnit = v!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.category,
                      style: TextStyle(fontSize: 11, color: colors.gray),
                    ),
                    const SizedBox(height: 4),
                    InputDecorator(
                      decoration: _inputDecoration(''),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ItemCategory>(
                          value: row.newCategory,
                          isDense: true,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 13),
                          items: ItemCategory.values
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    _categoryDisplay(c, t),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setDialogState(() => row.newCategory = v!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: row.qtyCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setDialogState(() {}),
            decoration: InputDecoration(
              isDense: true,
              hintText: t.quantity,
              hintStyle: TextStyle(fontSize: 13, color: colors.gray),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixText: _unitLabel(row.newUnit),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final List<InventoryItem> inventory;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _RecipeCard({
    required this.recipe,
    required this.inventory,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    // final cost = recipe.costPerServing(inventory);
    // final profit = recipe.grossProfit(inventory);
    // const primaryGreen = Color(0xFF5BA154);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: colors.text,
                  ),
                ),
                // const SizedBox(height: 2),
                // Text(
                //   '${t.sellingPrice}: RM ${recipe.sellingPrice.toStringAsFixed(2)}',
                //   style: TextStyle(fontSize: 12, color: colors.gray),
                // ),
                // Text(
                //   '${t.cost}: RM ${cost.toStringAsFixed(2)}${t.perCup}',
                //   style: TextStyle(fontSize: 12, color: colors.gray),
                // ),
                // const SizedBox(height: 2),
                // Text(
                //   '${t.grossProfitLabel}: RM ${profit.toStringAsFixed(2)}',
                //   style: TextStyle(
                //     fontSize: 12,
                //     fontWeight: FontWeight.w600,
                //     color: profit >= 0 ? primaryGreen : Colors.red,
                //   ),
                // ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: colors.gray),
            onPressed: onTap,
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    isDense: true,
  );
}

String _categoryDisplay(ItemCategory c, Translations t) {
  switch (c) {
    case ItemCategory.bahan:
      return t.ingredients;
    case ItemCategory.pembungkusan:
      return t.packaging;
    case ItemCategory.lain:
      return t.others;
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

// Widget _costRow(String label, double value, Color labelColor, Color valueColor) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 2),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: TextStyle(fontSize: 13, color: labelColor)),
//         Text(
//           'RM ${value.toStringAsFixed(2)}',
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.bold,
//             color: valueColor,
//           ),
//         ),
//       ],
//     ),
//   );
// }

class _IngredientRow {
  String? itemId;
  bool isNew = false;
  ItemCategory newCategory = ItemCategory.bahan;
  ItemUnit newUnit = ItemUnit.g;
  final TextEditingController qtyCtrl;
  final TextEditingController nameCtrl;

  _IngredientRow({
    this.isNew = false,
    this.itemId,
    TextEditingController? qtyCtrl,
    TextEditingController? nameCtrl,
  }) : nameCtrl = nameCtrl ?? TextEditingController(),
       qtyCtrl = qtyCtrl ?? TextEditingController();

  void dispose() {
    qtyCtrl.dispose();
    nameCtrl.dispose();
  }
}

import 'package:flutter/material.dart';
import '../app/translations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Method to trigger the popup dialog matching your image
  void _showRecordSaleDialog(BuildContext context, Translations t) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const _RecordSaleModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    const backgroundColor = Color(0xFFF9F9F9);
    const primaryGreen = Color(0xFF5BA154);
    const softGreenBg = Color(0xFFEAF5EA);
    const softRedBg = Color(0xFFFDF0F0);
    const softBlueBg = Color(0xFFF0F6FF);
    const softPurpleBg = Color(0xFFFBF0F9);
    const pinkAccent = Color(0xFFE27387);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('👋'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.greetingSubtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
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
                  bgColor: softGreenBg,
                  title: t.salesToday,
                  value: 'RM 485.00',
                  valueColor: primaryGreen,
                ),
                _StatCard(
                  icon: Icons.monetization_on_outlined,
                  iconColor: pinkAccent,
                  bgColor: softPurpleBg,
                  title: t.grossProfit,
                  value: 'RM 286.50',
                  valueColor: pinkAccent,
                ),
                _StatCard(
                  icon: Icons.local_cafe_outlined,
                  iconColor: const Color(0xFF8E44AD),
                  bgColor: softPurpleBg,
                  title: t.cupsSold,
                  value: '68 cup',
                  valueColor: textDark,
                ),
                _StatCard(
                  icon: Icons.inventory_2_outlined,
                  iconColor: Colors.blue,
                  bgColor: softBlueBg,
                  title: t.inventoryValue,
                  value: 'RM 1,250.00',
                  valueColor: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
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
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          t.viewAll,
                          style: const TextStyle(fontSize: 12, color: textDark),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 16, thickness: 0.5),
                  _StockItemRow(
                    iconPath: '🥛',
                    name: 'Susu UHT',
                    qty: '2 kotak',
                    statusText: t.nearlyOut,
                    statusColor: Colors.red,
                    statusBgColor: softRedBg,
                  ),
                  Divider(height: 16, thickness: 0.5),
                  _StockItemRow(
                    iconPath: '🍵',
                    name: 'Matcha Powder',
                    qty: '300g',
                    statusText: t.low,
                    statusColor: Colors.orange,
                    statusBgColor: const Color(0xFFFFF3E0),
                  ),
                  Divider(height: 16, thickness: 0.5),
                  _StockItemRow(
                    iconPath: '🧋',
                    name: 'Pearl',
                    qty: '500g',
                    statusText: t.nearlyOut,
                    statusColor: Colors.red,
                    statusBgColor: softRedBg,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Record Sale Button triggers the Modal Pop-up
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showRecordSaleDialog(context, t),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.bestSellingMenu,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    t.viewReport,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _TopMenuItemCard(
                    iconEmoji: '🍵',
                    title: 'Matcha\nLatte',
                    count: '35 cup',
                  ),
                  SizedBox(width: 10),
                  _TopMenuItemCard(
                    iconEmoji: '🧋',
                    title: 'Milk Tea',
                    count: '20 cup',
                  ),
                  SizedBox(width: 10),
                  _TopMenuItemCard(
                    iconEmoji: '☕',
                    title: 'Americano',
                    count: '13 cup',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// POPUP DIALOG: Rekod Jualan
// ---------------------------------------------------------------------------
class _RecordSaleModal extends StatefulWidget {
  const _RecordSaleModal();

  @override
  State<_RecordSaleModal> createState() => _RecordSaleModalState();
}

class _RecordSaleModalState extends State<_RecordSaleModal> {
  String selectedMenu = 'Matcha Latte (RM 8.00)';
  String selectedUnit = 'Cup';
  final TextEditingController quantityController = TextEditingController(text: '20');
  final TextEditingController priceController = TextEditingController(text: '8.00');

  double get totalSales {
    final double qty = double.tryParse(quantityController.text) ?? 0;
    final double price = double.tryParse(priceController.text) ?? 0;
    return qty * price;
  }

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF2C3E50);
    const borderColor = Color(0xFFE2E8F0);
    const saveButtonColor = Color(0xFFFF7B89);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Title and Close Icon
              Stack(
                children: [
                  const Center(
                    child: Text(
                      'Rekod Jualan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: -2,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFFA0AEC0),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pilih Menu Label & Dropdown
              const Text(
                'Pilih Menu',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedMenu,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF718096)),
                    style: const TextStyle(fontSize: 14, color: textDark, fontWeight: FontWeight.w500),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedMenu = newValue;
                        });
                      }
                    },
                    items: <String>[
                      'Matcha Latte (RM 8.00)',
                      'Milk Tea (RM 7.00)',
                      'Americano (RM 5.00)'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kuantiti Terjual Fields (Quantity + Unit)
              const Text(
                'Kuantiti Terjual',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Quantity Input Field
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: textDark),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Unit Dropdown Field
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedUnit,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF718096)),
                          style: const TextStyle(fontSize: 14, color: textDark, fontWeight: FontWeight.w500),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedUnit = newValue;
                              });
                            }
                          },
                          items: <String>['Cup', 'Botol', 'Peket']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Harga Jual Seunit Field
              const Text(
                'Harga Jual Seunit (RM)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontWeight: FontWeight.bold, color: textDark),
                decoration: InputDecoration(
                  fillColor: const Color(0xFFF7FAFC),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Total Calculation Container (Jumlah Jualan)
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
                    const Text(
                      'Jumlah Jualan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RM ${totalSales.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Save Button (Simpan Rekod)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: saveButtonColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Rekod',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Automatic Stock Deduction Notice Container
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
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Color(0xFF319795),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Stok bahan akan ditolak mengikut resipi secara automatik.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C7A7B),
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

// ---------------------------------------------------------------------------
// EXISTING HELPER WIDGETS
// ---------------------------------------------------------------------------
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
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
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
  final String iconPath;
  final String name;
  final String qty;
  final String statusText;
  final Color statusColor;
  final Color statusBgColor;

  const _StockItemRow({
    required this.iconPath,
    required this.name,
    required this.qty,
    required this.statusText,
    required this.statusColor,
    required this.statusBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Text(iconPath, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            qty,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
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
    return Container(
      width: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(iconEmoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
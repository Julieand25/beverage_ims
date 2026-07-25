import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom color constants extracted from the design
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
            // Header Section: Greeting + Avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Hai, Farisha!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text('👋'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Semoga jualan hari ini laris!',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
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

            // Top Stat Cards Grid (2x2)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.0,
              children: const [
                _StatCard(
                  icon: Icons.receipt_long,
                  iconColor: primaryGreen,
                  bgColor: softGreenBg,
                  title: 'Jualan Hari Ini',
                  value: 'RM 485.00',
                  valueColor: primaryGreen,
                ),
                _StatCard(
                  icon: Icons.monetization_on_outlined,
                  iconColor: pinkAccent,
                  bgColor: softPurpleBg,
                  title: 'Untung Kasar',
                  value: 'RM 286.50',
                  valueColor: pinkAccent,
                ),
                _StatCard(
                  icon: Icons.local_cafe_outlined,
                  iconColor: Color(0xFF8E44AD),
                  bgColor: softPurpleBg,
                  title: 'Cawan Terjual',
                  value: '68 cup',
                  valueColor: textDark,
                ),
                _StatCard(
                  icon: Icons.inventory_2_outlined,
                  iconColor: Colors.blue,
                  bgColor: softBlueBg,
                  title: 'Nilai Inventori',
                  value: 'RM 1,250.00',
                  valueColor: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status Stok Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'STATUS STOK',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Lihat Semua >',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: const [
                  _StockItemRow(
                    iconPath: '🥛',
                    name: 'Susu UHT',
                    qty: '2 kotak',
                    statusText: 'Hampir Habis',
                    statusColor: Colors.red,
                    statusBgColor: softRedBg,
                  ),
                  Divider(height: 16),
                  _StockItemRow(
                    iconPath: '🍵',
                    name: 'Matcha Powder',
                    qty: '300g',
                    statusText: 'Rendah',
                    statusColor: Colors.orange,
                    statusBgColor: Color(0xFFFFF3E0),
                  ),
                  Divider(height: 16),
                  _StockItemRow(
                    iconPath: '🧋',
                    name: 'Pearl',
                    qty: '500g',
                    statusText: 'Hampir Habis',
                    statusColor: Colors.red,
                    statusBgColor: softRedBg,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Button: + Rekod Jualan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Rekod Jualan',
                  style: TextStyle(
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

            // Menu Terlaris Hari Ini Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MENU TERLARIS HARI INI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Lihat Laporan >',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal Menu Items List
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

// Custom Widget for Top Statistic Cards
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

// Custom Widget for Stock Alert Items
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
        Text(
          qty,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Container(
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
      ],
    );
  }
}

// Custom Widget for Top Selling Items (Horizontal scroll)
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
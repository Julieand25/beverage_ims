import 'package:flutter/material.dart';
import '../app/translations.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedTab = 0;

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
        title: Text(
          t.reportTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: textDark,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TabToggle(
              selectedIndex: _selectedTab,
              labels: [
                t.dailyReport,
                t.stockHistory,
                t.monthlySummary,
              ],
              onChanged: (index) => setState(() => _selectedTab = index),
            ),
            const SizedBox(height: 16),
            if (_selectedTab == 0) _DailyReport(t: t, primaryGreen: primaryGreen, softGreenBg: softGreenBg, softRedBg: softRedBg, softBlueBg: softBlueBg, softPurpleBg: softPurpleBg, pinkAccent: pinkAccent, textDark: textDark),
            if (_selectedTab == 1) _StockHistory(t: t, softGreenBg: softGreenBg, softRedBg: softRedBg, textDark: textDark, primaryGreen: primaryGreen),
            if (_selectedTab == 2) _MonthlySummary(t: t, primaryGreen: primaryGreen, softGreenBg: softGreenBg, softRedBg: softRedBg, textDark: textDark),
          ],
        ),
      ),
    );
  }
}

class _TabToggle extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _TabToggle({
    required this.selectedIndex,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF5BA154)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DailyReport extends StatelessWidget {
  final Translations t;
  final Color primaryGreen;
  final Color softGreenBg;
  final Color softRedBg;
  final Color softBlueBg;
  final Color softPurpleBg;
  final Color pinkAccent;
  final Color textDark;

  const _DailyReport({
    required this.t,
    required this.primaryGreen,
    required this.softGreenBg,
    required this.softRedBg,
    required this.softBlueBg,
    required this.softPurpleBg,
    required this.pinkAccent,
    required this.textDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateHeader(),
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
              title: t.dailySales,
              value: 'RM 485.00',
              valueColor: primaryGreen,
            ),
            _StatCard(
              icon: Icons.monetization_on_outlined,
              iconColor: pinkAccent,
              bgColor: softPurpleBg,
              title: t.dailyCost,
              value: 'RM 198.50',
              valueColor: pinkAccent,
            ),
            _StatCard(
              icon: Icons.trending_up,
              iconColor: primaryGreen,
              bgColor: softGreenBg,
              title: t.dailyProfit,
              value: 'RM 286.50',
              valueColor: primaryGreen,
            ),
            _StatCard(
              icon: Icons.local_cafe_outlined,
              iconColor: Colors.blue,
              bgColor: softBlueBg,
              title: t.dailyCups,
              value: '68 ${t.isMs ? "cawan" : "cups"}',
              valueColor: Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          t.menuRank.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        _BestSellerCard(rank: 1, name: 'Matcha Latte', cups: '35', revenue: 'RM 280.00', primaryGreen: primaryGreen),
        const SizedBox(height: 8),
        _BestSellerCard(rank: 2, name: 'Milk Tea', cups: '20', revenue: 'RM 120.00', primaryGreen: primaryGreen),
        const SizedBox(height: 8),
        _BestSellerCard(rank: 3, name: 'Americano', cups: '13', revenue: 'RM 65.00', primaryGreen: primaryGreen),
      ],
    );
  }
}

class _DateHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            '16 Julai 2026',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
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

class _BestSellerCard extends StatelessWidget {
  final int rank;
  final String name;
  final String cups;
  final String revenue;
  final Color primaryGreen;

  const _BestSellerCard({
    required this.rank,
    required this.name,
    required this.cups,
    required this.revenue,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    final rankColors = [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32)];
    final rankColor = rank <= 3 ? rankColors[rank - 1] : Colors.grey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rankColor.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
            ),
          ),
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
            '$cups cup',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Text(
            revenue,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockHistory extends StatelessWidget {
  final Translations t;
  final Color softGreenBg;
  final Color softRedBg;
  final Color textDark;
  final Color primaryGreen;

  const _StockHistory({
    required this.t,
    required this.softGreenBg,
    required this.softRedBg,
    required this.textDark,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StockLog(
          icon: Icons.add_circle_outline,
          iconColor: primaryGreen,
          bgColor: softGreenBg,
          title: '+10000ml Susu UHT',
          subtitle: t.restockEntry,
          timestamp: '16 Julai 2026, 08:00 AM',
        ),
        const SizedBox(height: 8),
        _StockLog(
          icon: Icons.remove_circle_outline,
          iconColor: Colors.red,
          bgColor: softRedBg,
          title: '-35 cawan Matcha Latte',
          subtitle: t.deductionEntry,
          timestamp: '16 Julai 2026, 10:30 AM',
        ),
        const SizedBox(height: 8),
        _StockLog(
          icon: Icons.remove_circle_outline,
          iconColor: Colors.red,
          bgColor: softRedBg,
          title: '-20 cawan Milk Tea',
          subtitle: t.deductionEntry,
          timestamp: '16 Julai 2026, 12:15 PM',
        ),
        const SizedBox(height: 8),
        _StockLog(
          icon: Icons.add_circle_outline,
          iconColor: primaryGreen,
          bgColor: softGreenBg,
          title: '+500g Matcha Powder',
          subtitle: t.restockEntry,
          timestamp: '15 Julai 2026, 04:00 PM',
        ),
        const SizedBox(height: 8),
        _StockLog(
          icon: Icons.remove_circle_outline,
          iconColor: Colors.red,
          bgColor: softRedBg,
          title: '-13 cawan Americano',
          subtitle: t.deductionEntry,
          timestamp: '16 Julai 2026, 03:45 PM',
        ),
      ],
    );
  }
}

class _StockLog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String timestamp;

  const _StockLog({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timestamp,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _MonthlySummary extends StatelessWidget {
  final Translations t;
  final Color primaryGreen;
  final Color softGreenBg;
  final Color softRedBg;
  final Color textDark;

  const _MonthlySummary({
    required this.t,
    required this.primaryGreen,
    required this.softGreenBg,
    required this.softRedBg,
    required this.textDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MonthlyHeader(t: t, primaryGreen: primaryGreen, textDark: textDark),
        const SizedBox(height: 16),
        _WeeklyChart(primaryGreen: primaryGreen, softRedBg: softRedBg),
        const SizedBox(height: 16),
        _Legend(t: t),
      ],
    );
  }
}

class _MonthlyHeader extends StatelessWidget {
  final Translations t;
  final Color primaryGreen;
  final Color textDark;

  const _MonthlyHeader({
    required this.t,
    required this.primaryGreen,
    required this.textDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Julai 2026',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ),
          Text(
            'RM 8,250.00',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            t.monthlyRevenue,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final Color primaryGreen;
  final Color softRedBg;

  const _WeeklyChart({
    required this.primaryGreen,
    required this.softRedBg,
  });

  @override
  Widget build(BuildContext context) {
    final weeks = [
      ('Mng 1', 0.85, 0.35),
      ('Mng 2', 0.70, 0.30),
      ('Mng 3', 0.90, 0.40),
      ('Mng 4', 0.65, 0.25),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weeks.map((w) {
              return Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 18,
                          height: 100 * w.$2,
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 18,
                          height: 100 * w.$3,
                          decoration: BoxDecoration(
                            color: softRedBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    w.$1,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Translations t;

  const _Legend({required this.t});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: const Color(0xFF5BA154), label: t.legendRevenue),
        const SizedBox(width: 24),
        _LegendItem(color: const Color(0xFFFDF0F0), label: t.legendCost),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

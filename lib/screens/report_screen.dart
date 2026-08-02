import 'package:flutter/material.dart';
import '../app/app_colors.dart';
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
    final colors = Theme.of(context).extension<AppColors>()!;
    const primaryGreen = Color(0xFF5BA154);
    const pinkAccent = Color(0xFFE27387);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.reportTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.text,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
              if (_selectedTab == 0) _DailyReport(t: t, primaryGreen: primaryGreen, pinkAccent: pinkAccent),
              if (_selectedTab == 1) _StockHistory(t: t, primaryGreen: primaryGreen),
              if (_selectedTab == 2) _MonthlySummary(t: t, primaryGreen: primaryGreen),
            ],
          ),
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
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
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
                    color: isSelected ? Colors.white : colors.gray,
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
  final Color pinkAccent;

  const _DailyReport({
    required this.t,
    required this.primaryGreen,
    required this.pinkAccent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
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
              bgColor: colors.subtleGreen,
              title: t.dailySales,
              value: 'RM 485.00',
              valueColor: primaryGreen,
            ),
            _StatCard(
              icon: Icons.monetization_on_outlined,
              iconColor: pinkAccent,
              bgColor: colors.subtlePurple,
              title: t.dailyCost,
              value: 'RM 198.50',
              valueColor: pinkAccent,
            ),
            _StatCard(
              icon: Icons.trending_up,
              iconColor: primaryGreen,
              bgColor: colors.subtleGreen,
              title: t.dailyProfit,
              value: 'RM 286.50',
              valueColor: primaryGreen,
            ),
            _StatCard(
              icon: Icons.local_cafe_outlined,
              iconColor: Colors.blue,
              bgColor: colors.subtleBlue,
              title: t.dailyCups,
              value: '68 ${t.isMs ? "cawan" : "cups"}',
              valueColor: Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          t.menuRank.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colors.gray,
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
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: colors.gray),
          const SizedBox(width: 8),
          Text(
            '16 Julai 2026',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.text,
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
    final colors = Theme.of(context).extension<AppColors>()!;
    final rankColors = [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32)];
    final rankColor = rank <= 3 ? rankColors[rank - 1] : colors.gray;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
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
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colors.text,
              ),
            ),
          ),
          Text(
            '$cups cup',
            style: TextStyle(fontSize: 12, color: colors.gray),
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
  final Color primaryGreen;

  const _StockHistory({
    required this.t,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Column(
      children: [
        _StockLog(
          icon: Icons.add_circle_outline,
          iconColor: primaryGreen,
          bgColor: colors.subtleGreen,
          title: '+10000ml Susu UHT',
          subtitle: t.restockEntry,
          timestamp: '16 Julai 2026, 08:00 AM',
        ),
        const SizedBox(height: 8),
        _StockLog(
          icon: Icons.remove_circle_outline,
          iconColor: Colors.red,
          bgColor: colors.subtleRed,
          title: '-35 cawan Matcha Latte',
          subtitle: t.deductionEntry,
          timestamp: '16 Julai 2026, 10:30 AM',
        ),
        const SizedBox(height: 8),
        _StockLog(
          icon: Icons.remove_circle_outline,
          iconColor: Colors.red,
          bgColor: colors.subtleRed,
          title: '-20 cawan Milk Tea',
          subtitle: t.deductionEntry,
          timestamp: '16 Julai 2026, 12:15 PM',
        ),
        const SizedBox(height: 8),
        _StockLog(
          icon: Icons.add_circle_outline,
          iconColor: primaryGreen,
          bgColor: colors.subtleGreen,
          title: '+500g Matcha Powder',
          subtitle: t.restockEntry,
          timestamp: '15 Julai 2026, 04:00 PM',
        ),
        const SizedBox(height: 8),
        _StockLog(
          icon: Icons.remove_circle_outline,
          iconColor: Colors.red,
          bgColor: colors.subtleRed,
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
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: colors.gray),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timestamp,
            style: TextStyle(fontSize: 10, color: colors.gray),
          ),
        ],
      ),
    );
  }
}

class _MonthlySummary extends StatelessWidget {
  final Translations t;
  final Color primaryGreen;

  const _MonthlySummary({
    required this.t,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MonthlyHeader(t: t, primaryGreen: primaryGreen),
        const SizedBox(height: 16),
        _WeeklyChart(primaryGreen: primaryGreen),
        const SizedBox(height: 16),
        _Legend(t: t),
      ],
    );
  }
}

class _MonthlyHeader extends StatelessWidget {
  final Translations t;
  final Color primaryGreen;

  const _MonthlyHeader({
    required this.t,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month, size: 20, color: colors.gray),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Julai 2026',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.text,
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
            style: TextStyle(fontSize: 11, color: colors.gray),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final Color primaryGreen;

  const _WeeklyChart({
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
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
        color: colors.card,
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
                            color: colors.subtleRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    w.$1,
                    style: TextStyle(fontSize: 11, color: colors.gray),
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
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: const Color(0xFF5BA154), label: t.legendRevenue),
        const SizedBox(width: 24),
        _LegendItem(color: colors.subtleRed, label: t.legendCost),
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
    final colors = Theme.of(context).extension<AppColors>()!;
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
          style: TextStyle(fontSize: 11, color: colors.gray),
        ),
      ],
    );
  }
}

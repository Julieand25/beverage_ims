import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/sales_provider.dart';
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
    final sales = context.watch<SalesProvider>();
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
              if (_selectedTab == 0) _DailyReport(t: t, primaryGreen: primaryGreen, pinkAccent: pinkAccent, sales: sales),
              if (_selectedTab == 1) _StockHistory(t: t, primaryGreen: primaryGreen, sales: sales),
              if (_selectedTab == 2) _MonthlySummary(t: t, primaryGreen: primaryGreen, sales: sales),
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
  final SalesProvider sales;

  const _DailyReport({
    required this.t,
    required this.primaryGreen,
    required this.pinkAccent,
    required this.sales,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final now = DateTime.now();
    final dateStr = '${now.day} ${_monthName(now.month, t.isMs)} ${now.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateHeader(date: dateStr),
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
              value: 'RM ${sales.todaySales.toStringAsFixed(2)}',
              valueColor: primaryGreen,
            ),
            _StatCard(
              icon: Icons.monetization_on_outlined,
              iconColor: pinkAccent,
              bgColor: colors.subtlePurple,
              title: t.dailyCost,
              value: 'RM ${(sales.todaySales * 0.4).toStringAsFixed(2)}',
              valueColor: pinkAccent,
            ),
            _StatCard(
              icon: Icons.trending_up,
              iconColor: primaryGreen,
              bgColor: colors.subtleGreen,
              title: t.dailyProfit,
              value: 'RM ${(sales.todaySales * 0.6).toStringAsFixed(2)}',
              valueColor: primaryGreen,
            ),
            _StatCard(
              icon: Icons.local_cafe_outlined,
              iconColor: Colors.blue,
              bgColor: colors.subtleBlue,
              title: t.dailyCups,
              value: '${sales.todayCups} ${t.isMs ? "cawan" : "cups"}',
              valueColor: Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          t.menuRank.toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.gray),
        ),
        const SizedBox(height: 8),
        if (sales.bestSellers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              t.isMs ? 'Tiada jualan hari ini' : 'No sales today',
              style: TextStyle(fontSize: 13, color: colors.gray),
            ),
          )
        else
          ...sales.bestSellers.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final b = entry.value;
            final name = b['recipe_name'] as String;
            final cups = (b['total_cups'] as int).toString();
            final revenue = 'RM ${(b['total_revenue'] as double).toStringAsFixed(2)}';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _BestSellerCard(rank: rank, name: name, cups: cups, revenue: revenue, primaryGreen: primaryGreen),
            );
          }),
      ],
    );
  }
}

String _monthName(int month, bool isMs) {
  if (isMs) {
    const months = ['', 'Januari', 'Februari', 'Mac', 'April', 'Mei', 'Jun', 'Julai', 'Ogos', 'September', 'Oktober', 'November', 'Disember'];
    return months[month];
  }
  const months = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return months[month];
}

class _DateHeader extends StatelessWidget {
  final String date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: colors.gray),
          const SizedBox(width: 8),
          Text(date, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text)),
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
  final SalesProvider sales;

  const _StockHistory({
    required this.t,
    required this.primaryGreen,
    required this.sales,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final movements = sales.stockMovements;

    if (movements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            t.isMs ? 'Tiada rekod stok' : 'No stock records',
            style: TextStyle(fontSize: 13, color: colors.gray),
          ),
        ),
      );
    }

    return Column(
      children: movements.map((m) {
        final isRestock = m['type'] == 'restock';
        final itemName = m['inventory_items']?['name'] ?? 'Unknown';
        final qty = (m['quantity'] as num).toDouble();
        final movedAt = DateTime.parse(m['moved_at'] as String);
        final timestamp = '${movedAt.day} ${_monthName(movedAt.month, t.isMs)} ${movedAt.year}, ${movedAt.hour.toString().padLeft(2, '0')}:${movedAt.minute.toString().padLeft(2, '0')}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _StockLog(
            icon: isRestock ? Icons.add_circle_outline : Icons.remove_circle_outline,
            iconColor: isRestock ? primaryGreen : Colors.red,
            bgColor: isRestock ? colors.subtleGreen : colors.subtleRed,
            title: '${isRestock ? "+" : "-"}${qty.abs().toStringAsFixed(0)} $itemName',
            subtitle: isRestock ? t.restockEntry : t.deductionEntry,
            timestamp: timestamp,
          ),
        );
      }).toList(),
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
  final SalesProvider sales;

  const _MonthlySummary({
    required this.t,
    required this.primaryGreen,
    required this.sales,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MonthlyHeader(t: t, primaryGreen: primaryGreen, sales: sales),
        const SizedBox(height: 16),
        _WeeklyChart(primaryGreen: primaryGreen, sales: sales),
        const SizedBox(height: 16),
        _Legend(t: t),
      ],
    );
  }
}

class _MonthlyHeader extends StatelessWidget {
  final Translations t;
  final Color primaryGreen;
  final SalesProvider sales;

  const _MonthlyHeader({
    required this.t,
    required this.primaryGreen,
    required this.sales,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final now = DateTime.now();
    final monthStr = '${_monthName(now.month, t.isMs)} ${now.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.calendar_month, size: 20, color: colors.gray),
          const SizedBox(width: 8),
          Expanded(
            child: Text(monthStr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.text)),
          ),
          Text(
            'RM ${sales.monthlyRevenue.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
          ),
          const SizedBox(width: 4),
          Text(t.monthlyRevenue, style: TextStyle(fontSize: 11, color: colors.gray)),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final Color primaryGreen;
  final SalesProvider sales;

  const _WeeklyChart({
    required this.primaryGreen,
    required this.sales,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final weekly = sales.weeklyStats;

    final weeks = [1, 2, 3, 4].map((w) {
      final data = weekly[w];
      final revFrac = data != null ? ((data['revenue'] ?? 0) / (sales.monthlyRevenue > 0 ? sales.monthlyRevenue : 1)).clamp(0.2, 1.0) : 0.2;
      final costFrac = data != null ? ((data['cost'] ?? 0) / (sales.monthlyRevenue > 0 ? sales.monthlyRevenue : 1)).clamp(0.1, 1.0) : 0.1;
      final label = 'Wk $w';
      return (label, revFrac, costFrac);
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(12)),
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
                        Container(width: 18, height: 100 * w.$2, decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 4),
                        Container(width: 18, height: 100 * w.$3, decoration: BoxDecoration(color: colors.subtleRed, borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(w.$1, style: TextStyle(fontSize: 11, color: colors.gray)),
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

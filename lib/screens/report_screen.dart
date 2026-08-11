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

class _DailyReport extends StatefulWidget {
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
  State<_DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends State<_DailyReport> {
  late DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    widget.sales.loadDailyComparison(_selectedDate);
  }

  String? _changePercent(double today, double yesterday) {
    if (yesterday == 0) return null;
    final pct = ((today - yesterday) / yesterday) * 100;
    final sign = pct >= 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(1)}%';
  }

  String? _changePercentInt(int today, int yesterday) {
    if (yesterday == 0) return null;
    final pct = ((today - yesterday) / yesterday) * 100;
    final sign = pct >= 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = widget.t;
    final primaryGreen = widget.primaryGreen;
    final pinkAccent = widget.pinkAccent;
    final sales = widget.sales;
    final dateStr = '${_selectedDate.day} ${_monthName(_selectedDate.month, t.isMs)} ${_selectedDate.year}';

    final isToday = _selectedDate.day == DateTime.now().day &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.year == DateTime.now().year;

    final marginPct = sales.todaySales > 0
        ? (sales.todayProfit / sales.todaySales * 100).toStringAsFixed(1)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null && picked != _selectedDate) {
              setState(() => _selectedDate = picked);
              sales.loadDailyComparison(picked);
            }
          },
          child: _DateHeader(date: dateStr, isToday: isToday),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.3,
          children: [
            _StatCard(
              icon: Icons.receipt_long,
              iconColor: primaryGreen,
              bgColor: colors.subtleGreen,
              title: t.dailySales,
              value: 'RM ${sales.todaySales.toStringAsFixed(2)}',
              valueColor: primaryGreen,
              comparisonText: _changePercent(sales.todaySales, sales.yesterdaySales),
            ),
            _StatCard(
              icon: Icons.monetization_on_outlined,
              iconColor: pinkAccent,
              bgColor: colors.subtlePurple,
              title: t.dailyCost,
              value: 'RM ${sales.todayCogs.toStringAsFixed(2)}',
              valueColor: pinkAccent,
              comparisonText: sales.yesterdayCogs > 0 ? _changePercent(sales.todayCogs, sales.yesterdayCogs) : null,
            ),
            _StatCard(
              icon: Icons.trending_up,
              iconColor: primaryGreen,
              bgColor: colors.subtleGreen,
              title: t.dailyProfit,
              value: 'RM ${sales.todayProfit.toStringAsFixed(2)}'
                  '${marginPct != null ? '  ($marginPct%)' : ''}',
              valueColor: primaryGreen,
              comparisonText: _changePercent(sales.todayProfit, sales.yesterdayProfit),
            ),
            _StatCard(
              icon: Icons.local_cafe_outlined,
              iconColor: Colors.blue,
              bgColor: colors.subtleBlue,
              title: t.dailyCups,
              value: '${sales.todayCups} ${t.cupsUnit}',
              valueColor: Colors.blue,
              comparisonText: _changePercentInt(sales.todayCups, sales.yesterdayCups),
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
              t.noSalesToday,
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
        const SizedBox(height: 20),
        Text(
          t.dailyTransactions.toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.gray),
        ),
        const SizedBox(height: 8),
        if (sales.dailyTransactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              t.noTransactions,
              style: TextStyle(fontSize: 13, color: colors.gray),
            ),
          )
        else
          ...sales.dailyTransactions.map((tx) {
            final recipeName = tx['recipes']?['name'] as String? ?? t.unknownItem;
            final qty = tx['quantity'] as int;
            final amount = (tx['total_amount'] as num).toDouble();
            final soldAt = DateTime.parse(tx['sold_at'] as String);
            final timeStr = '${soldAt.hour.toString().padLeft(2, '0')}:${soldAt.minute.toString().padLeft(2, '0')}';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TransactionCard(
                name: recipeName,
                qty: qty,
                amount: amount,
                time: timeStr,
                primaryGreen: primaryGreen,
              ),
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
  final bool isToday;
  const _DateHeader({required this.date, this.isToday = false});

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
          if (isToday)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF5BA154).withAlpha(30),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Today',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF5BA154)),
              ),
            ),
          const Spacer(),
          Icon(Icons.chevron_right, size: 16, color: colors.gray),
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
  final String? comparisonText;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.value,
    required this.valueColor,
    this.comparisonText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isUp = comparisonText != null && !comparisonText!.startsWith('-');
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
                ),
                if (comparisonText != null) ...[
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Icon(
                        isUp ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 9,
                        color: isUp ? const Color(0xFF5BA154) : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      FittedBox(
                        child: Text(
                          comparisonText!,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isUp ? const Color(0xFF5BA154) : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
    final t = Translations.of(context);
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
            '$cups ${t.cupUnit}',
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

class _TransactionCard extends StatelessWidget {
  final String name;
  final int qty;
  final double amount;
  final String time;
  final Color primaryGreen;

  const _TransactionCard({
    required this.name,
    required this.qty,
    required this.amount,
    required this.time,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.subtleGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt_long, color: primaryGreen, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: colors.text),
                ),
                Text(
                  '$time  -  x$qty ${t.cupUnit}',
                  style: TextStyle(fontSize: 11, color: colors.gray),
                ),
              ],
            ),
          ),
          Text(
            'RM ${amount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryGreen),
          ),
        ],
      ),
    );
  }
}

class _StockHistory extends StatefulWidget {
  final Translations t;
  final Color primaryGreen;
  final SalesProvider sales;

  const _StockHistory({
    required this.t,
    required this.primaryGreen,
    required this.sales,
  });

  @override
  State<_StockHistory> createState() => _StockHistoryState();
}

class _StockHistoryState extends State<_StockHistory> {
  int _quickFilter = 0; // 0 = all, 1 = 7d, 2 = 30d, 3 = custom
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    widget.sales.loadStockMovements();
  }

  void _applyFilter(int filter) {
    setState(() {
      _quickFilter = filter;
      if (filter == 0) {
        _startDate = null;
        _endDate = null;
        widget.sales.loadStockMovements();
      } else if (filter == 1) {
        _endDate = DateTime.now();
        _startDate = _endDate!.subtract(const Duration(days: 7));
        widget.sales.loadStockMovements(startDate: _startDate, endDate: _endDate);
      } else if (filter == 2) {
        _endDate = DateTime.now();
        _startDate = _endDate!.subtract(const Duration(days: 30));
        widget.sales.loadStockMovements(startDate: _startDate, endDate: _endDate);
      }
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _endDate ?? DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _quickFilter = 3;
      });
      widget.sales.loadStockMovements(startDate: _startDate, endDate: _endDate);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _quickFilter = 3;
      });
      widget.sales.loadStockMovements(startDate: _startDate, endDate: _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = widget.t;
    final primaryGreen = widget.primaryGreen;
    final sales = widget.sales;
    final movements = sales.stockMovements;

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: t.allTime,
                isSelected: _quickFilter == 0,
                onTap: () => _applyFilter(0),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: t.last7Days,
                isSelected: _quickFilter == 1,
                onTap: () => _applyFilter(1),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: t.last30Days,
                isSelected: _quickFilter == 2,
                onTap: () => _applyFilter(2),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _pickStartDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: _quickFilter == 3 ? colors.subtleGreen : colors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _quickFilter == 3 ? primaryGreen : colors.gray.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: _startDate != null ? primaryGreen : colors.gray),
                      const SizedBox(width: 4),
                      Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : t.fromDate,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _startDate != null ? primaryGreen : colors.gray),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _pickEndDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: _quickFilter == 3 ? colors.subtleGreen : colors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _quickFilter == 3 ? primaryGreen : colors.gray.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: _endDate != null ? primaryGreen : colors.gray),
                      const SizedBox(width: 4),
                      Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : t.toDate,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _endDate != null ? primaryGreen : colors.gray),
                      ),
                    ],
                  ),
                ),
              ),
              if (_quickFilter == 3) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _applyFilter(0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.close, size: 14, color: colors.gray),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (movements.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                t.noStockRecords,
                style: TextStyle(fontSize: 13, color: colors.gray),
              ),
            ),
          )
        else
          ...movements.map((m) {
            final isRestock = m['type'] == 'restock';
            final itemName = m['inventory_items']?['name'] ?? t.unknownItem;
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
          }),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? colors.subtleGreen : colors.card,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: const Color(0xFF5BA154))
              : Border.all(color: colors.gray.withAlpha(50)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF5BA154) : colors.gray,
          ),
        ),
      ),
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

class _MonthlySummary extends StatefulWidget {
  final Translations t;
  final Color primaryGreen;
  final SalesProvider sales;

  const _MonthlySummary({
    required this.t,
    required this.primaryGreen,
    required this.sales,
  });

  @override
  State<_MonthlySummary> createState() => _MonthlySummaryState();
}

class _MonthlySummaryState extends State<_MonthlySummary> {
  late DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    widget.sales.loadMonthlyComparison(_selectedMonth);
  }

  void _goToMonth(int monthsDelta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + monthsDelta, 1);
    });
    widget.sales.loadMonthlyComparison(_selectedMonth);
  }

  bool get _canGoNext => DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MonthlyHeader(
          t: t,
          primaryGreen: widget.primaryGreen,
          sales: widget.sales,
          selectedMonth: _selectedMonth,
          onPrevious: () => _goToMonth(-1),
          onNext: _canGoNext ? () => _goToMonth(1) : null,
        ),
        const SizedBox(height: 16),
        _WeeklyChart(primaryGreen: widget.primaryGreen, sales: widget.sales),
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
  final DateTime selectedMonth;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  const _MonthlyHeader({
    required this.t,
    required this.primaryGreen,
    required this.sales,
    required this.selectedMonth,
    required this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final monthStr = '${_monthName(selectedMonth.month, t.isMs)} ${selectedMonth.year}';
    final marginPct = sales.monthlyRevenue > 0
        ? (sales.monthlyProfit / sales.monthlyRevenue * 100).toStringAsFixed(1)
        : null;

    String? comparison;
    Color comparisonColor = colors.gray;
    if (sales.lastMonthRevenue > 0) {
      final pct = ((sales.monthlyRevenue - sales.lastMonthRevenue) / sales.lastMonthRevenue * 100);
      final sign = pct >= 0 ? '+' : '';
      comparison = '${t.vsLastMonth}: $sign${pct.toStringAsFixed(1)}%';
      comparisonColor = pct >= 0 ? const Color(0xFF5BA154) : Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onPrevious,
                child: Icon(Icons.chevron_left, size: 24, color: colors.gray),
              ),
              Expanded(
                child: Text(
                  monthStr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.text),
                ),
              ),
              GestureDetector(
                onTap: onNext,
                child: Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: onNext != null ? colors.gray : colors.gray.withAlpha(50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'RM ${sales.monthlyRevenue.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen),
                  ),
                  Text(t.monthlyRevenue, style: TextStyle(fontSize: 11, color: colors.gray)),
                  if (marginPct != null)
                    Text(
                      '${t.profitMargin}: $marginPct%',
                      style: TextStyle(fontSize: 10, color: colors.gray),
                    ),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                children: [
                  Text(
                    'RM ${sales.monthlyProfit.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: sales.monthlyProfit >= 0 ? primaryGreen : Colors.red,
                    ),
                  ),
                  Text(t.dailyProfit, style: TextStyle(fontSize: 11, color: colors.gray)),
                ],
              ),
            ],
          ),
          if (comparison != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  comparisonColor == const Color(0xFF5BA154) ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: comparisonColor,
                ),
                const SizedBox(width: 4),
                Text(comparison, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: comparisonColor)),
              ],
            ),
          ],
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

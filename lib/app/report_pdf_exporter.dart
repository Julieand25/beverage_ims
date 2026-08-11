import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

String _monthName(int month, bool isMs) {
  if (isMs) {
    const months = ['', 'Januari', 'Februari', 'Mac', 'April', 'Mei', 'Jun', 'Julai', 'Ogos', 'September', 'Oktober', 'November', 'Disember'];
    return months[month];
  }
  const months = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return months[month];
}

class ReportPdfExporter {
  static const _green = PdfColor.fromInt(0xFF5BA154);
  static const _pink = PdfColor.fromInt(0xFFE27387);
  static const _blue = PdfColor.fromInt(0xFF2196F3);
  static const _red = PdfColor.fromInt(0xFFE53935);
  static const _grey = PdfColor.fromInt(0xFF757575);
  static const _lightGreen = PdfColor.fromInt(0xFFE8F5E9);

  static String _fmt(double v) => v.toStringAsFixed(2);
  static String _dateStr(DateTime d) => '${d.day}/${d.month}/${d.year}';
  static String _timeStr(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static pw.Widget _sectionTitle(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _grey),
      ),
    );
  }

  static pw.Widget _statBox(String title, String value, String? comparison, PdfColor color, {bool isMs = false}) {
    final isUp = comparison != null && !comparison.startsWith('-');
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 9, color: _grey)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
          if (comparison != null)
            pw.Text(
              isUp ? '\u25B2 $comparison' : '\u25BC $comparison',
              style: pw.TextStyle(fontSize: 8, color: isUp ? _green : _red),
            ),
        ],
      ),
    );
  }

  static pw.TableRow _tableHeader(List<String> headers) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: _lightGreen),
      children: headers.map((h) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: pw.Text(h, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _green)),
      )).toList(),
    );
  }

  static pw.TableRow _tableRow(List<String> cells, {int highlightIndex = -1}) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        border: const pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
      ),
      children: List.generate(cells.length, (i) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: pw.Text(
          cells[i],
          style: pw.TextStyle(
            fontSize: 10,
            color: i == highlightIndex ? _green : PdfColors.black,
            fontWeight: i == highlightIndex ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      )),
    );
  }

  static Future<Uint8List> _generatePdf(List<pw.Widget> Function(pw.Context context) builder) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => builder(context),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(right: 20, bottom: 10),
          child: pw.Text(
            '${_dateStr(DateTime.now())} ${_timeStr(DateTime.now())}',
            style: pw.TextStyle(fontSize: 8, color: _grey),
          ),
        ),
      ),
    );
    return pdf.save();
  }

  static Future<void> previewPdf(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  static Future<Uint8List> generateDailyReport({
    required DateTime date,
    required bool isMs,
    required double sales,
    required double cost,
    required double profit,
    required int cups,
    required double yesterdaySales,
    required double yesterdayCogs,
    required double yesterdayProfit,
    required int yesterdayCups,
    required List<Map<String, dynamic>> bestSellers,
    required List<Map<String, dynamic>> transactions,
    required String unknownItemLabel,
    required String cupUnit,
  }) async {
    final marginPct = sales > 0 ? (profit / sales * 100).toStringAsFixed(1) : null;
    final salesComp = _changePct(sales, yesterdaySales);
    final costComp = yesterdayCogs > 0 ? _changePct(cost, yesterdayCogs) : null;
    final profitComp = _changePct(profit, yesterdayProfit);
    final cupsComp = yesterdayCups > 0 ? _changePctInt(cups, yesterdayCups) : null;

    return _generatePdf((context) => [
      pw.Header(text: 'Daily Report', child: pw.Text('Daily Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _green))),
      pw.SizedBox(height: 4),
      pw.Text('${_dateStr(date)}  (${_monthName(date.month, isMs)} ${date.year})', style: const pw.TextStyle(fontSize: 12)),
      _sectionTitle('SUMMARY'),
      pw.Row(
        children: [
          pw.Expanded(child: _statBox('Total Sales', 'RM ${_fmt(sales)}', salesComp, _green, isMs: isMs)),
          pw.SizedBox(width: 8),
          pw.Expanded(child: _statBox('Cost of Goods', 'RM ${_fmt(cost)}', costComp, _pink, isMs: isMs)),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        children: [
          pw.Expanded(child: _statBox(
            profit >= 0 ? 'Gross Profit' : 'Gross Profit',
            'RM ${_fmt(profit)}${marginPct != null ? '  ($marginPct%)' : ''}',
            profitComp,
            profit >= 0 ? _green : _red,
            isMs: isMs,
          )),
          pw.SizedBox(width: 8),
          pw.Expanded(child: _statBox('Cups Sold', '$cups $cupUnit', cupsComp, _blue, isMs: isMs)),
        ],
      ),
      if (bestSellers.isNotEmpty) ...[
        _sectionTitle('BEST SELLING MENU'),
        pw.Table(
          columnWidths: {0: const pw.FlexColumnWidth(1), 1: const pw.FlexColumnWidth(3), 2: const pw.FlexColumnWidth(2), 3: const pw.FlexColumnWidth(2)},
          children: <pw.TableRow>[
            _tableHeader(['#', 'Menu', 'Cups', 'Revenue']),
            ...List<pw.TableRow>.from(bestSellers.asMap().entries.map((e) => _tableRow(
              [
                '${e.key + 1}',
                e.value['recipe_name'] as String,
                '${e.value['total_cups']} $cupUnit',
                'RM ${_fmt((e.value['total_revenue'] as num).toDouble())}',
              ],
            ))),
          ],
        ),
      ],
      if (transactions.isNotEmpty) ...[
        _sectionTitle('TRANSACTIONS'),
        pw.Table(
          columnWidths: {0: const pw.FlexColumnWidth(2), 1: const pw.FlexColumnWidth(3), 2: const pw.FlexColumnWidth(1), 3: const pw.FlexColumnWidth(2)},
          children: <pw.TableRow>[
            _tableHeader(['Time', 'Item', 'Qty', 'Amount']),
            ...List<pw.TableRow>.from(transactions.map((tx) {
              final recipeName = tx['recipes']?['name'] as String? ?? unknownItemLabel;
              final qty = tx['quantity'] as int;
              final amount = (tx['total_amount'] as num).toDouble();
              final soldAt = DateTime.parse(tx['sold_at'] as String);
              return _tableRow([
                _timeStr(soldAt),
                recipeName,
                'x$qty',
                'RM ${_fmt(amount)}',
              ], highlightIndex: 3);
            })),
          ],
        ),
      ],
    ]);
  }

  static Future<Uint8List> generateStockHistory({
    required bool isMs,
    required List<Map<String, dynamic>> movements,
    required String unknownItemLabel,
    required String restockLabel,
    required String deductionLabel,
    required String adjustmentLabel,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final rangeLabel = (startDate != null && endDate != null)
        ? '${_dateStr(startDate)} - ${_dateStr(endDate)}'
        : (startDate != null)
            ? 'From ${_dateStr(startDate)}'
            : (endDate != null)
                ? 'Until ${_dateStr(endDate)}'
                : 'All Time';

    return _generatePdf((context) => [
      pw.Header(text: 'Stock History', child: pw.Text('Stock History', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _green))),
      pw.SizedBox(height: 4),
      pw.Text(rangeLabel, style: const pw.TextStyle(fontSize: 12)),
      _sectionTitle('STOCK MOVEMENTS'),
      if (movements.isEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 32),
          child: pw.Text('No stock records', style: const pw.TextStyle(fontSize: 11, color: _grey)),
        )
      else
        pw.Table(
          columnWidths: {0: const pw.FlexColumnWidth(3), 1: const pw.FlexColumnWidth(3), 2: const pw.FlexColumnWidth(2), 3: const pw.FlexColumnWidth(2)},
          children: [
            _tableHeader(['Date / Time', 'Item', 'Type', 'Qty']),
            ...List<pw.TableRow>.from(movements.map((m) {
              final type = m['type'] as String? ?? '';
              final itemName = m['inventory_items']?['name'] ?? unknownItemLabel;
              final qty = (m['quantity'] as num).toDouble();
              final movedAt = DateTime.parse(m['moved_at'] as String);

              final bool isUp;
              final String label;
              if (type == 'restock') {
                isUp = true;
                label = restockLabel;
              } else if (type == 'adjustment') {
                isUp = qty > 0;
                label = adjustmentLabel;
              } else {
                isUp = false;
                label = deductionLabel;
              }

              return _tableRow([
                '${_dateStr(movedAt)} ${_timeStr(movedAt)}',
                itemName,
                label,
                '${isUp ? "+" : "-"}${qty.abs().toStringAsFixed(0)}',
              ], highlightIndex: -1);
            })),
          ],
        ),
    ]);
  }

  static Future<Uint8List> generateMonthlySummary({
    required DateTime month,
    required bool isMs,
    required double revenue,
    required double cogs,
    required double profit,
    required double lastMonthRevenue,
    required double lastMonthCogs,
    required double lastMonthProfit,
    required Map<int, Map<String, double>> weeklyStats,
  }) async {
    final marginPct = revenue > 0 ? (profit / revenue * 100).toStringAsFixed(1) : null;
    String? revComp;
    if (lastMonthRevenue > 0) {
      final pct = ((revenue - lastMonthRevenue) / lastMonthRevenue * 100);
      final sign = pct >= 0 ? '+' : '';
      revComp = '$sign${pct.toStringAsFixed(1)}%';
    }

    return _generatePdf((context) => [
      pw.Header(
        text: 'Monthly Summary',
        child: pw.Text('Monthly Summary', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _green)),
      ),
      pw.SizedBox(height: 4),
      pw.Text('${_monthName(month.month, isMs)} ${month.year}', style: const pw.TextStyle(fontSize: 12)),
      _sectionTitle('OVERVIEW'),
      pw.Row(
        children: [
          pw.Expanded(
            child: _statBox('Total Revenue', 'RM ${_fmt(revenue)}', revComp != null ? 'vs Last Month: $revComp' : null, _green, isMs: isMs),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: _statBox(
              'Gross Profit',
              'RM ${_fmt(profit)}${marginPct != null ? '  ($marginPct%)' : ''}',
              null,
              profit >= 0 ? _green : _red,
              isMs: isMs,
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        children: [
          pw.Expanded(child: _statBox('Ingredient Cost', 'RM ${_fmt(cogs)}', null, _pink, isMs: isMs)),
          pw.SizedBox(width: 8),
          pw.Expanded(child: pw.SizedBox.shrink()),
        ],
      ),
      _sectionTitle('WEEKLY BREAKDOWN'),
      pw.Table(
        columnWidths: {0: const pw.FlexColumnWidth(2), 1: const pw.FlexColumnWidth(3), 2: const pw.FlexColumnWidth(3)},
        children: [
          _tableHeader(['Week', 'Revenue', 'Cost']),
          for (final w in [1, 2, 3, 4])
            _tableRow([
              'Wk $w',
              weeklyStats[w] != null ? 'RM ${_fmt(weeklyStats[w]!['revenue'] ?? 0)}' : '-',
              weeklyStats[w] != null ? 'RM ${_fmt(weeklyStats[w]!['cost'] ?? 0)}' : '-',
            ]),
        ],
      ),
    ]);
  }

  static Future<Uint8List> generateAllReports({
    required DateTime dailyDate,
    required DateTime monthlyMonth,
    required bool isMs,
    required double sales,
    required double cost,
    required double profit,
    required int cups,
    required double yesterdaySales,
    required double yesterdayCogs,
    required double yesterdayProfit,
    required int yesterdayCups,
    required List<Map<String, dynamic>> bestSellers,
    required List<Map<String, dynamic>> transactions,
    required List<Map<String, dynamic>> movements,
    required double monthlyRevenue,
    required double monthlyCogs,
    required double monthlyProfit,
    required double lastMonthRevenue,
    required double lastMonthCogs,
    required double lastMonthProfit,
    required Map<int, Map<String, double>> weeklyStats,
    required String unknownItemLabel,
    required String cupUnit,
    required String restockLabel,
    required String deductionLabel,
    required String adjustmentLabel,
    DateTime? stockStartDate,
    DateTime? stockEndDate,
  }) async {
    final pdf = pw.Document();
    final marginPct = sales > 0 ? (profit / sales * 100).toStringAsFixed(1) : null;
    final salesComp = _changePct(sales, yesterdaySales);
    final costComp = yesterdayCogs > 0 ? _changePct(cost, yesterdayCogs) : null;
    final profitComp = _changePct(profit, yesterdayProfit);
    final cupsComp = yesterdayCups > 0 ? _changePctInt(cups, yesterdayCups) : null;

    // -- Daily Report Page --
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Daily Report', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _green)),
          pw.SizedBox(height: 4),
          pw.Text('${_dateStr(dailyDate)}  (${_monthName(dailyDate.month, isMs)} ${dailyDate.year})', style: const pw.TextStyle(fontSize: 12)),
          _sectionTitle('SUMMARY'),
          pw.Row(
            children: [
              pw.Expanded(child: _statBox('Total Sales', 'RM ${_fmt(sales)}', salesComp, _green)),
              pw.SizedBox(width: 8),
              pw.Expanded(child: _statBox('Cost of Goods', 'RM ${_fmt(cost)}', costComp, _pink)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(child: _statBox(
                'Gross Profit',
                'RM ${_fmt(profit)}${marginPct != null ? '  ($marginPct%)' : ''}',
                profitComp,
                profit >= 0 ? _green : _red,
              )),
              pw.SizedBox(width: 8),
              pw.Expanded(child: _statBox('Cups Sold', '$cups $cupUnit', cupsComp, _blue)),
            ],
          ),
          if (bestSellers.isNotEmpty) ...[
            _sectionTitle('BEST SELLING MENU'),
            pw.Table(
              defaultColumnWidth: const pw.FlexColumnWidth(),
              children: [
                _tableHeader(['#', 'Menu', 'Cups', 'Revenue']),
                ...bestSellers.asMap().entries.map((e) => _tableRow([
                  '${e.key + 1}',
                  e.value['recipe_name'] as String,
                  '${e.value['total_cups']} $cupUnit',
                  'RM ${_fmt((e.value['total_revenue'] as num).toDouble())}',
                ])),
              ],
            ),
          ],
          if (transactions.isNotEmpty) ...[
            _sectionTitle('TRANSACTIONS'),
            pw.Table(
              defaultColumnWidth: const pw.FlexColumnWidth(),
              children: [
                _tableHeader(['Time', 'Item', 'Qty', 'Amount']),
                ...transactions.map((tx) {
                  final recipeName = tx['recipes']?['name'] as String? ?? unknownItemLabel;
                  return _tableRow([
                    _timeStr(DateTime.parse(tx['sold_at'] as String)),
                    recipeName,
                    'x${tx['quantity']}',
                    'RM ${_fmt((tx['total_amount'] as num).toDouble())}',
                  ], highlightIndex: 3);
                }),
              ],
            ),
          ],
        ],
      ),
    );

    // -- Stock History Page --
    final rangeLabel = (stockStartDate != null && stockEndDate != null)
        ? '${_dateStr(stockStartDate)} - ${_dateStr(stockEndDate)}'
        : 'All Time';
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Stock History', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _green)),
          pw.SizedBox(height: 4),
          pw.Text(rangeLabel, style: const pw.TextStyle(fontSize: 12)),
          _sectionTitle('STOCK MOVEMENTS'),
          if (movements.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 32),
              child: pw.Text('No stock records', style: const pw.TextStyle(fontSize: 11, color: _grey)),
            )
          else
            pw.Table(
              defaultColumnWidth: const pw.FlexColumnWidth(),
              children: [
                _tableHeader(['Date / Time', 'Item', 'Type', 'Qty']),
                ...List<pw.TableRow>.from(movements.map((m) {
                  final type = m['type'] as String? ?? '';
                  final itemName = m['inventory_items']?['name'] ?? unknownItemLabel;
                  final qty = (m['quantity'] as num).toDouble();
                  final movedAt = DateTime.parse(m['moved_at'] as String);

                  final bool isUp;
                  final String label;
                  if (type == 'restock') {
                    isUp = true;
                    label = restockLabel;
                  } else if (type == 'adjustment') {
                    isUp = qty > 0;
                    label = adjustmentLabel;
                  } else {
                    isUp = false;
                    label = deductionLabel;
                  }

                  return _tableRow([
                    '${_dateStr(movedAt)} ${_timeStr(movedAt)}',
                    itemName,
                    label,
                    '${isUp ? "+" : "-"}${qty.abs().toStringAsFixed(0)}',
                  ]);
                })),
              ],
            ),
        ],
      ),
    );

    // -- Monthly Summary Page --
    final monthMarginPct = monthlyRevenue > 0 ? (monthlyProfit / monthlyRevenue * 100).toStringAsFixed(1) : null;
    String? monthRevComp;
    if (lastMonthRevenue > 0) {
      final pct = ((monthlyRevenue - lastMonthRevenue) / lastMonthRevenue * 100);
      final sign = pct >= 0 ? '+' : '';
      monthRevComp = '$sign${pct.toStringAsFixed(1)}%';
    }
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Monthly Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _green)),
          pw.SizedBox(height: 4),
          pw.Text('${_monthName(monthlyMonth.month, isMs)} ${monthlyMonth.year}', style: const pw.TextStyle(fontSize: 12)),
          _sectionTitle('OVERVIEW'),
          pw.Row(
            children: [
              pw.Expanded(
                child: _statBox('Total Revenue', 'RM ${_fmt(monthlyRevenue)}',
                    monthRevComp != null ? 'vs Last Month: $monthRevComp' : null, _green),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _statBox('Gross Profit', 'RM ${_fmt(monthlyProfit)}${monthMarginPct != null ? '  ($monthMarginPct%)' : ''}', null,
                    monthlyProfit >= 0 ? _green : _red),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(child: _statBox('Ingredient Cost', 'RM ${_fmt(monthlyCogs)}', null, _pink)),
              pw.SizedBox(width: 8),
              pw.Expanded(child: pw.SizedBox.shrink()),
            ],
          ),
          _sectionTitle('WEEKLY BREAKDOWN'),
          pw.Table(
            defaultColumnWidth: const pw.FlexColumnWidth(),
            children: [
              _tableHeader(['Week', 'Revenue', 'Cost']),
              for (final w in [1, 2, 3, 4])
                _tableRow([
                  'Wk $w',
                  weeklyStats[w] != null ? 'RM ${_fmt(weeklyStats[w]!['revenue'] ?? 0)}' : '-',
                  weeklyStats[w] != null ? 'RM ${_fmt(weeklyStats[w]!['cost'] ?? 0)}' : '-',
                ]),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static String? _changePct(double today, double yesterday) {
    if (yesterday == 0) return null;
    final pct = ((today - yesterday) / yesterday) * 100;
    final sign = pct >= 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(1)}%';
  }

  static String? _changePctInt(int today, int yesterday) {
    if (yesterday == 0) return null;
    final pct = ((today - yesterday) / yesterday) * 100;
    final sign = pct >= 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(1)}%';
  }
}

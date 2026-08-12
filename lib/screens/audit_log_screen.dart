import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/audit_provider.dart';
import '../app/models/audit_log.dart';
import '../app/translations.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  DateTime? _selectedDate;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final provider = context.watch<AuditProvider>();
    final colors = Theme.of(context).extension<AppColors>()!;

    var filteredLogs = provider.logs;

    if (_selectedDate != null) {
      filteredLogs = filteredLogs.where((log) {
        return log.timestamp.year == _selectedDate!.year &&
            log.timestamp.month == _selectedDate!.month &&
            log.timestamp.day == _selectedDate!.day;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filteredLogs = filteredLogs.where((log) {
        return log.userName.toLowerCase().contains(q) ||
            log.action.toLowerCase().contains(q) ||
            log.targetType.toLowerCase().contains(q) ||
            log.details.values.any((v) => v.toString().toLowerCase().contains(q));
      }).toList();
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Icon(Icons.arrow_back_ios, size: 20, color: colors.text),
        ),
        centerTitle: true,
        title: Text(
          t.viewAuditLogs,
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.calendar_today, size: 20, color: colors.text),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: t.searchItem,
                    hintStyle: TextStyle(fontSize: 14, color: colors.gray),
                    prefixIcon: Icon(Icons.search, size: 20, color: colors.gray),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: Icon(Icons.close, size: 18, color: colors.gray),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            if (_selectedDate != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: colors.card,
                child: Row(
                  children: [
                    Icon(Icons.date_range, size: 16, color: colors.gray),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                      style: TextStyle(fontSize: 13, color: colors.text, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${filteredLogs.length} ${t.recordsUnit})',
                      style: TextStyle(fontSize: 12, color: colors.gray),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _selectedDate = null),
                      child: Icon(Icons.close, size: 18, color: colors.gray),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: filteredLogs.isEmpty
                  ? Center(
                child: Text(
                  t.emptyAudit,
                        style: TextStyle(color: colors.gray, fontSize: 14),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => provider.loadAll(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          return _AuditLogCard(log: log);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  final AuditLog log;
  const _AuditLogCard({required this.log});

  Color _actionColor(String action) {
    switch (action) {
      case 'LOGIN':
      case 'SIGN_OUT':
        return Colors.blue;
      case 'ADD_ITEM':
      case 'RESTOCK_ITEM':
      case 'ADD_RECIPE':
        return const Color(0xFF5BA154);
      case 'STOCK_ADJUST':
        return Colors.teal;
      case 'EDIT_ITEM':
      case 'EDIT_RECIPE':
        return Colors.orange;
      case 'DELETE_ITEM':
      case 'DELETE_RECIPE':
        return Colors.red;
      case 'RECORD_SALE':
        return const Color(0xFFE27387);
      case 'CHANGE_PASSWORD':
        return Colors.purple;
      case 'REGISTER_STAFF':
        return Colors.indigo;
      case 'UPDATE_NAME':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  String _actionEmoji(String action) {
    switch (action) {
      case 'LOGIN':
        return '\u{1F511}';
      case 'SIGN_OUT':
        return '\u{1F44B}';
      case 'ADD_ITEM':
      case 'RESTOCK_ITEM':
        return '\u{1F4E6}';
      case 'STOCK_ADJUST':
        return '\u{2699}';
      case 'ADD_RECIPE':
        return '\u{1F4CB}';
      case 'EDIT_ITEM':
      case 'EDIT_RECIPE':
        return '\u{270F}';
      case 'DELETE_ITEM':
      case 'DELETE_RECIPE':
        return '\u{1F5D1}';
      case 'RECORD_SALE':
        return '\u{1F4B0}';
      case 'CHANGE_PASSWORD':
        return '\u{1F512}';
      case 'REGISTER_STAFF':
        return '\u{1F464}';
      case 'UPDATE_NAME':
        return '\u{1F4DD}';
      default:
        return '\u{1F4CC}';
    }
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'LOGIN': return 'Login';
      case 'SIGN_OUT': return 'Sign Out';
      case 'ADD_ITEM': return 'Add Item';
      case 'RESTOCK_ITEM': return 'Restock';
      case 'STOCK_ADJUST': return 'Adjust Stock';
      case 'ADD_RECIPE': return 'Add Recipe';
      case 'EDIT_ITEM': return 'Edit Item';
      case 'EDIT_RECIPE': return 'Edit Recipe';
      case 'DELETE_ITEM': return 'Delete Item';
      case 'DELETE_RECIPE': return 'Delete Recipe';
      case 'RECORD_SALE': return 'Record Sale';
      case 'CHANGE_PASSWORD': return 'Change Password';
      case 'REGISTER_STAFF': return 'Register Staff';
      case 'UPDATE_NAME': return 'Update Name';
      default: return action;
    }
  }

  String _detailsText() {
    if (log.details.isEmpty) return '';
    final parts = <String>[];
    log.details.forEach((k, v) {
      if (v is Map) {
        final sub = v.entries.map((e) => '${e.key}: ${e.value}').join(', ');
        if (sub.isNotEmpty) parts.add(sub);
      } else if (v is String && v.isNotEmpty) {
        parts.add(v);
      } else if (v is num) {
        parts.add(v.toString());
      }
    });
    return parts.join('  |  ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final actionColor = _actionColor(log.action);
    final details = _detailsText();

    final timeStr =
        '${log.timestamp.day.toString().padLeft(2, '0')}/${log.timestamp.month.toString().padLeft(2, '0')}/${log.timestamp.year} '
        '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: actionColor.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(_actionEmoji(log.action), style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: colors.text,
                        ),
                      ),
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(fontSize: 11, color: colors.gray),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: actionColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _actionLabel(log.action),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: actionColor,
                        ),
                      ),
                    ),
                    if (log.targetType.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        log.targetType,
                        style: TextStyle(fontSize: 11, color: colors.gray),
                      ),
                    ],
                  ],
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    details,
                    style: TextStyle(fontSize: 11, color: colors.gray, fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

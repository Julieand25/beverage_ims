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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final provider = context.watch<AuditProvider>();
    final colors = Theme.of(context).extension<AppColors>()!;

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
      ),
      body: SafeArea(
        child: provider.logs.isEmpty
            ? Center(
                child: Text(
                  t.isMs ? 'Tiada rekod audit' : 'No audit records',
                  style: TextStyle(color: colors.gray, fontSize: 14),
                ),
              )
            : RefreshIndicator(
                onRefresh: () => provider.loadAll(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: provider.logs.length,
                  itemBuilder: (context, index) {
                    final log = provider.logs[index];
                    return _AuditLogCard(log: log);
                  },
                ),
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
      case 'RESTOCK':
      case 'ADD_RECIPE':
        return const Color(0xFF5BA154);
      case 'EDIT_RECIPE':
      case 'DELETE_RECIPE':
        return Colors.orange;
      case 'RECORD_SALE':
        return const Color(0xFFE27387);
      case 'CHANGE_PASSWORD':
        return Colors.purple;
      case 'REGISTER_STAFF':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _actionEmoji(String action) {
    switch (action) {
      case 'LOGIN':
        return '🔑';
      case 'SIGN_OUT':
        return '👋';
      case 'ADD_ITEM':
      case 'RESTOCK':
        return '📦';
      case 'ADD_RECIPE':
      case 'EDIT_RECIPE':
      case 'DELETE_RECIPE':
        return '📋';
      case 'RECORD_SALE':
        return '💰';
      case 'CHANGE_PASSWORD':
        return '🔒';
      case 'REGISTER_STAFF':
        return '👤';
      default:
        return '📌';
    }
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'LOGIN':
        return 'Login';
      case 'SIGN_OUT':
        return 'Sign Out';
      case 'ADD_ITEM':
        return 'Add Item';
      case 'RESTOCK':
        return 'Restock';
      case 'ADD_RECIPE':
        return 'Add Recipe';
      case 'EDIT_RECIPE':
        return 'Edit Recipe';
      case 'DELETE_RECIPE':
        return 'Delete Recipe';
      case 'RECORD_SALE':
        return 'Record Sale';
      case 'CHANGE_PASSWORD':
        return 'Change Password';
      case 'REGISTER_STAFF':
        return 'Register Staff';
      default:
        return action;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final actionColor = _actionColor(log.action);

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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

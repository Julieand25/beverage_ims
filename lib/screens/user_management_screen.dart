import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/auth_provider.dart';
import '../app/models/user.dart';
import '../app/translations.dart';
import '../app/user_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadAllUsers();
    });
  }

  void _showUserActions(User user) {
    final t = Translations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    final primaryGreen = const Color(0xFF5BA154);
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;
    final isSelf = currentUser?.id == user.id;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.gray.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: primaryGreen.withAlpha(30),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryGreen),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.text),
                ),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 13, color: colors.gray),
                ),
                const SizedBox(height: 16),
                if (isSelf)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      t.isMs ? 'Ini adalah akaun anda sendiri.' : 'This is your own account.',
                      style: TextStyle(fontSize: 12, color: colors.gray, fontStyle: FontStyle.italic),
                    ),
                  ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(Icons.admin_panel_settings, color: isSelf ? colors.gray : colors.text),
                  title: Text(t.changeRole, style: TextStyle(fontSize: 14, color: isSelf ? colors.gray : colors.text)),
                  subtitle: Text(
                    '${t.role}: ${user.role == UserRole.admin ? 'Admin' : 'Staff'}',
                    style: TextStyle(fontSize: 12, color: colors.gray),
                  ),
                  enabled: !isSelf,
                  onTap: isSelf
                      ? null
                      : () {
                          Navigator.pop(ctx);
                          _confirmChangeRole(user);
                        },
                ),
                ListTile(
                  leading: Icon(
                    user.isActive ? Icons.block : Icons.check_circle_outline,
                    color: user.isActive ? Colors.red : primaryGreen,
                  ),
                  title: Text(
                    user.isActive ? t.deactivateUser : t.activateUser,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelf ? colors.gray : (user.isActive ? Colors.red : primaryGreen),
                    ),
                  ),
                  subtitle: Text(
                    '${t.status}: ${user.isActive ? t.active : t.deactivated}',
                    style: TextStyle(fontSize: 12, color: colors.gray),
                  ),
                  enabled: !isSelf,
                  onTap: isSelf
                      ? null
                      : () {
                          Navigator.pop(ctx);
                          _confirmToggleActive(user);
                        },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmChangeRole(User user) {
    final t = Translations.of(context);
    final newRole = user.role == UserRole.admin ? 'staff' : 'admin';
    final newRoleLabel = user.role == UserRole.admin ? 'Staff' : 'Admin';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.changeRole),
        content: Text(
          t.isMs
              ? 'Tukar peranan ${user.name} kepada $newRoleLabel?'
              : 'Change ${user.name}\'s role to $newRoleLabel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = context.read<AuthProvider>();
              final currentUser = auth.currentUser;
              if (currentUser == null) return;
              final success = await context.read<UserProvider>().updateUserRole(
                user.id,
                newRole,
                currentUser.id,
                currentUser.name,
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? t.roleChanged : t.roleUpdateFailed),
                  backgroundColor: success ? const Color(0xFF5BA154) : Colors.red,
                ),
              );
            },
            child: Text(t.save),
          ),
        ],
      ),
    );
  }

  void _confirmToggleActive(User user) {
    final t = Translations.of(context);
    final willBeActive = !user.isActive;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(willBeActive ? t.activateUser : t.deactivateUser),
        content: Text(willBeActive ? t.confirmActivate : t.confirmDeactivate),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = context.read<AuthProvider>();
              final currentUser = auth.currentUser;
              if (currentUser == null) return;
              final success = await context.read<UserProvider>().toggleUserActive(
                user.id,
                willBeActive,
                currentUser.id,
                currentUser.name,
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? t.statusChanged : t.statusUpdateFailed),
                  backgroundColor: success ? const Color(0xFF5BA154) : Colors.red,
                ),
              );
            },
            child: Text(t.save),
          ),
        ],
      ),
    );
  }

  String _formatLastOpen(DateTime? lastOpen, Translations t) {
    if (lastOpen == null) return t.never;
    final now = DateTime.now();
    final diff = now.difference(lastOpen);
    if (diff.inMinutes < 1) return t.isMs ? 'Baru sahaja' : 'Just now';
    if (diff.inMinutes < 60) return t.isMs ? '${diff.inMinutes} minit lepas' : '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return t.isMs ? '${diff.inHours} jam lepas' : '${diff.inHours}h ago';
    if (diff.inDays < 7) return t.isMs ? '${diff.inDays} hari lepas' : '${diff.inDays}d ago';
    return '${lastOpen.day}/${lastOpen.month}/${lastOpen.year}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final provider = context.watch<UserProvider>();
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
          t.userManagementTitle,
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: !provider.isLoaded
            ? const Center(child: CircularProgressIndicator())
            : provider.users.isEmpty
                ? Center(
                    child: Text(
                      t.emptyAudit,
                      style: TextStyle(color: colors.gray, fontSize: 14),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => provider.loadAllUsers(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: provider.users.length,
                      itemBuilder: (context, index) {
                        final user = provider.users[index];
                        return _UserCard(
                          user: user,
                          lastOpenedText: _formatLastOpen(user.lastOpen, t),
                          onTap: () => _showUserActions(user),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final String lastOpenedText;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.lastOpenedText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    const primaryGreen = Color(0xFF5BA154);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: primaryGreen.withAlpha(30),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: user.isActive ? primaryGreen : Colors.red,
                          border: Border.all(color: colors.card, width: 2),
                        ),
                      ),
                    ),
                  ],
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
                              user.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: colors.text,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: user.role == UserRole.admin
                                  ? Colors.amber.withAlpha(30)
                                  : primaryGreen.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.role == UserRole.admin ? 'Admin' : 'Staff',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: user.role == UserRole.admin ? Colors.amber[800] : primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 12, color: colors.gray),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: colors.gray),
                          const SizedBox(width: 4),
                          Text(
                            '${t.lastOpened}: $lastOpenedText',
                            style: TextStyle(fontSize: 11, color: colors.gray),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 20, color: colors.gray),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

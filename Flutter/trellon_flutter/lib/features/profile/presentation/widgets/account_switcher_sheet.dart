import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/saved_account.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../routes.dart';

class AccountSwitcherSheet extends StatefulWidget {
  const AccountSwitcherSheet({super.key});

  @override
  State<AccountSwitcherSheet> createState() => _AccountSwitcherSheetState();
}

class _AccountSwitcherSheetState extends State<AccountSwitcherSheet> {
  final _sessionManager = SessionManager();
  List<SavedAccount> _accounts = [];
  String? _activeUserUId;
  bool _isSwitching = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final accounts = await _sessionManager.getSavedAccounts();
    final activeUId = await _sessionManager.getActiveUserUId();
    if (mounted) {
      setState(() {
        _accounts = accounts;
        _activeUserUId = activeUId;
      });
    }
  }

  Future<void> _switchAccount(SavedAccount account) async {
    if (account.userUId == _activeUserUId) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _isSwitching = true);
    final ok = await _sessionManager.switchTo(account);
    if (!mounted) return;

    if (!ok) {
      setState(() => _isSwitching = false);
      if (!mounted) return;
      // Token hết hạn → chuyển sang trang đăng nhập với email được điền sẵn
      Navigator.of(context).pop(); // Đóng sheet
      Navigator.of(context, rootNavigator: true).pushNamed(
        AppRoutes.login,
        arguments: account.email, // LoginPage đọc args để pre-fill email
      );
      return;
    }

    // Close sheet and navigate to home, wiping the back stack.
    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
  }

  Future<void> _removeAccount(SavedAccount account) async {
    if (account.userUId == _activeUserUId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa tài khoản đang hoạt động.'),
        ),
      );
      return;
    }
    await _sessionManager.removeAccount(account.userUId);
    await _load();
  }

  void _addAccount() {
    Navigator.of(context).pop();
    Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(99),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.switch_account_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Chuyển tài khoản',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceContainer),

          if (_isSwitching)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            // Account list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _accounts.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  indent: 72,
                  color: AppColors.surfaceContainer,
                ),
                itemBuilder: (context, i) =>
                    _buildAccountTile(_accounts[i]),
              ),
            ),

            const Divider(height: 1, color: AppColors.surfaceContainer),

            // Add account
            InkWell(
              onTap: _addAccount,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Thêm tài khoản',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildAccountTile(SavedAccount account) {
    final isActive = account.userUId == _activeUserUId;

    return Dismissible(
      key: ValueKey(account.userUId),
      direction: isActive
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.error.withValues(alpha: 0.08),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'Xóa tài khoản?',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            content: Text(
              'Tài khoản "${account.userName}" sẽ bị xóa khỏi thiết bị.',
              style: GoogleFonts.inter(),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'Hủy',
                  style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  'Xóa',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
            false;
      },
      onDismissed: (_) => _removeAccount(account),
      child: InkWell(
        onTap: () => _switchAccount(account),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(account),
              const SizedBox(width: 14),

              // Name + email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.userName.isEmpty ? 'Người dùng' : account.userName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account.email,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Active badge or chevron
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Đang dùng',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.outlineVariant,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(SavedAccount account) {
    final initial = (account.userName.isNotEmpty
        ? account.userName[0]
        : account.email.isNotEmpty
            ? account.email[0]
            : '?'
    ).toUpperCase();

    return Stack(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          backgroundImage: account.avatarUrl.isNotEmpty
              ? CachedNetworkImageProvider(account.avatarUrl)
              : null,
          child: account.avatarUrl.isEmpty
              ? Text(
                  initial,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        if (account.userUId == _activeUserUId)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

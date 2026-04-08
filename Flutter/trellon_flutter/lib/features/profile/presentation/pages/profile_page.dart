import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 40),
                    _buildWorkspacesGroup(context),
                    const SizedBox(height: 24),
                    _buildAccountSettingsGroup(),
                    const SizedBox(height: 24),
                    _buildPreferencesGroup(),
                    const SizedBox(height: 24),
                    _buildSupportGroup(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F2F4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.grid_view_rounded,
            color: Color(0xFF1D4ED8),
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            'Workspace',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  width: 4,
                ),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    'https://i.pravatar.cc/150?u=jordan',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Trần Nguyễn',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@trannguyen_work',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ── Groups ───────────────────────────────────────────────────────────────

  Widget _buildWorkspacesGroup(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('KHÔNG GIAN LÀM VIỆC'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildWorkspaceItem(
                'Thiết kế & UI/UX',
                'Đang hoạt động',
                const Color(0xFF2563EB),
                true,
                true,
                () {
                  Navigator.pushNamed(context, '/workspace-menu');
                },
              ),
              _buildDivider(),
              _buildWorkspaceItem(
                'Engineering Workspace',
                'Chuyển không gian',
                const Color(0xFF059669),
                false,
                true,
                () {
                  Navigator.pushNamed(context, '/workspace-menu');
                },
              ),
              _buildDivider(),
              _buildAddItem('Tạo không gian làm việc mới'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettingsGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('CÀI ĐẶT TÀI KHOẢN'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                Icons.person_rounded,
                'Thông tin cá nhân',
                'Tên, email và ảnh',
                AppColors.primaryContainer.withValues(alpha: 0.1),
                AppColors.primaryContainer,
              ),
              _buildDivider(),
              _buildSettingItem(
                Icons.security_rounded,
                'Bảo mật',
                'Mật khẩu và 2FA',
                AppColors.primaryContainer.withValues(alpha: 0.1),
                AppColors.primaryContainer,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('TÙY CHỌN'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                Icons.dark_mode_rounded,
                'Giao diện',
                'Hệ thống, Sáng, Tối',
                const Color(0xFFD2E0FC),
                const Color(0xFF0D1C30),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Sáng',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              _buildDivider(),
              _buildSettingItem(
                Icons.notifications_rounded,
                'Thông báo',
                'Desktop, Email, Mobile',
                const Color(0xFFD2E0FC),
                const Color(0xFF0D1C30),
              ),
              _buildDivider(),
              _buildSettingItem(
                Icons.language_rounded,
                'Ngôn ngữ',
                'Tiếng Việt',
                const Color(0xFFD2E0FC),
                const Color(0xFF0D1C30),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('TRỢ GIÚP & HỖ TRỢ'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                Icons.help_rounded,
                'Trung tâm trợ giúp',
                null,
                AppColors.surfaceContainerHigh,
                AppColors.onSurfaceVariant,
                showChevron: false,
              ),
              _buildDivider(),
              _buildSettingItem(
                Icons.logout_rounded,
                'Đăng xuất',
                null,
                const Color(0xFFFFDAD6).withValues(alpha: 0.2),
                AppColors.error,
                showChevron: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helper Widgets ───────────────────────────────────────────────────────

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDivider() =>
      const Divider(height: 1, indent: 64, color: AppColors.surfaceContainer);

  Widget _buildWorkspaceItem(
    String name,
    String subText,
    Color color,
    bool isActive,
    bool hasChevron,
    VoidCallback onTap,
  ) {
    final initial = name.substring(0, 1).toUpperCase();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subText,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 24,
              )
            else if (hasChevron)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.outlineVariant,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddItem(String text) {
    return InkWell(
      onTap: () {},
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String? subtitle,
    Color iconBgColor,
    Color iconColor, {
    Widget? trailing,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                (showChevron
                    ? const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.outlineVariant,
                        size: 24,
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

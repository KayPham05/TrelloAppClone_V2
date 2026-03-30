import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/profile_menu_group_widget.dart';
import '../widgets/profile_section_header_widget.dart';
import '../widgets/profile_user_card_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Mock user data from User.cs
  static const String _userName = 'Phạm Tấn Kha';
  static const String _userEmail = '6451071030@st.utc2.edu.vn';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App Bar ────────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Text(
                  'Tài khoản',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ── User Card ──────────────────────────────────────────
              const ProfileUserCardWidget(
                userName: _userName,
                userEmail: _userEmail,
              ),
              const SizedBox(height: 20),

              // ── Workspace Section ──────────────────────────────────
              const ProfileSectionHeaderWidget(title: 'Không gian làm việc'),
              ProfileMenuGroupWidget(
                items: [
                  ProfileMenuItem(
                    icon: Icons.people_outline,
                    label: 'Không gian làm việc của bạn',
                    onTap: () {},
                    trailing: Icons.chevron_right,
                  ),
                  ProfileMenuItem(
                    icon: Icons.person_outline,
                    label: 'Không gian làm việc của khách',
                    onTap: () {},
                    trailing: Icons.chevron_right,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Settings Section ───────────────────────────────────
              const ProfileSectionHeaderWidget(title: 'Cài đặt và công cụ'),
              ProfileMenuGroupWidget(
                items: [
                  ProfileMenuItem(icon: Icons.settings_outlined, label: 'Cài đặt ứng dụng', onTap: () {}),
                  ProfileMenuItem(icon: Icons.sync_outlined, label: 'Hàng đợi đồng bộ', onTap: () {}),
                  ProfileMenuItem(icon: Icons.build_outlined, label: 'Công cụ cho Nhà phát triển', onTap: () {}, trailing: Icons.chevron_right),
                  ProfileMenuItem(icon: Icons.help_outline, label: 'Giới thiệu và trợ giúp', onTap: () {}, trailing: Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 16),

              // ── Account Management ─────────────────────────────────
              ProfileMenuGroupWidget(
                items: [
                  ProfileMenuItem(
                    icon: Icons.manage_accounts_outlined,
                    label: 'Quản lý tài khoản',
                    onTap: () {},
                    trailingWidget: const Icon(Icons.open_in_new, color: AppColors.textSecondary, size: 16),
                  ),
                  ProfileMenuItem(
                    icon: Icons.delete_outline,
                    label: 'Xóa tài khoản',
                    color: AppColors.error,
                    onTap: () {},
                    trailingWidget: const Icon(Icons.open_in_new, color: AppColors.textSecondary, size: 16),
                  ),
                  ProfileMenuItem(
                    icon: Icons.bolt_outlined,
                    label: 'Tham gia thử nghiệm bản beta',
                    onTap: () {},
                    trailingWidget: const Icon(Icons.open_in_new, color: AppColors.textSecondary, size: 16),
                  ),
                  ProfileMenuItem(
                    icon: Icons.person_add_outlined,
                    label: 'Đăng ký tài khoản mới',
                    color: AppColors.primary,
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    trailing: Icons.chevron_right,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Thông tin ứng dụng ─────────────────────────────────
              const ProfileSectionHeaderWidget(title: 'Thông tin ứng dụng'),
              ProfileMenuGroupWidget(
                items: [
                  ProfileMenuItem(icon: Icons.info_outline, label: 'Phiên bản 1.0.0', onTap: () {}),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

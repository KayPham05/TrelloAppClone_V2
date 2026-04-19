import 'package:apptreolon/core/constants/app_colors.dart';
import 'package:apptreolon/features/profile/presentation/widgets/setting_item_widget.dart';
import 'package:apptreolon/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class SecurityPage extends StatelessWidget{
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1D4ED8),
          )),
        backgroundColor: const Color(0xFFF1F2F4),
        title: Text(
            'Bảo mật',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
              letterSpacing: -0.3,
            ),
          ),

      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 80),
          child: Column(
            children: [
              _buildAccountSettingsGroup(context),
              SizedBox(height: 16,),
              buildTwoFactorialGroup(context)
            ],
          ),
        )
      )
    );
  }
  Widget _buildDivider() =>
    const Divider(height: 1, indent: 64, color: AppColors.surfaceContainer);
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
  Widget _buildAccountSettingsGroup(BuildContext context) {
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
              SettingItem(
              icon: Icons.lock_outline,
              title: 'Đổi mật khẩu',
              iconBgColor: AppColors.primaryContainer.withValues(alpha: 0.1),
              iconColor: AppColors.primaryContainer,
              onTap: (){
                Navigator.pushNamed(context, AppRoutes.changePassPage);
              },
            ),
            _buildDivider(),
            
            SettingItem(
              icon: Icons.email_outlined,
              title: 'Đổi Email',
              iconBgColor: AppColors.primaryContainer.withValues(alpha: 0.1),
              iconColor: AppColors.primaryContainer
            ),
            _buildDivider(),

            SettingItem(
              icon: Icons.phone_outlined,
              title: 'Đổi số điện thoại',
              iconBgColor: AppColors.primaryContainer.withValues(alpha: 0.1),
              iconColor: AppColors.primaryContainer
            ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTwoFactorialGroup(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Xác thực hai lớp'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              SettingItem(
                icon: Icons.shield_outlined,
                title: 'Cài đặt xác thực hai lớp',
                iconBgColor: AppColors.primaryContainer.withValues(alpha: 0.1),
                iconColor: AppColors.primaryContainer
              ),
            ],
          ),
        ),
      ],
    );
  }
}
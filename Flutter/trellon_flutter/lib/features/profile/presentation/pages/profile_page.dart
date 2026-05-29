import 'package:apptreolon/features/profile/presentation/widgets/setting_item_widget.dart';
import 'package:apptreolon/routes.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../init_dependencies.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../activity/presentation/cubit/notification_cubit.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../../features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../../workspace/domain/entities/workspace_entity.dart';
import '../../../board/presentation/widgets/board_list/create_workspace_sheet.dart';
import 'dart:io';
import '../../../../core/utils/image_picker_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isUploadingAvatar = false;

  Future<Map<String, String>> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final nameStr = prefs.getString('user_name');
    final emailStr = prefs.getString('user_email');
    final avatarStr = prefs.getString('user_avatar');

    final name = (nameStr == null || nameStr.isEmpty) ? 'Khách' : nameStr;
    final email = (emailStr == null || emailStr.isEmpty)
        ? 'Chưa cập nhật'
        : emailStr;
    final avatar = avatarStr ?? '';

    return {'name': name, 'email': email, 'avatar': avatar};
  }

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
                    FutureBuilder<Map<String, String>>(
                      future: _getUserInfo(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 150,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final name = snapshot.data?['name'] ?? 'Khách';
                        final email =
                            snapshot.data?['email'] ?? 'Chưa cập nhật';
                        final avatar = snapshot.data?['avatar'] ?? '';

                        return _buildProfileHeader(name, email, avatar);
                      },
                    ),
                    const SizedBox(height: 40),
                    _buildWorkspacesGroup(context),
                    const SizedBox(height: 24),
                    _buildAccountSettingsGroup(context),
                    const SizedBox(height: 24),
                    _buildPreferencesGroup(),
                    const SizedBox(height: 24),
                    _buildSupportGroup(context),
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

  // ── Thêm Avatar Upload vào Header ─────────────────────────────────────────
  Future<void> _pickAndUploadAvatar() async {
    final croppedFile = await ImagePickerHelper.pickAndCropImage();

    if (croppedFile != null) {
      setState(() {
        _isUploadingAvatar = true;
      });

      try {
        final dio = serviceLocator<Dio>();
        String fileName = croppedFile.path.split('/').last;

        FormData formData = FormData.fromMap({
          'avatar': await MultipartFile.fromFile(
            croppedFile.path,
            filename: fileName,
          ),
        });

        final response = await dio.put(
          ApiEndpoints.updateProfile,
          data: formData,
        );

        if (response.statusCode == 200) {
          final data = response.data;
          final prefs = await SharedPreferences.getInstance();
          if (data['avatarUrl'] != null) {
            await prefs.setString('user_avatar', data['avatarUrl']);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật ảnh đại diện thành công')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi cập nhật ảnh: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploadingAvatar = false;
          });
        }
      }
    }
  }

  // BỎ ASYNC VÀ FUTURE Ở ĐÂY, TRUYỀN THAM SỐ VÀO
  Widget _buildProfileHeader(String name, String email, String avatarUrl) {
    ImageProvider avatarImage;
    if (avatarUrl.isNotEmpty) {
      avatarImage = CachedNetworkImageProvider(avatarUrl);
    } else {
      avatarImage = const CachedNetworkImageProvider(
        'https://i.pravatar.cc/150?u=jordan',
      );
    }

    return GestureDetector(
      onTap: _pickAndUploadAvatar,
      child: Column(
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
                  image: DecorationImage(image: avatarImage, fit: BoxFit.cover),
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
                  child: _isUploadingAvatar
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name, // HIỂN THỊ TÊN TỪ THAM SỐ
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email, // HIỂN THỊ EMAIL TỪ THAM SỐ
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ── Groups ───────────────────────────────────────────────────────────────

  void _showCreateWorkspaceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<WorkspaceCubit>(),
        child: const CreateWorkspaceSheet(),
      ),
    );
  }

  Widget _buildWorkspacesGroup(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('KHÔNG GIAN LÀM VIỆC (GẦN ĐÂY)'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: BlocBuilder<WorkspaceCubit, WorkspaceState>(
            builder: (context, state) {
              if (state is WorkspaceLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is WorkspaceLoaded) {
                final allWorkspaces = [...state.personal, ...state.team];
                // Limit to top 3 workspaces
                final topWorkspaces = allWorkspaces.take(3).toList();

                return Column(
                  children: [
                    for (int i = 0; i < topWorkspaces.length; i++) ...[
                      _buildWorkspaceItem(
                        topWorkspaces[i].name,
                        topWorkspaces[i].type == WorkspaceType.personal
                            ? 'Cá nhân'
                            : 'Nhóm',
                        AppColors.primary,
                        false,
                        true,
                        () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.workspaceMenu,
                            arguments: topWorkspaces[i],
                          );
                        },
                      ),
                      _buildDivider(),
                    ],
                    _buildAddItem(
                      'Tạo không gian làm việc mới',
                      onTap: _showCreateWorkspaceSheet,
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildAddItem(
                    'Tạo không gian làm việc mới',
                    onTap: _showCreateWorkspaceSheet,
                  ),
                ],
              );
            },
          ),
        ),
      ],
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
                icon: Icons.person_rounded,
                title: 'Thông tin cá nhân',
                subtitle: 'Tên, email và ảnh',
                iconBgColor: AppColors.primaryContainer.withValues(alpha: 0.1),
                iconColor: AppColors.primaryContainer,
                onTap: () async {
                  await Navigator.pushNamed(context, '/information');
                  setState(() {}); // Refresh info when returning
                },
              ),
              _buildDivider(),
              SettingItem(
                icon: Icons.security_rounded,
                title: 'Bảo mật',
                subtitle: 'Mật khẩu và 2FA',
                iconBgColor: AppColors.primaryContainer.withValues(alpha: 0.1),
                iconColor: AppColors.primaryContainer,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.securityPage);
                },
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
              SettingItem(
                icon: Icons.dark_mode_rounded,
                title: 'Giao diện',
                subtitle: 'Hệ thống, Sáng, Tối',
                iconBgColor: const Color(0xFFD2E0FC),
                iconColor: const Color(0xFF0D1C30),
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
              SettingItem(
                icon: Icons.notifications_rounded,
                title: 'Thông báo',
                subtitle: 'Desktop, Email, Mobile',
                iconBgColor: const Color(0xFFD2E0FC),
                iconColor: const Color(0xFF0D1C30),
                onTap: () {},
              ),
              _buildDivider(),
              SettingItem(
                icon: Icons.language_rounded,
                title: 'Ngôn ngữ',
                subtitle: 'Tiếng Việt',
                iconBgColor: const Color(0xFFD2E0FC),
                iconColor: const Color(0xFF0D1C30),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportGroup(BuildContext context) {
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
              SettingItem(
                icon: Icons.help_rounded,
                title: 'Trung tâm trợ giúp',
                iconBgColor: AppColors.surfaceContainerHigh,
                iconColor: AppColors.onSurfaceVariant,
                onTap: () {},
              ),
              SettingItem(
                icon: Icons.logout_rounded,
                title: 'Đăng xuất',
                iconBgColor: const Color(0xFFFFDAD6).withValues(alpha: 0.2),
                iconColor: AppColors.error,
                onTap: () {
                  _showLogoutDialog(context);
                },
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

  Widget _buildAddItem(String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Xác nhận',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất?',
            style: GoogleFonts.inter(),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
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
              onPressed: () async {
                // Đóng dialog xác nhận
                Navigator.of(dialogContext).pop();

                // Hiển thị vòng xoay loading mờ
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );

                // 1. Gọi API Logout (Có thể fail nếu rớt mạng, không sao cả)
                try {
                  final prefs = await SharedPreferences.getInstance();
                  final userUId = prefs.getString('user_uid');
                  const secureStorage = FlutterSecureStorage();
                  final refreshToken = await secureStorage.read(
                    key: 'refresh_token',
                  );
                  if (userUId != null && userUId.isNotEmpty) {
                    final dio = serviceLocator<Dio>();
                    await dio.post(
                      '${ApiEndpoints.logout}?userUId=$userUId',
                      data: {'refreshToken': refreshToken},
                    );
                  }
                } catch (_) {}

                // 2. Xóa các biến SharedPreferences
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('user_uid');
                  await prefs.remove('user_name');
                  await prefs.remove('user_email');
                  await prefs.setBool('isLogged', false);
                } catch (_) {}

                // 3. Xóa FlutterSecureStorage
                try {
                  const secureStorage = FlutterSecureStorage();
                  await secureStorage.deleteAll();
                } catch (_) {}

                // 4. Xóa Cookie (Sử dụng try-catch riêng cực kỳ quan trọng vì GetIt có thể báo lỗi nếu CookieJar chưa đăng ký)
                try {
                  if (serviceLocator.isRegistered<CookieJar>()) {
                    final cookieJar = serviceLocator<CookieJar>();
                    await cookieJar.deleteAll();
                  }
                } catch (_) {}

                // 5. Điều hướng về Login
                if (context.mounted) {
                  // Dùng rootNavigator để xóa sạch cả loading dialog nếu có và các trang trước đó
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                }
              },
              child: Text(
                'Đăng xuất',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

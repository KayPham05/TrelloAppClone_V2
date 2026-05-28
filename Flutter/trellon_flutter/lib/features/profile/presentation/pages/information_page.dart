import 'dart:io';
import 'package:apptreolon/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../../init_dependencies.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../widgets/profile_text_field_widget.dart';
class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String _avatarUrl = '';
  File? _selectedAvatar;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? 'Khách';
      _emailController.text = prefs.getString('user_email') ?? 'Chưa cập nhật';
      _bioController.text = prefs.getString('user_bio') ?? '';
      _avatarUrl = prefs.getString('user_avatar') ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCropImage() async {
    final croppedFile = await ImagePickerHelper.pickAndCropImage();

    if (croppedFile != null) {
      setState(() {
        _selectedAvatar = File(croppedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dio = serviceLocator<Dio>();

      String fileName = '';
      if (_selectedAvatar != null) {
        fileName = _selectedAvatar!.path.split('/').last;
      }

      FormData formData = FormData.fromMap({
        'userName': _nameController.text.trim(),
        'Bio': _bioController.text.trim(),
        if (_selectedAvatar != null)
          'avatar': await MultipartFile.fromFile(
            _selectedAvatar!.path,
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
        await prefs.setString(
          'user_name',
          data['userName'] ?? _nameController.text.trim(),
        );
        await prefs.setString('user_bio', _bioController.text.trim());
        if (data['avatarUrl'] != null) {
          await prefs.setString('user_avatar', data['avatarUrl']);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật thông tin thành công')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1D4ED8),
          ),
        ),
        title: Text(
          'Thông tin cá nhân',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3A8A),
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Lưu',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 32),
            ProfileTextFieldWidget(
              label: 'Họ và tên',
              controller: _nameController,
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 24),
            ProfileTextFieldWidget(
              label: 'Tiểu sử (Bio)',
              controller: _bioController,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            ProfileTextFieldWidget(
              label: 'Email',
              controller: _emailController,
              icon: Icons.email_outlined,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/change-email');
                  if (result == true) {
                    _loadUserInfo();
                  }
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(
                  'Đổi email liên kết',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    ImageProvider avatarImage;
    if (_selectedAvatar != null) {
      avatarImage = FileImage(_selectedAvatar!);
    } else if (_avatarUrl.isNotEmpty) {
      avatarImage = CachedNetworkImageProvider(_avatarUrl);
    } else {
      avatarImage = const CachedNetworkImageProvider(
        'https://i.pravatar.cc/150?u=jordan',
      );
    }

    return GestureDetector(
      onTap: _pickAndCropImage,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 120,
                height: 120,
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Chạm để đổi ảnh đại diện',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

}

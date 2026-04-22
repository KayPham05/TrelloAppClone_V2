import 'package:apptreolon/core/constants/api_endpoints.dart';
import 'package:apptreolon/core/constants/app_colors.dart';
import 'package:apptreolon/features/profile/presentation/pages/backup_codes_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../init_dependencies.dart';

/// Màn hình Enable 2FA - 3 bước:
/// 1. Thông báo chuẩn bị Google Authenticator
/// 2. Hiển thị QR code + secret key + form nhập mã 6 số
/// 3. Hiển thị backup codes (navigate sang BackupCodesPage)
class Enable2FAScreen extends StatefulWidget {
  const Enable2FAScreen({super.key});

  @override
  State<Enable2FAScreen> createState() => _Enable2FAScreenState();
}

class _Enable2FAScreenState extends State<Enable2FAScreen> {
  // Step tracking
  int _currentStep = 0; // 0 = intro, 1 = QR + verify

  // API data
  String _secretKey = '';
  String _qrUri = '';

  // UI state
  bool _isLoadingSetup = false;
  bool _isVerifying = false;
  String? _errorMessage;

  // Form
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final Dio _dio = serviceLocator<Dio>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // ─── Bước 1: Gọi API GET /2fa/setup ───
  Future<void> _callSetup2FA() async {
    setState(() {
      _isLoadingSetup = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userUId = prefs.getString('user_uid') ?? '';

      if (userUId.isEmpty) {
        setState(() {
          _errorMessage =
              'Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.';
          _isLoadingSetup = false;
        });
        return;
      }

      final response = await _dio.get(
        '${ApiEndpoints.twoFASetup}?userUId=$userUId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _secretKey = data['secretKey'] ?? '';
          _qrUri = data['qrUri'] ?? '';
          _currentStep = 1;
          _isLoadingSetup = false;
        });
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Lỗi kết nối server'
          : 'Lỗi kết nối server';
      setState(() {
        _errorMessage = msg;
        _isLoadingSetup = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi: $e';
        _isLoadingSetup = false;
      });
    }
  }

  // ─── Bước 4: Gọi API POST /2fa/enable ───
  Future<void> _callEnable2FA() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userUId = prefs.getString('user_uid') ?? '';

      final response = await _dio.post(
        '${ApiEndpoints.twoFAEnable}?userUId=$userUId',
        data: {'code': _codeController.text.trim()},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final backupCodes = List<String>.from(data['backupCodes'] ?? []);

        if (!mounted) return;

        // Navigate sang BackupCodesPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BackupCodesPage(backupCodes: backupCodes),
          ),
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Mã xác thực không hợp lệ'
          : 'Lỗi kết nối server';
      setState(() {
        _errorMessage = msg;
        _isVerifying = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi: $e';
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F2F4),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1D4ED8),
          ),
        ),
        title: Text(
          'Xác thực 2 yếu tố',
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
        child: _currentStep == 0 ? _buildIntroStep() : _buildQRStep(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // STEP 0: Màn hình giới thiệu - Chuẩn bị Google Authenticator
  // ═══════════════════════════════════════════════════════
  Widget _buildIntroStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        children: [
          // Icon shield
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.security_rounded,
              size: 40,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Bảo vệ tài khoản của bạn',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Xác thực 2 yếu tố (2FA) thêm một lớp bảo mật cho tài khoản của bạn bằng cách yêu cầu mã xác thực từ ứng dụng Google Authenticator mỗi khi đăng nhập.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Hướng dẫn
          _buildInstructionTile(
            number: '1',
            title: 'Tải ứng dụng',
            description:
                'Cài đặt Google Authenticator từ App Store hoặc Google Play.',
            icon: Icons.download_rounded,
          ),
          const SizedBox(height: 12),
          _buildInstructionTile(
            number: '2',
            title: 'Quét mã QR',
            description:
                'Sử dụng Google Authenticator để quét mã QR ở bước tiếp theo.',
            icon: Icons.qr_code_scanner_rounded,
          ),
          const SizedBox(height: 12),
          _buildInstructionTile(
            number: '3',
            title: 'Nhập mã xác thực',
            description:
                'Nhập mã 6 số từ Google Authenticator để hoàn tất thiết lập.',
            icon: Icons.pin_rounded,
          ),
          const SizedBox(height: 32),

          // Error message
          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Button Tiếp tục
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoadingSetup ? null : _callSetup2FA,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoadingSetup
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Tiếp tục',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionTile({
    required String number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // STEP 1: Hiển thị QR Code + Secret Key + Form nhập mã
  // ═══════════════════════════════════════════════════════
  Widget _buildQRStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        children: [
          // QR Code
          Text(
            'Quét mã QR bằng Google Authenticator',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),

          // QR Code container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
            ),
            child: QrImageView(
              data: _qrUri,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF1E3A8A),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Secret Key hiển thị
          Text(
            'Hoặc nhập thủ công mã bên dưới:',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _secretKey,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy_rounded,
                    size: 20,
                    color: AppColors.primaryContainer,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _secretKey));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã sao chép mã bí mật'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Sao chép',
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Xác nhận',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.outlineVariant)),
            ],
          ),
          const SizedBox(height: 20),

          // Form nhập mã 6 số
          Text(
            'Nhập mã 6 số từ Google Authenticator',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          Form(
            key: _formKey,
            child: TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: GoogleFonts.jetBrainsMono(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 8,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '000000',
                hintStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 8,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryContainer,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Vui lòng nhập mã xác thực';
                if (value.length != 6) return 'Mã phải đủ 6 chữ số';
                if (!RegExp(r'^\d{6}$').hasMatch(value))
                  return 'Mã chỉ chứa các chữ số';
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),

          // Error message
          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Button Xác nhận
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _callEnable2FA,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isVerifying
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Xác nhận',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:apptreolon/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bước 6: Hiển thị 8 mã dự phòng sau khi bật 2FA thành công.
/// - Nút Copy / Tải xuống
/// - Checkbox xác nhận đã lưu
/// - Nút Hoàn tất chỉ enable khi đã tick checkbox
class BackupCodesPage extends StatefulWidget {
  final List<String> backupCodes;

  const BackupCodesPage({super.key, required this.backupCodes});

  @override
  State<BackupCodesPage> createState() => _BackupCodesPageState();
}

class _BackupCodesPageState extends State<BackupCodesPage> {
  bool _hasSavedCodes = false;

  void _copyAllCodes() {
    final codesText = widget.backupCodes
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');

    final fullText = '═══ Trellon - Mã dự phòng 2FA ═══\n\n'
        '$codesText\n\n'
        'Lưu ý: Mỗi mã chỉ dùng được một lần.\n'
        'Hãy giữ các mã này ở nơi an toàn.';

    Clipboard.setData(ClipboardData(text: fullText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text('Đã sao chép tất cả mã dự phòng'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleDone() {
    // Pop tất cả các trang 2FA và quay về Security page
    Navigator.of(context).popUntil((route) {
      return route.settings.name == '/security' || route.isFirst;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Chặn back để user phải bấm Hoàn tất
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF1F2F4),
          automaticallyImplyLeading: false,
          title: Text(
            'Mã dự phòng',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              children: [
                // Success icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    size: 32,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Xác thực 2 yếu tố đã được bật!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Lưu lại các mã dự phòng bên dưới ở nơi an toàn. '
                  'Bạn có thể sử dụng chúng để đăng nhập nếu không thể truy cập Google Authenticator.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Warning banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFD54F)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Mỗi mã chỉ sử dụng được một lần. Sau khi đóng trang này, bạn sẽ không thể xem lại các mã này.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            height: 1.5,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Backup codes grid
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'MÃ DỰ PHÒNG',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCodesGrid(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Copy button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: _copyAllCodes,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text(
                      'Sao chép tất cả mã',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryContainer,
                      side: const BorderSide(color: AppColors.primaryContainer),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Checkbox xác nhận
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasSavedCodes
                          ? AppColors.success.withValues(alpha: 0.5)
                          : AppColors.outlineVariant,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: _hasSavedCodes,
                    onChanged: (val) => setState(() => _hasSavedCodes = val ?? false),
                    title: Text(
                      'Tôi đã lưu các mã dự phòng này ở nơi an toàn',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                const SizedBox(height: 20),

                // Button Hoàn tất - chỉ enable khi đã tick checkbox
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _hasSavedCodes ? _handleDone : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.surfaceContainerHigh,
                      disabledForegroundColor: AppColors.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Hoàn tất',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodesGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: widget.backupCodes.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final code = entry.value;
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 48 - 40 - 12) / 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  '$index.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  code,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

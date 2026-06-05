import 'package:apptreolon/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// BÆ°á»›c 6: Hiá»ƒn thá»‹ 8 mÃ£ dá»± phÃ²ng sau khi báº­t 2FA thÃ nh cÃ´ng.
/// - NÃºt Copy / Táº£i xuá»‘ng
/// - Checkbox xÃ¡c nháº­n Ä‘Ã£ lÆ°u
/// - NÃºt HoÃ n táº¥t chá»‰ enable khi Ä‘Ã£ tick checkbox
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

    final fullText = 'â•â•â• Kabo - MÃ£ dá»± phÃ²ng 2FA â•â•â•\n\n'
        '$codesText\n\n'
        'LÆ°u Ã½: Má»—i mÃ£ chá»‰ dÃ¹ng Ä‘Æ°á»£c má»™t láº§n.\n'
        'HÃ£y giá»¯ cÃ¡c mÃ£ nÃ y á»Ÿ nÆ¡i an toÃ n.';

    Clipboard.setData(ClipboardData(text: fullText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text('ÄÃ£ sao chÃ©p táº¥t cáº£ mÃ£ dá»± phÃ²ng'),
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
    // Pop táº¥t cáº£ cÃ¡c trang 2FA vÃ  quay vá» Security page
    Navigator.of(context).popUntil((route) {
      return route.settings.name == '/security' || route.isFirst;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Cháº·n back Ä‘á»ƒ user pháº£i báº¥m HoÃ n táº¥t
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF1F2F4),
          automaticallyImplyLeading: false,
          title: Text(
            'MÃ£ dá»± phÃ²ng',
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
                  'XÃ¡c thá»±c 2 yáº¿u tá»‘ Ä‘Ã£ Ä‘Æ°á»£c báº­t!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'LÆ°u láº¡i cÃ¡c mÃ£ dá»± phÃ²ng bÃªn dÆ°á»›i á»Ÿ nÆ¡i an toÃ n. '
                  'Báº¡n cÃ³ thá»ƒ sá»­ dá»¥ng chÃºng Ä‘á»ƒ Ä‘Äƒng nháº­p náº¿u khÃ´ng thá»ƒ truy cáº­p Google Authenticator.',
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
                          'Má»—i mÃ£ chá»‰ sá»­ dá»¥ng Ä‘Æ°á»£c má»™t láº§n. Sau khi Ä‘Ã³ng trang nÃ y, báº¡n sáº½ khÃ´ng thá»ƒ xem láº¡i cÃ¡c mÃ£ nÃ y.',
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
                        'MÃƒ Dá»° PHÃ’NG',
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
                      'Sao chÃ©p táº¥t cáº£ mÃ£',
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

                // Checkbox xÃ¡c nháº­n
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
                      'TÃ´i Ä‘Ã£ lÆ°u cÃ¡c mÃ£ dá»± phÃ²ng nÃ y á»Ÿ nÆ¡i an toÃ n',
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

                // Button HoÃ n táº¥t - chá»‰ enable khi Ä‘Ã£ tick checkbox
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
                      'HoÃ n táº¥t',
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

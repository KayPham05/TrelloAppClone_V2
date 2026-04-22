import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'introduction_common.dart';

class StepWorkspace extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String name, String visibility) onFinish;

  const StepWorkspace({
    super.key,
    required this.onBack,
    required this.onFinish,
  });

  @override
  State<StepWorkspace> createState() => _StepWorkspaceState();
}

class _StepWorkspaceState extends State<StepWorkspace> {
  final TextEditingController _boardNameController = TextEditingController();
  String _selectedVisibility = 'Private';

  @override
  void dispose() {
    _boardNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: IntroductionAppBar(
              title: 'Step 5 of 5',
              actionText: 'LUCID',
              onBack: widget.onBack,
              isActionText: true,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Tạo bảng\nđầu tiên của bạn!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Đây là nơi bạn theo dõi công việc của mình. Đặt tên và chọn mức độ hiển thị cho bảng.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Tên bảng',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _boardNameController,
                      decoration: const InputDecoration(
                        hintText: 'vd: Công việc cá nhân',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Mức độ hiển thị',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _VisibilityOptionWidget(
                    value: 'Private',
                    selected: _selectedVisibility,
                    icon: Icons.lock_rounded,
                    label: 'Riêng tư',
                    description: 'Chỉ bạn mới thấy bảng này.',
                    onTap: () => setState(() => _selectedVisibility = 'Private'),
                  ),
                  const SizedBox(height: 10),
                  _VisibilityOptionWidget(
                    value: 'Public',
                    selected: _selectedVisibility,
                    icon: Icons.public_rounded,
                    label: 'Công khai',
                    description: 'Mọi người đều có thể xem bảng này.',
                    onTap: () => setState(() => _selectedVisibility = 'Public'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: IntroductionPrimaryButton(
              text: 'Bắt đầu nào!',
              onPressed: () {
                if (_boardNameController.text.trim().isNotEmpty) {
                  widget.onFinish(
                    _boardNameController.text.trim(),
                    _selectedVisibility,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VisibilityOptionWidget extends StatelessWidget {
  final String value;
  final String selected;
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _VisibilityOptionWidget({
    required this.value,
    required this.selected,
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryFixed : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isActive ? AppColors.primary : AppColors.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

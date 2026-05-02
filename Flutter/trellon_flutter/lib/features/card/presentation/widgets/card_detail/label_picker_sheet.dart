import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/card_entity.dart';

class LabelPickerSheet extends StatelessWidget {
  final List<CardLabelEntity> selectedLabels;
  final Function(String, String) onLabelToggled;

  const LabelPickerSheet({
    super.key,
    required this.selectedLabels,
    required this.onLabelToggled,
  });

  // Storage for the user's available labels throughout the session.
  static List<Map<String, dynamic>> boardLabelRepository = [
    {
      'name': '',
      'color': const Color(0xFF1E7F51),
      'code': '#1E7F51',
    }, // Emerald
    {
      'name': '',
      'color': const Color(0xFF8B791B),
      'code': '#8B791B',
    }, // Mustard
    {'name': '', 'color': const Color(0xFFB15F1C), 'code': '#B15F1C'}, // Orange
    {'name': '', 'color': const Color(0xFFB92C23), 'code': '#B92C23'}, // Red
    {'name': '', 'color': const Color(0xFF7E3DCC), 'code': '#7E3DCC'}, // Purple
  ];

  static const List<Map<String, dynamic>> paletteColors = [
    {'name': '', 'color': Color(0xFF107A5A), 'code': '#107A5A'}, // Dark Emerald
    {'name': '', 'color': Color(0xFF715F0B), 'code': '#715F0B'}, // Dark Mustard
    {'name': '', 'color': Color(0xFF8F4D18), 'code': '#8F4D18'}, // Dark Orange
    {'name': '', 'color': Color(0xFF8F221B), 'code': '#8F221B'}, // Dark Red
    {'name': '', 'color': Color(0xFF42217E), 'code': '#42217E'}, // Dark Purple

    {'name': '', 'color': Color(0xFF1E7F51), 'code': '#1E7F51'}, // Emerald
    {'name': '', 'color': Color(0xFF8B791B), 'code': '#8B791B'}, // Mustard
    {'name': '', 'color': Color(0xFFB15F1C), 'code': '#B15F1C'}, // Orange
    {'name': '', 'color': Color(0xFFB92C23), 'code': '#B92C23'}, // Red
    {'name': '', 'color': Color(0xFF7E3DCC), 'code': '#7E3DCC'}, // Purple

    {
      'name': '',
      'color': Color(0xFF4BBF6B),
      'code': '#4BBF6B',
    }, // Light Emerald
    {
      'name': '',
      'color': Color(0xFFDBB124),
      'code': '#DBB124',
    }, // Light Mustard
    {'name': '', 'color': Color(0xFFFF9F1A), 'code': '#FF9F1A'}, // Light Orange
    {'name': '', 'color': Color(0xFFEB5A46), 'code': '#EB5A46'}, // Light Red
    {'name': '', 'color': Color(0xFFC377E0), 'code': '#C377E0'}, // Light Purple

    {'name': '', 'color': Color(0xFF003774), 'code': '#003774'}, // Dark Blue
    {'name': '', 'color': Color(0xFF07474E), 'code': '#07474E'}, // Dark Cyan
    {'name': '', 'color': Color(0xFF334A1B), 'code': '#334A1B'}, // Dark Olive
    {'name': '', 'color': Color(0xFF4D1C34), 'code': '#4D1C34'}, // Dark Maroon
    {'name': '', 'color': Color(0xFF42526E), 'code': '#42526E'}, // Dark Slate

    {'name': '', 'color': Color(0xFF0052CC), 'code': '#0052CC'}, // Blue
    {'name': '', 'color': Color(0xFF008B94), 'code': '#008B94'}, // Cyan
    {'name': '', 'color': Color(0xFF519839), 'code': '#519839'}, // Olive
    {'name': '', 'color': Color(0xFF893F62), 'code': '#893F62'}, // Maroon
    {'name': '', 'color': Color(0xFF6B778C), 'code': '#6B778C'}, // Slate

    {'name': '', 'color': Color(0xFF4DA0FF), 'code': '#4DA0FF'}, // Light Blue
    {'name': '', 'color': Color(0xFF00C7D1), 'code': '#00C7D1'}, // Light Cyan
    {'name': '', 'color': Color(0xFF94C748), 'code': '#94C748'}, // Light Olive
    {'name': '', 'color': Color(0xFFFF8ED4), 'code': '#FF8ED4'}, // Light Maroon
    {'name': '', 'color': Color(0xFFA5ADBA), 'code': '#A5ADBA'}, // Light Slate
  ];

  @override
  Widget build(BuildContext context) {
    return _LabelPickerContent(
      selectedLabels: selectedLabels,
      onLabelToggled: onLabelToggled,
    );
  }

  static void show(
    BuildContext context, {
    required List<CardLabelEntity> selectedLabels,
    required Function(String, String) onLabelToggled,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => AnimatedPadding(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: LabelPickerSheet(
          selectedLabels: selectedLabels,
          onLabelToggled: onLabelToggled,
        ),
      ),
    );
  }
}

class _LabelPickerContent extends StatefulWidget {
  final List<CardLabelEntity> selectedLabels;
  final Function(String, String) onLabelToggled;

  const _LabelPickerContent({
    required this.selectedLabels,
    required this.onLabelToggled,
  });

  @override
  State<_LabelPickerContent> createState() => _LabelPickerContentState();
}

class _LabelPickerContentState extends State<_LabelPickerContent> {
  bool isAddingLabel = false;
  String customName = '';
  Color? selectedCustomColor;
  late List<CardLabelEntity> _localSelectedLabels;

  @override
  void initState() {
    super.initState();
    _localSelectedLabels = List.from(widget.selectedLabels);
    _importSelectedLabelsIntoRepository();
  }

  void _importSelectedLabelsIntoRepository() {
    for (var sl in widget.selectedLabels) {
      final codeUpper = sl.colorCode.toUpperCase();
      final exists = LabelPickerSheet.boardLabelRepository.any(
        (r) =>
            (r['code'] as String).toUpperCase() == codeUpper &&
            r['name'] == sl.title,
      );
      if (!exists) {
        // Attempt to find the real color from palette
        Color color = Colors.grey;
        final paletteMatch = LabelPickerSheet.paletteColors
            .where((p) => (p['code'] as String).toUpperCase() == codeUpper)
            .toList();
        if (paletteMatch.isNotEmpty) {
          color = paletteMatch.first['color'] as Color;
        } else {
          // Fallback parsing if somehow it doesn't match palette
          final hex = codeUpper.replaceAll('#', '');
          if (hex.length == 6) {
            color = Color(int.parse('FF$hex', radix: 16));
          }
        }
        LabelPickerSheet.boardLabelRepository.add({
          'name': sl.title,
          'color': color,
          'code': codeUpper,
        });
      }
    }
  }

  void _onToggleLabel(String name, String code) {
    setState(() {
      final codeUpper = code.toUpperCase();
      final exists = _localSelectedLabels.any(
        (l) => l.colorCode.toUpperCase() == codeUpper && l.title == name,
      );
      if (exists) {
        _localSelectedLabels.removeWhere(
          (l) => l.colorCode.toUpperCase() == codeUpper && l.title == name,
        );
      } else {
        _localSelectedLabels.add(
          CardLabelEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: name,
            colorCode: codeUpper,
          ),
        );
      }
    });
    widget.onLabelToggled(name, code);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: isAddingLabel ? _buildAddLabelView() : _buildMainListView(),
    );
  }

  Widget _buildMainListView() {
    return Column(
      children: [
        _buildHeader(
          title: 'Nhãn',
          leftAction: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          rightAction: IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () => setState(() => isAddingLabel = true),
          ),
        ),
        _buildSettingsRow('Chế độ mù màu'),
        _buildSettingsRow('Hiển thị tên nhãn trên mặt trước thẻ'),
        const Divider(color: Colors.black12, height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: LabelPickerSheet.boardLabelRepository.map((label) {
              final isSelected = _localSelectedLabels.any(
                (l) =>
                    l.colorCode.toUpperCase() ==
                        (label['code'] as String).toUpperCase() &&
                    l.title == label['name'],
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            _onToggleLabel(label['name'], label['code']),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: label['color'],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  label['name'] as String,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.black54,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          isAddingLabel = true;
                          customName = label['name'];
                          selectedCustomColor = label['color'];
                        });
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAddLabelView() {
    return Column(
      children: [
        _buildHeader(
          title: 'Thêm nhãn',
          leftAction: TextButton(
            onPressed: () => setState(() {
              isAddingLabel = false;
              customName = '';
              selectedCustomColor = null;
            }),
            child: Text('Huỷ', style: GoogleFonts.inter(color: Colors.black87)),
          ),
          rightAction: TextButton(
            onPressed: () {
              if (selectedCustomColor != null) {
                final hexCode =
                    '#${selectedCustomColor!.value.toRadixString(16).substring(2).toUpperCase()}';

                // Add to repository if not exists
                final existsInRepo = LabelPickerSheet.boardLabelRepository.any(
                  (r) =>
                      (r['code'] as String).toUpperCase() == hexCode &&
                      r['name'] == customName,
                );
                if (!existsInRepo) {
                  LabelPickerSheet.boardLabelRepository.add({
                    'name': customName,
                    'color': selectedCustomColor!,
                    'code': hexCode,
                  });
                }

                _onToggleLabel(customName, hexCode);
                setState(() => isAddingLabel = false);
              }
            },
            child: Text(
              'Xong',
              style: GoogleFonts.inter(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: selectedCustomColor ?? Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  customName,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tên (không bắt buộc)',
                style: GoogleFonts.inter(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (v) => setState(() => customName = v),
                controller: TextEditingController(text: customName)
                  ..selection = TextSelection.collapsed(
                    offset: customName.length,
                  ),
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black12,
                  hintText: 'Tên nhãn...',
                  hintStyle: const TextStyle(color: Colors.black38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Màu sắc',
                style: GoogleFonts.inter(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemCount: LabelPickerSheet.paletteColors.length,
                itemBuilder: (context, index) {
                  final color =
                      LabelPickerSheet.paletteColors[index]['color'] as Color;
                  final isSelected = selectedCustomColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCustomColor = color),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                        border: isSelected
                            ? Border.all(color: Colors.blueAccent, width: 2)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({
    required String title,
    required Widget leftAction,
    required Widget rightAction,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leftAction,
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          rightAction,
        ],
      ),
    );
  }

  Widget _buildSettingsRow(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(color: Colors.black87, fontSize: 14),
          ),
          Switch(
            value: false,
            onChanged: (v) {},
            activeColor: Colors.blue,
            inactiveThumbColor: Colors.black54,
            inactiveTrackColor: Colors.black12,
          ),
        ],
      ),
    );
  }
}

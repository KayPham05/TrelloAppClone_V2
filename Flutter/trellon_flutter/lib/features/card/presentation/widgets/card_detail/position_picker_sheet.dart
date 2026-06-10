import 'package:flutter/material.dart';

/// Sheet chọn vị trí (1-indexed) cho card trong list hoặc inbox.
class PositionPickerSheet extends StatelessWidget {
  final int currentPosition;
  final int totalPositions;

  const PositionPickerSheet({
    super.key,
    required this.currentPosition,
    required this.totalPositions,
  });

  static Future<int?> show(
    BuildContext context, {
    required int currentPosition,
    required int totalPositions,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PositionPickerSheet(
        currentPosition: currentPosition,
        totalPositions: totalPositions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemHeight = MediaQuery.of(context).size.height * (7 / 8);

    return Container(
      height: itemHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            alignment: Alignment.center,
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Text(
                  'Chọn vị trí',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: totalPositions,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
              itemBuilder: (_, i) {
                final pos = i + 1;
                final isSelected = pos == currentPosition;
                return ListTile(
                  title: Text('$pos', style: const TextStyle(fontSize: 15)),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF0052CC))
                      : null,
                  tileColor: isSelected ? const Color(0xFFE8F0FE) : null,
                  onTap: () => Navigator.of(context).pop(pos),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/list_entity.dart';

class ListMenuBottomSheet extends StatelessWidget {
  final ListEntity list;

  const ListMenuBottomSheet({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              list.name,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_rounded),
            title: const Text('Thêm thẻ mới'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy_rounded, size: 20),
            title: const Text('Sao chép danh sách'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.archive_outlined, size: 20),
            title: const Text('Lưu trữ danh sách'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

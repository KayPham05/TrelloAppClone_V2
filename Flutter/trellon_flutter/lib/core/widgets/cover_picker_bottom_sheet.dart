import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';

class CoverPickerBottomSheet extends StatelessWidget {
  final Function(String url) onTemplateSelected;
  final Function(File file) onImagePicked;

  const CoverPickerBottomSheet({
    super.key,
    required this.onTemplateSelected,
    required this.onImagePicked,
  });

  static const List<String> _templates = [
    'https://images.unsplash.com/photo-1707343843437-caacff5cfa74?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1557682250-33bd709cbe85?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1518640467707-6811f4a6ab73?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1508615039623-a25605d2b022?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1533134486753-c833f0ed4866?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=400&auto=format&fit=crop',
  ];

  static void show(BuildContext context, {
    required Function(String url) onTemplateSelected,
    required Function(File file) onImagePicked,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CoverPickerBottomSheet(
        onTemplateSelected: onTemplateSelected,
        onImagePicked: onImagePicked,
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (context.mounted) {
        Navigator.pop(context);
        onImagePicked(File(pickedFile.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ảnh bìa',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _pickImage(context),
            icon: const Icon(Icons.upload_file),
            label: const Text('Tải ảnh biểu bìa từ thiết bị'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.surfaceContainer,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mẫu có sẵn (Unsplash)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
            ),
            itemCount: _templates.length,
            itemBuilder: (context, index) {
              final url = _templates[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onTemplateSelected(url);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: AppColors.surfaceContainer),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

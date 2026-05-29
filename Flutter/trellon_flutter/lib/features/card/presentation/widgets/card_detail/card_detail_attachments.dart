import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../cubit/card_detail_cubit.dart';
import '../../cubit/card_detail_state.dart';
import '../../../domain/entities/card_entity.dart';

class CardDetailAttachments extends StatelessWidget {
  const CardDetailAttachments({super.key});

  void _showAddAttachmentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Thư viện ảnh/video'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Tài liệu/chọn File'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickDocument(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDocument(BuildContext context) async {
    final result = await FilePicker.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        _showDescriptionDialog(context, result.files.single.path!);
      }
    }
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      if (context.mounted) {
        _showDescriptionDialog(context, pickedFile.path);
      }
    }
  }

  Future<void> _showUpdateDescriptionDialog(BuildContext context, FileUrlEntity file) async {
    final cubit = context.read<CardDetailCubit>();
    String newDescription = file.description ?? '';
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Bình luận/Mô tả ảnh'),
          content: TextField(
            controller: TextEditingController(text: newDescription),
            decoration: const InputDecoration(hintText: 'Nhập mô tả cho ảnh...'),
            onChanged: (val) => newDescription = val,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
    // if newDescription differs manually
    cubit.updateAttachmentDescription(file.id, newDescription);
  }

  Future<void> _showDescriptionDialog(BuildContext context, String filePath) async {
    final cubit = context.read<CardDetailCubit>();
    String? description;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Thêm mô tả cho tệp'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Nhập mô tả (không bắt buộc)'),
            onChanged: (val) => description = val,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bỏ qua')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
    cubit.uploadAttachment(filePath, description: description);
  }
  
  void _editImage(BuildContext context, FileUrlEntity file) async {
    final cubit = context.read<CardDetailCubit>();
    if (!_isImage(file.url)) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProImageEditor.network(
          file.url,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (bytes) async {
              // Convert bytes back to file temporarily
              final tempDir = Directory.systemTemp;
              final tempFile = File('${tempDir.path}/edited_${file.fileName}');
              await tempFile.writeAsBytes(bytes);
              
              if (context.mounted) {
                Navigator.pop(context); // pop editor
                // Re-upload as new attachment
                cubit.uploadAttachment(tempFile.path, description: 'Edited from ${file.fileName}');
              }
            },
          ),
        ),
      ),
    );
  }

  bool _isImage(String url) {
    final ext = url.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardDetailCubit, CardDetailState>(
      listenWhen: (prev, current) {
        if (current is CardDetailLoaded && current.attachmentError != null) return true;
        return false;
      },
      listener: (context, state) {
        if (state is CardDetailLoaded && state.attachmentError == 'duplicate') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tệp này đã được đính kèm trước đó!'),
              backgroundColor: Colors.red,
            ),
          );
          context.read<CardDetailCubit>().clearAttachmentError();
        }
      },
      builder: (context, state) {
        if (state is! CardDetailLoaded) return const SizedBox.shrink();
        final fileUrls = state.card.fileUrls;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.attach_file_rounded,
                        size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      'CÁC TẬP TIN ĐÍNH KÈM',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: state.isUploadingAttachment ? null : () => _showAddAttachmentBottomSheet(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.isUploadingAttachment) 
                            const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1D4ED8)),
                            )
                          else
                            const Icon(Icons.add_rounded, size: 16, color: Color(0xFF1D4ED8)),
                          const SizedBox(width: 4),
                          Text(
                            state.isUploadingAttachment ? 'ĐANG TẢI...' : 'TẢI LÊN',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (fileUrls.isEmpty)
                  Text(
                    'Chưa có tập tin đính kèm nào.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ...fileUrls.map((file) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildAttachmentItem(context, file),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFileExt(String fileName) {
    if (!fileName.contains('.')) return 'FILE';
    final parts = fileName.split('.');
    String ext = parts.last.toUpperCase();
    return ext.length > 3 ? ext.substring(0, 3) : ext;
  }

  Color _getColorForExt(String fileName) {
    final ext = _getFileExt(fileName);
    if (ext == 'PDF') return const Color(0xFF3B82F6);
    if (['JPG', 'PNG', 'JPE', 'WEBP'].contains(ext)) return const Color(0xFF10B981);
    if (['DOC', 'DOCX'].contains(ext)) return const Color(0xFF2563EB);
    return const Color(0xFFF97316);
  }

  Widget _buildAttachmentItem(BuildContext context, FileUrlEntity file) {
    final isImg = _isImage(file.url);
    final ext = _getFileExt(file.fileName);
    final color = _getColorForExt(file.fileName);

    return InkWell(
      onTap: isImg ? () => _editImage(context, file) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                image: isImg 
                  ? DecorationImage(image: NetworkImage(file.url), fit: BoxFit.cover)
                  : null,
              ),
              child: isImg ? null : Center(
                child: Text(
                  ext,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
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
                    file.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (file.description != null && file.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        file.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Cloudinary URL',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant, size: 20),
              onSelected: (value) {
                if (value == 'edit_image') {
                  _editImage(context, file);
                } else if (value == 'edit_description') {
                  _showUpdateDescriptionDialog(context, file);
                } else if (value == 'delete') {
                  context.read<CardDetailCubit>().deleteAttachment(file.id);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                if (isImg)
                  const PopupMenuItem<String>(
                    value: 'edit_image',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined, color: Colors.blue),
                      title: Text('Xem và chỉnh sửa ảnh'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                const PopupMenuItem<String>(
                  value: 'edit_description',
                  child: ListTile(
                    leading: Icon(Icons.comment_outlined, color: Colors.green),
                    title: Text('Thêm bình luận cho ảnh'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('Xóa ảnh'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

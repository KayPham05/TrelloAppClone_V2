import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../cubit/card_detail_cubit.dart';
import '../../cubit/card_detail_state.dart';
import '../../../domain/entities/card_entity.dart';
import 'attachment_download_service.dart';

class CardDetailAttachments extends StatelessWidget {
  final AttachmentDownloadService downloadService;

  const CardDetailAttachments({
    super.key,
    this.downloadService = const AttachmentDownloadService(),
  });

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

  Future<void> _showRenameFileDialog(
    BuildContext context,
    FileUrlEntity file,
  ) async {
    final cubit = context.read<CardDetailCubit>();

    final lastDotIndex = file.fileName.lastIndexOf('.');
    final hasExtension =
        lastDotIndex != -1 && lastDotIndex < file.fileName.length - 1;
    final baseName = hasExtension
        ? file.fileName.substring(0, lastDotIndex)
        : file.fileName;
    final extension = hasExtension ? file.fileName.substring(lastDotIndex) : '';

    String newBaseName = baseName;
    final controller = TextEditingController(text: newBaseName);

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Đổi tên tệp'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Nhập tên tệp mới...',
              suffixText: extension,
            ),
            onChanged: (val) => newBaseName = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
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

    if (newBaseName.trim().isNotEmpty && newBaseName != baseName) {
      final finalName = '${newBaseName.trim()}$extension';
      cubit.renameAttachment(file.id, finalName);
    }
  }

  Future<void> _showDescriptionDialog(
    BuildContext context,
    String filePath,
  ) async {
    final cubit = context.read<CardDetailCubit>();
    String? description;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Thêm mô tả cho tệp'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Nhập mô tả (không bắt buộc)',
            ),
            onChanged: (val) => description = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Bỏ qua'),
            ),
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

  void _openFile(BuildContext context, FileUrlEntity file) async {
    final isImg = _isImage(file.url);
    final ext = _getFileExt(file.fileName);
    final isPdf = ext == 'PDF';

    if (isImg) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(child: Image.network(file.url)),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              _buildFileInfoOverlay(file, true),
            ],
          ),
        ),
      );
    } else if (isPdf) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                const PDF().cachedFromUrl(
                  file.url,
                  placeholder: (progress) => Center(child: Text('$progress %')),
                  errorWidget: (error) => Center(child: Text(error.toString())),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black54,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                _buildFileInfoOverlay(file, false),
              ],
            ),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: const Text(
            'Không có bản xem trước nào cho tệp đính kèm này.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFileInfoOverlay(FileUrlEntity file, bool isTransparentBg) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: isTransparentBg
              ? BorderRadius.zero
              : const BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              file.fileName,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (file.description != null && file.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  file.description!,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
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
        if (current is CardDetailLoaded && current.attachmentError != null) {
          return true;
        }
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
        final images = fileUrls.where((f) => _isImage(f.url)).toList();
        final files = fileUrls.where((f) => !_isImage(f.url)).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Các tập tin đính kèm ─────────────────────────────────
            _SectionHeader(
              icon: Icons.attach_file_rounded,
              title: 'Các tập tin đính kèm',
              trailing: state.isUploadingAttachment
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF1D4ED8),
                      ),
                    )
                  : GestureDetector(
                      onTap: () => _showAddAttachmentBottomSheet(context),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 22,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
            ),

            if (files.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: files
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildAttachmentItem(context, f),
                        ),
                      )
                      .toList(),
                ),
              ),

            // ── Các ảnh đính kèm ─────────────────────────────────────
            if (images.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Các ảnh đính kèm',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: images
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildAttachmentItem(context, f),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
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
    if (['JPG', 'PNG', 'JPE', 'WEBP'].contains(ext)) {
      return const Color(0xFF10B981);
    }
    if (['DOC', 'DOCX'].contains(ext)) return const Color(0xFF2563EB);
    return const Color(0xFFF97316);
  }

  Widget _buildAttachmentItem(BuildContext context, FileUrlEntity file) {
    final isImg = _isImage(file.url);
    final ext = _getFileExt(file.fileName);
    final color = _getColorForExt(file.fileName);

    return InkWell(
      onTap: () => _openFile(context, file),
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
                    ? DecorationImage(
                        image: NetworkImage(file.url),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: isImg
                  ? null
                  : Center(
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
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
              onSelected: (value) async {
                if (value == 'rename') {
                  _showRenameFileDialog(context, file);
                } else if (value == 'download') {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final savedFile = await downloadService.download(
                      url: file.url,
                      fileName: file.fileName,
                    );
                    if (!context.mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text('Đã tải về: ${savedFile.path}')),
                    );
                  } catch (_) {
                    if (!context.mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Không thể tải tệp. Vui lòng thử lại.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xác nhận xóa'),
                      content: const Text(
                        'Bạn có chắc chắn muốn xóa tệp đính kèm này không?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            'Xóa',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    context.read<CardDetailCubit>().deleteAttachment(file.id);
                  }
                }
              },
              constraints: const BoxConstraints(minWidth: 148, maxWidth: 176),
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'download',
                  height: 40,
                  child: ListTile(
                    dense: true,
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    minLeadingWidth: 20,
                    horizontalTitleGap: 10,
                    leading: Icon(
                      Icons.download_outlined,
                      color: Colors.blue,
                      size: 19,
                    ),
                    title: Text('Tải về'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'rename',
                  height: 40,
                  child: ListTile(
                    dense: true,
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    minLeadingWidth: 20,
                    horizontalTitleGap: 10,
                    leading: Icon(
                      Icons.edit_outlined,
                      color: Colors.green,
                      size: 19,
                    ),
                    title: Text('Chỉnh sửa'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  height: 40,
                  child: ListTile(
                    dense: true,
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    minLeadingWidth: 20,
                    horizontalTitleGap: 10,
                    leading: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 19,
                    ),
                    title: Text('Xóa tệp'),
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

/// Reusable flat section-header row: icon + title + optional trailing widget
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade500),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

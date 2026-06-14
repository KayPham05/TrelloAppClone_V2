import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AttachmentDownloadService {
  const AttachmentDownloadService();

  Future<File> download({required String url, required String fileName}) async {
    final directory =
        await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
    final destination = buildDestinationFile(
      directory: directory,
      fileName: fileName,
      url: url,
      exists: (path) => File(path).existsSync(),
    );

    await Dio().download(url, destination.path);
    return destination;
  }

  static File buildDestinationFile({
    required Directory directory,
    required String fileName,
    required String url,
    required bool Function(String path) exists,
  }) {
    final safeName = _safeFileName(fileName).isNotEmpty
        ? _safeFileName(fileName)
        : _safeFileName(_fileNameFromUrl(url));
    final resolvedName = safeName.isNotEmpty ? safeName : 'attachment';

    File candidate(String name) {
      return File('${directory.path}${Platform.pathSeparator}$name');
    }

    var file = candidate(resolvedName);
    if (!exists(file.path)) return file;

    final dotIndex = resolvedName.lastIndexOf('.');
    final hasExtension = dotIndex > 0 && dotIndex < resolvedName.length - 1;
    final baseName = hasExtension
        ? resolvedName.substring(0, dotIndex)
        : resolvedName;
    final extension = hasExtension ? resolvedName.substring(dotIndex) : '';

    var index = 1;
    do {
      file = candidate('$baseName ($index)$extension');
      index++;
    } while (exists(file.path));

    return file;
  }

  static String _fileNameFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final segment = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : '';
    return Uri.decodeComponent(segment);
  }

  static String _safeFileName(String value) {
    final trimmed = value.trim();
    final parts = trimmed
        .split(RegExp(r'[\\/]'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    final withoutPath = parts.isEmpty ? '' : parts.last.trim();

    return withoutPath
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'^\.+$'), '')
        .trim();
  }
}

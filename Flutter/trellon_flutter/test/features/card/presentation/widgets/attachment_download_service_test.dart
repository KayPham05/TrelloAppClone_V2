import 'dart:io';

import 'package:apptreolon/features/card/presentation/widgets/card_detail/attachment_download_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttachmentDownloadService', () {
    test(
      'uses a sanitized fallback file name when attachment name is unsafe',
      () {
        final file = AttachmentDownloadService.buildDestinationFile(
          directory: Directory.systemTemp,
          fileName: ' ../ ',
          url: 'https://example.com/uploads/demo.pdf',
          exists: (_) => false,
        );

        expect(file.path, endsWith('${Platform.pathSeparator}demo.pdf'));
      },
    );

    test(
      'adds a numeric suffix when a file with the same name already exists',
      () {
        final file = AttachmentDownloadService.buildDestinationFile(
          directory: Directory.systemTemp,
          fileName: 'demo.pdf',
          url: 'https://example.com/uploads/demo.pdf',
          exists: (path) => path.endsWith('demo.pdf'),
        );

        expect(file.path, endsWith('${Platform.pathSeparator}demo (1).pdf'));
      },
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apptreolon/features/card/presentation/cubit/card_detail_cubit.dart';
import 'package:apptreolon/features/card/presentation/cubit/card_detail_state.dart';
import 'package:apptreolon/features/card/domain/entities/card_entity.dart';
import 'package:apptreolon/features/card/domain/repositories/i_card_repository.dart';
import 'package:apptreolon/features/inbox/domain/repositories/i_inbox_repositories.dart';
import 'package:apptreolon/features/card/domain/usecases/add_card_comment_usecase.dart';
import 'package:apptreolon/features/card/domain/usecases/upload_attachment_usecase.dart';
import 'package:apptreolon/features/card/domain/usecases/get_attachments_usecase.dart';
import 'package:apptreolon/features/card/domain/usecases/delete_attachment_usecase.dart';
import 'package:apptreolon/features/card/domain/usecases/update_attachment_description_usecase.dart';
import 'package:apptreolon/features/card/domain/usecases/upload_card_cover_usecase.dart';
import 'package:apptreolon/features/card/domain/usecases/update_card_comment_usecase.dart';
import 'package:apptreolon/features/card/domain/usecases/delete_card_comment_usecase.dart';
import 'package:apptreolon/features/card/domain/usecases/upload_comment_attachment_usecase.dart';
import 'package:apptreolon/features/card/domain/usecases/delete_comment_attachment_usecase.dart';
import 'package:apptreolon/features/card/domain/usecases/update_attachment_name_usecase.dart';

// Mocks
class MockCardRepository extends Mock implements ICardRepository {}

class MockInboxRepositories extends Mock implements InboxRepositories {}

class MockAddCardCommentUseCase extends Mock implements AddCardCommentUseCase {}

class MockUploadAttachmentUseCase extends Mock
    implements UploadAttachmentUseCase {}

class MockGetAttachmentsUseCase extends Mock implements GetAttachmentsUseCase {}

class MockDeleteAttachmentUseCase extends Mock
    implements DeleteAttachmentUseCase {}

class MockUpdateAttachmentDescriptionUseCase extends Mock
    implements UpdateAttachmentDescriptionUseCase {}

class MockUploadCardCoverUseCase extends Mock
    implements UploadCardCoverUseCase {}

class MockUpdateCardCommentUseCase extends Mock
    implements UpdateCardCommentUseCase {}

class MockDeleteCardCommentUseCase extends Mock
    implements DeleteCardCommentUseCase {}

class MockUploadCommentAttachmentUseCase extends Mock
    implements UploadCommentAttachmentUseCase {}

class MockDeleteCommentAttachmentUseCase extends Mock
    implements DeleteCommentAttachmentUseCase {}

class MockUpdateAttachmentNameUseCase extends Mock
    implements UpdateAttachmentNameUseCase {}

void main() {
  late MockCardRepository mockRepository;
  late MockInboxRepositories mockInboxRepository;
  late MockAddCardCommentUseCase mockAddCardCommentUseCase;
  late MockUploadAttachmentUseCase mockUploadAttachmentUseCase;
  late MockGetAttachmentsUseCase mockGetAttachmentsUseCase;
  late MockDeleteAttachmentUseCase mockDeleteAttachmentUseCase;
  late MockUpdateAttachmentDescriptionUseCase
  mockUpdateAttachmentDescriptionUseCase;
  late MockUploadCardCoverUseCase mockUploadCardCoverUseCase;
  late MockUpdateCardCommentUseCase mockUpdateCardCommentUseCase;
  late MockDeleteCardCommentUseCase mockDeleteCardCommentUseCase;
  late MockUploadCommentAttachmentUseCase mockUploadCommentAttachmentUseCase;
  late MockDeleteCommentAttachmentUseCase mockDeleteCommentAttachmentUseCase;
  late MockUpdateAttachmentNameUseCase mockUpdateAttachmentNameUseCase;
  late CardDetailCubit cubit;

  const tCardId = 'card-123';
  const tFileId = 'file-456';
  const tUserUId = 'user-789';

  final tInitialCard = CardEntity(
    id: tCardId,
    title: 'Test Card',
    position: 0,
    fileUrls: [
      FileUrlEntity(
        id: tFileId,
        url: 'http://example.com/file.png',
        fileName: 'file.png',
      ),
    ],
  );

  final tComment = CommentEntity(
    id: 'comment-123',
    content: 'Test comment',
    createdAt: DateTime.utc(2026, 6, 14),
    userUId: tUserUId,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({'user_uid': tUserUId});

    mockRepository = MockCardRepository();
    mockInboxRepository = MockInboxRepositories();
    mockAddCardCommentUseCase = MockAddCardCommentUseCase();
    mockUploadAttachmentUseCase = MockUploadAttachmentUseCase();
    mockGetAttachmentsUseCase = MockGetAttachmentsUseCase();
    mockDeleteAttachmentUseCase = MockDeleteAttachmentUseCase();
    mockUpdateAttachmentDescriptionUseCase =
        MockUpdateAttachmentDescriptionUseCase();
    mockUploadCardCoverUseCase = MockUploadCardCoverUseCase();
    mockUpdateCardCommentUseCase = MockUpdateCardCommentUseCase();
    mockDeleteCardCommentUseCase = MockDeleteCardCommentUseCase();
    mockUploadCommentAttachmentUseCase = MockUploadCommentAttachmentUseCase();
    mockDeleteCommentAttachmentUseCase = MockDeleteCommentAttachmentUseCase();
    mockUpdateAttachmentNameUseCase = MockUpdateAttachmentNameUseCase();

    cubit = CardDetailCubit(
      mockRepository,
      mockInboxRepository,
      mockAddCardCommentUseCase,
      mockUploadAttachmentUseCase,
      mockGetAttachmentsUseCase,
      mockDeleteAttachmentUseCase,
      mockUpdateAttachmentDescriptionUseCase,
      mockUploadCardCoverUseCase,
      mockUpdateCardCommentUseCase,
      mockDeleteCardCommentUseCase,
      mockUploadCommentAttachmentUseCase,
      mockDeleteCommentAttachmentUseCase,
      mockUpdateAttachmentNameUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('renameAttachment', () {
    const tNewFileName = 'renamed-file.png';

    blocTest<CardDetailCubit, CardDetailState>(
      'should call updateAttachmentNameUseCase and emit new state with renamed file',
      build: () {
        when(
          () => mockUpdateAttachmentNameUseCase.call(
            cardId: any(named: 'cardId'),
            fileId: any(named: 'fileId'),
            userUId: any(named: 'userUId'),
            fileName: any(named: 'fileName'),
          ),
        ).thenAnswer((_) async => Future.value());
        return cubit;
      },
      seed: () => CardDetailLoaded(
        card: tInitialCard,
        todos: const [],
        members: const [],
        comments: const [],
      ),
      act: (cubit) => cubit.renameAttachment(tFileId, tNewFileName),
      verify: (_) {
        verify(
          () => mockUpdateAttachmentNameUseCase.call(
            cardId: tCardId,
            fileId: tFileId,
            userUId: tUserUId,
            fileName: tNewFileName,
          ),
        ).called(1);
      },
      expect: () => [
        isA<CardDetailLoaded>().having(
          (state) => state.card.fileUrls.first.fileName,
          'fileName',
          tNewFileName,
        ),
      ],
    );

    blocTest<CardDetailCubit, CardDetailState>(
      'should use inbox repository when renaming an inbox card attachment',
      build: () {
        when(
          () => mockInboxRepository.getTodoItems(cardId: any(named: 'cardId')),
        ).thenAnswer((_) async => const []);
        when(
          () => mockInboxRepository.getComments(cardId: any(named: 'cardId')),
        ).thenAnswer((_) async => const []);
        when(
          () =>
              mockInboxRepository.getAttachments(cardId: any(named: 'cardId')),
        ).thenAnswer((_) async => tInitialCard.fileUrls);
        when(
          () => mockInboxRepository.renameAttachment(
            cardId: any(named: 'cardId'),
            fileId: any(named: 'fileId'),
            userUId: any(named: 'userUId'),
            fileName: any(named: 'fileName'),
          ),
        ).thenAnswer((_) async => Future.value());
        return cubit;
      },
      act: (cubit) async {
        await cubit.loadCardDetails(tInitialCard, isInboxCard: true);
        await cubit.renameAttachment(tFileId, tNewFileName);
      },
      verify: (_) {
        verify(
          () => mockInboxRepository.renameAttachment(
            cardId: tCardId,
            fileId: tFileId,
            userUId: tUserUId,
            fileName: tNewFileName,
          ),
        ).called(1);
        verifyNever(
          () => mockUpdateAttachmentNameUseCase.call(
            cardId: any(named: 'cardId'),
            fileId: any(named: 'fileId'),
            userUId: any(named: 'userUId'),
            fileName: any(named: 'fileName'),
          ),
        );
      },
      expect: () => [
        isA<CardDetailLoading>(),
        isA<CardDetailLoaded>(),
        isA<CardDetailLoaded>().having(
          (state) => state.card.fileUrls.first.fileName,
          'fileName',
          tNewFileName,
        ),
      ],
    );
  });

  group('addComment attachments', () {
    blocTest<CardDetailCubit, CardDetailState>(
      'should attach uploaded files to both the new comment and card attachments',
      build: () {
        when(
          () => mockAddCardCommentUseCase.call(
            cardId: any(named: 'cardId'),
            content: any(named: 'content'),
            userUId: any(named: 'userUId'),
          ),
        ).thenAnswer((_) async => tComment);
        when(
          () => mockUploadCommentAttachmentUseCase.call(
            commentId: any(named: 'commentId'),
            filePath: any(named: 'filePath'),
            userUId: any(named: 'userUId'),
          ),
        ).thenAnswer(
          (_) async => const FileUrlEntity(
            id: 'comment-file-1',
            url: 'http://example.com/comment-file.pdf',
            fileName: 'comment-file.pdf',
          ),
        );
        when(
          () => mockUploadAttachmentUseCase.call(
            cardId: any(named: 'cardId'),
            filePath: any(named: 'filePath'),
            userUId: any(named: 'userUId'),
            description: any(named: 'description'),
          ),
        ).thenAnswer(
          (_) async => const FileUrlEntity(
            id: 'card-file-1',
            url: 'http://example.com/card-file.pdf',
            fileName: 'card-file.pdf',
          ),
        );
        return cubit;
      },
      seed: () => CardDetailLoaded(
        card: tInitialCard,
        todos: const [],
        members: const [],
        comments: const [],
      ),
      act: (cubit) => cubit.addComment(
        'Test comment',
        filePaths: const ['C:\\tmp\\comment-file.pdf'],
      ),
      verify: (_) {
        verify(
          () => mockUploadCommentAttachmentUseCase.call(
            commentId: tComment.id,
            filePath: 'C:\\tmp\\comment-file.pdf',
            userUId: tUserUId,
          ),
        ).called(1);
        verify(
          () => mockUploadAttachmentUseCase.call(
            cardId: tCardId,
            filePath: 'C:\\tmp\\comment-file.pdf',
            userUId: tUserUId,
          ),
        ).called(1);
      },
      expect: () => [
        isA<CardDetailLoaded>().having(
          (state) => state.comments.single.attachments,
          'comment attachments before upload finishes',
          isEmpty,
        ),
        isA<CardDetailLoaded>()
            .having(
              (state) => state.comments.single.attachments.single.id,
              'comment attachment id',
              'comment-file-1',
            )
            .having(
              (state) => state.card.fileUrls.map((file) => file.id),
              'card attachment ids',
              contains('card-file-1'),
            ),
      ],
    );
  });

  group('deleteAttachment', () {
    blocTest<CardDetailCubit, CardDetailState>(
      'should call deleteAttachmentUseCase and remove file from state',
      build: () {
        when(
          () => mockDeleteAttachmentUseCase.call(
            cardId: any(named: 'cardId'),
            fileId: any(named: 'fileId'),
            userUId: any(named: 'userUId'),
          ),
        ).thenAnswer((_) async => Future.value());
        return cubit;
      },
      seed: () => CardDetailLoaded(
        card: tInitialCard,
        todos: const [],
        members: const [],
        comments: const [],
      ),
      act: (cubit) => cubit.deleteAttachment(tFileId),
      verify: (_) {
        verify(
          () => mockDeleteAttachmentUseCase.call(
            cardId: tCardId,
            fileId: tFileId,
            userUId: tUserUId,
          ),
        ).called(1);
      },
      expect: () => [
        isA<CardDetailLoaded>().having(
          (state) => state.card.fileUrls,
          'fileUrls',
          isEmpty,
        ),
      ],
    );
  });
}

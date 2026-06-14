import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:apptreolon/features/card/domain/repositories/i_card_repository.dart';
import 'package:apptreolon/features/card/domain/usecases/update_attachment_name_usecase.dart';

class MockCardRepository extends Mock implements ICardRepository {}

void main() {
  late UpdateAttachmentNameUseCase useCase;
  late MockCardRepository mockRepository;

  setUp(() {
    mockRepository = MockCardRepository();
    useCase = UpdateAttachmentNameUseCase(mockRepository);
  });

  const tCardId = 'card-123';
  const tFileId = 'file-456';
  const tUserUId = 'user-789';
  const tFileName = 'new-file-name.pdf';

  test('should call renameAttachment on the repository', () async {
    // arrange
    when(() => mockRepository.renameAttachment(
          cardId: any(named: 'cardId'),
          fileId: any(named: 'fileId'),
          userUId: any(named: 'userUId'),
          fileName: any(named: 'fileName'),
        )).thenAnswer((_) async => Future.value());

    // act
    await useCase(
      cardId: tCardId,
      fileId: tFileId,
      userUId: tUserUId,
      fileName: tFileName,
    );

    // assert
    verify(() => mockRepository.renameAttachment(
          cardId: tCardId,
          fileId: tFileId,
          userUId: tUserUId,
          fileName: tFileName,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw an exception when repository throws', () async {
    // arrange
    when(() => mockRepository.renameAttachment(
          cardId: any(named: 'cardId'),
          fileId: any(named: 'fileId'),
          userUId: any(named: 'userUId'),
          fileName: any(named: 'fileName'),
        )).thenThrow(Exception('Failed to rename'));

    // assert
    expect(() => useCase(
      cardId: tCardId,
      fileId: tFileId,
      userUId: tUserUId,
      fileName: tFileName,
    ), throwsException);
  });
}

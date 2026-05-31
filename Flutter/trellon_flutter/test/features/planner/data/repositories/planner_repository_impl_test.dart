import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:apptreolon/features/planner/data/repositories/planner_repository_impl.dart';
import 'package:apptreolon/features/planner/data/datasources/planner_remote_data_source.dart';
import 'package:apptreolon/features/card/data/models/card_model.dart';
import 'package:apptreolon/features/card/domain/entities/card_entity.dart';

class MockPlannerRemoteDataSource extends Mock implements PlannerRemoteDataSource {}

void main() {
  late PlannerRepositoryImpl repository;
  late MockPlannerRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockPlannerRemoteDataSource();
    repository = PlannerRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  test('should return map of CardEntities when call to remote data source is successful', () async {
    // Arrange
    final from = DateTime(2023, 1, 1);
    final to = DateTime(2023, 1, 31);
    
    final tCardModel = CardModel(
      id: '1',
      title: 'Test Card',
      description: 'Desc',
      dueDate: DateTime(2023, 1, 15),
      position: 0,
      status: 'To Do',
      labels: const [],
      todoItems: const [],
      comments: const [],
      fileUrls: const [],
      members: const [],
    );
    
    final Map<String, List<CardModel>> expectedMap = {
      '2023-01-15': [tCardModel],
    };

    when(() => mockRemoteDataSource.getPlannerCards(from, to))
        .thenAnswer((_) async => expectedMap);

    // Act
    final result = await repository.getPlannerCards(from, to);

    // Assert
    expect(result, isA<Map<String, List<CardEntity>>>());
    expect(result.containsKey('2023-01-15'), true);
    expect(result['2023-01-15']!.first.id, '1');
    verify(() => mockRemoteDataSource.getPlannerCards(from, to)).called(1);
  });

  test('should throw an Exception when call to remote data source fails', () async {
    // Arrange
    final from = DateTime(2023, 1, 1);
    final to = DateTime(2023, 1, 31);
    
    when(() => mockRemoteDataSource.getPlannerCards(from, to))
        .thenThrow(Exception('Server error'));

    // Act
    final call = repository.getPlannerCards;

    // Assert
    expect(() => call(from, to), throwsException);
  });
}

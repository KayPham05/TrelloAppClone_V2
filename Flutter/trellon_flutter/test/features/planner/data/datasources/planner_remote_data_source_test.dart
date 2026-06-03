import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:apptreolon/features/planner/data/datasources/planner_remote_data_source.dart';
import 'package:apptreolon/features/card/data/models/card_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late PlannerRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = PlannerRemoteDataSourceImpl(dio: mockDio);
  });

  test('should return map of CardModel when status code is 200', () async {
    // Arrange
    final from = DateTime(2023, 1, 1);
    final to = DateTime(2023, 1, 31);
    
    final tResponseData = {
      '2023-01-15': [
        {
          'cardUId': '1',
          'title': 'Test Card',
          'dueDate': '2023-01-15T00:00:00.000',
          'position': 0,
          'createdAt': '2023-01-01T00:00:00.000',
          'status': 'To Do'
        }
      ]
    };
    
    when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
        .thenAnswer((_) async => Response(
              data: tResponseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: 'planner/calendar'),
            ));

    // Act
    final result = await dataSource.getPlannerCards(from, to);

    // Assert
    expect(result, isA<Map<String, List<CardModel>>>());
    expect(result.containsKey('2023-01-15'), true);
    expect(result['2023-01-15']!.first.id, '1');
    verify(() => mockDio.get(
      'planner/calendar', 
      queryParameters: {
        'from': '2023-01-01',
        'to': '2023-01-31',
      }
    )).called(1);
  });

  test('should throw Exception when status code is not 200', () async {
    // Arrange
    final from = DateTime(2023, 1, 1);
    final to = DateTime(2023, 1, 31);
    
    when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
        .thenAnswer((_) async => Response(
              data: 'Error',
              statusCode: 404,
              requestOptions: RequestOptions(path: 'planner/calendar'),
            ));

    // Act
    final call = dataSource.getPlannerCards;

    // Assert
    expect(() => call(from, to), throwsException);
  });
}

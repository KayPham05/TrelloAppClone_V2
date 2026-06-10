import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:apptreolon/core/constants/api_endpoints.dart';
import 'package:apptreolon/features/search/data/datasources/search_remote_data_source.dart';
import 'package:apptreolon/features/search/data/models/search_result_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late SearchRemoteDataSource dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = SearchRemoteDataSource(client: mockDio);
  });

  group('search', () {
    final tQuery = 'test';
    final tUserUId = 'user-123';
    
    final tJsonResponse = {
      'boards': [
        {
          'boardUId': 'b1',
          'boardName': 'Board 1',
        }
      ],
      'cards': [
        {
          'cardUId': 'c1',
          'title': 'Card 1',
        }
      ]
    };

    test('should return SearchResultModel when the response code is 200', () async {
      // arrange
      when(() => mockDio.get(
            ApiEndpoints.search,
            queryParameters: {
              'q': tQuery,
              'userUId': tUserUId,
            },
          )).thenAnswer((_) async => Response(
            data: tJsonResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.search),
          ));

      // act
      final result = await dataSource.search(tQuery, tUserUId);

      // assert
      expect(result, isA<SearchResultModel>());
      expect(result.boards.length, 1);
      expect(result.boards.first.boardName, 'Board 1');
      expect(result.cards.length, 1);
      expect(result.cards.first.title, 'Card 1');
      
      verify(() => mockDio.get(
            ApiEndpoints.search,
            queryParameters: {
              'q': tQuery,
              'userUId': tUserUId,
            },
          )).called(1);
    });

    test('should throw an Exception when the response code is not 200', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: 'Something went wrong',
            statusCode: 404,
            requestOptions: RequestOptions(path: ApiEndpoints.search),
          ));

      // act
      final call = dataSource.search;

      // assert
      expect(() => call(tQuery, tUserUId), throwsException);
    });

    test('should throw an Exception when Dio throws a DioException', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: ApiEndpoints.search),
            error: 'Connection failed',
          ));

      // act
      final call = dataSource.search;

      // assert
      expect(() => call(tQuery, tUserUId), throwsException);
    });
  });
}

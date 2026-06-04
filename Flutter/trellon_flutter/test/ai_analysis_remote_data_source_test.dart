import 'package:apptreolon/features/ai_analysis/data/datasources/ai_analysis_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class MockDio extends Fake implements Dio {
  final Future<Response<dynamic>> Function(
    String path, {
    Object? data,
    Options? options,
    Map<String, dynamic>? queryParameters,
  })
  onGet;

  MockDio({required this.onGet});

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    final response = await onGet(
      path,
      data: data,
      options: options,
      queryParameters: queryParameters,
    );
    return response as Response<T>;
  }
}

void main() {
  group('AiAnalysisRemoteDataSource', () {
    test('analyzeBoard calls analysis board endpoint with user id', () async {
      final dio = MockDio(
        onGet: (path, {data, options, queryParameters}) async {
          expect(path, 'analysis/board/board-1');
          expect(queryParameters, {'userUId': 'user-1'});
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {
              'scopeType': 'board',
              'scopeUId': 'board-1',
              'title': 'Board',
              'overallProgress': 50,
              'summary': 'Ok',
              'metrics': {},
            },
          );
        },
      );
      final dataSource = AiAnalysisRemoteDataSourceImpl(client: dio);

      final result = await dataSource.analyzeBoard(
        boardUId: 'board-1',
        userUId: 'user-1',
      );

      expect(result.scopeUId, 'board-1');
      expect(result.overallProgress, 50);
    });

    test('analyzeBoard sends force refresh when requested', () async {
      final dio = MockDio(
        onGet: (path, {data, options, queryParameters}) async {
          expect(path, 'analysis/board/board-1');
          expect(queryParameters, {'userUId': 'user-1', 'forceRefresh': true});
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {
              'scopeType': 'board',
              'scopeUId': 'board-1',
              'title': 'Board',
              'overallProgress': 50,
              'summary': 'Ok',
              'metrics': {},
            },
          );
        },
      );
      final dataSource = AiAnalysisRemoteDataSourceImpl(client: dio);

      final result = await dataSource.analyzeBoard(
        boardUId: 'board-1',
        userUId: 'user-1',
        forceRefresh: true,
      );

      expect(result.scopeUId, 'board-1');
    });

    test('throws readable error for forbidden response', () async {
      final dio = MockDio(
        onGet: (path, {data, options, queryParameters}) async {
          throw DioException(
            requestOptions: RequestOptions(path: path),
            response: Response(
              requestOptions: RequestOptions(path: path),
              statusCode: 403,
              data: {'message': 'Bạn không có quyền phân tích board này.'},
            ),
          );
        },
      );
      final dataSource = AiAnalysisRemoteDataSourceImpl(client: dio);

      expect(
        () => dataSource.analyzeBoard(boardUId: 'board-1', userUId: 'viewer'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Bạn không có quyền'),
          ),
        ),
      );
    });
  });
}

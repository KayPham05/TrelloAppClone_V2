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
  final Future<Response<dynamic>> Function(
    String path, {
    Object? data,
    Options? options,
    Map<String, dynamic>? queryParameters,
  })?
  onPost;

  MockDio({required this.onGet, this.onPost});

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

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    final handler = onPost;
    if (handler == null) {
      throw UnsupportedError('POST was not expected.');
    }
    final response = await handler(
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
    test(
      'analyzeBoard calls analysis board endpoint without user id query',
      () async {
        final dio = MockDio(
          onGet: (path, {data, options, queryParameters}) async {
            expect(path, 'analysis/board/board-1');
            expect(queryParameters, isEmpty);
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

        final result = await dataSource.analyzeBoard(boardUId: 'board-1');

        expect(result.scopeUId, 'board-1');
        expect(result.overallProgress, 50);
      },
    );

    test('analyzeBoard sends force refresh when requested', () async {
      final dio = MockDio(
        onGet: (path, {data, options, queryParameters}) async {
          expect(path, 'analysis/board/board-1');
          expect(queryParameters, {'forceRefresh': true});
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
        () => dataSource.analyzeBoard(boardUId: 'board-1'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Bạn không có quyền'),
          ),
        ),
      );
    });

    test('getReportHistory calls history endpoint with paging only', () async {
      final dio = MockDio(
        onGet: (path, {data, options, queryParameters}) async {
          expect(path, 'analysis/history/board/board-1');
          expect(queryParameters, {'page': 2, 'pageSize': 5});
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {
              'items': [
                {
                  'reportUId': 'report-1',
                  'scopeType': 'board',
                  'scopeUId': 'board-1',
                  'title': 'Board',
                  'overallProgress': 50,
                  'model': 'gemini-test',
                  'generatedAt': '2026-06-02T00:00:00Z',
                },
              ],
              'totalCount': 6,
              'page': 2,
              'pageSize': 5,
              'hasMore': false,
            },
          );
        },
      );
      final dataSource = AiAnalysisRemoteDataSourceImpl(client: dio);

      final result = await dataSource.getReportHistory(
        scopeType: 'board',
        scopeUId: 'board-1',
        page: 2,
        pageSize: 5,
      );

      expect(result.items.single.reportUId, 'report-1');
      expect(result.page, 2);
    });

    test('getReportById calls report endpoint', () async {
      final dio = MockDio(
        onGet: (path, {data, options, queryParameters}) async {
          expect(path, 'analysis/report/report-1');
          expect(queryParameters, isEmpty);
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
              'cached': false,
            },
          );
        },
      );
      final dataSource = AiAnalysisRemoteDataSourceImpl(client: dio);

      final result = await dataSource.getReportById(reportUId: 'report-1');

      expect(result.scopeUId, 'board-1');
      expect(result.cached, false);
    });

    test('saveCurrentReport calls save endpoint', () async {
      final dio = MockDio(
        onGet: (path, {data, options, queryParameters}) async {
          throw UnsupportedError('GET was not expected.');
        },
        onPost: (path, {data, options, queryParameters}) async {
          expect(path, 'analysis/report/save/board/board-1');
          expect(queryParameters, isNull);
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {
              'reportUId': 'report-1',
              'scopeType': 'board',
              'scopeUId': 'board-1',
              'title': 'Board',
              'overallProgress': 50,
              'modelUsed': 'gemini-test',
              'generatedAt': '2026-06-02T00:00:00Z',
            },
          );
        },
      );
      final dataSource = AiAnalysisRemoteDataSourceImpl(client: dio);

      final result = await dataSource.saveCurrentReport(
        scopeType: 'board',
        scopeUId: 'board-1',
      );

      expect(result.reportUId, 'report-1');
      expect(result.model, 'gemini-test');
    });
  });
}

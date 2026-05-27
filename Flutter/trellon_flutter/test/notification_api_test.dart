import 'package:apptreolon/features/activity/data/datasources/notification_remote_datasource.dart';
import 'package:apptreolon/features/activity/domain/entities/notification_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class MockDio extends Fake implements Dio {
  final Future<Response<dynamic>> Function(
    String path, {
    Object? data,
    Options? options,
    Map<String, dynamic>? queryParameters,
  })? onGet;
  final Future<Response<dynamic>> Function(
    String path, {
    Object? data,
    Options? options,
    Map<String, dynamic>? queryParameters,
  })? onPatch;
  final Future<Response<dynamic>> Function(
    String path, {
    Object? data,
    Options? options,
    Map<String, dynamic>? queryParameters,
  })? onDelete;

  MockDio({this.onGet, this.onPatch, this.onDelete});

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    if (onGet != null) {
      final res = await onGet!(
        path,
        data: data,
        options: options,
        queryParameters: queryParameters,
      );
      return res as Response<T>;
    }
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    if (onPatch != null) {
      final res = await onPatch!(
        path,
        data: data,
        options: options,
        queryParameters: queryParameters,
      );
      return res as Response<T>;
    }
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (onDelete != null) {
      final res = await onDelete!(
        path,
        data: data,
        options: options,
        queryParameters: queryParameters,
      );
      return res as Response<T>;
    }
    throw UnimplementedError();
  }
}

void main() {
  group('NotificationRemoteDataSource', () {
    test('getNotifications parses paged response with server unread count', () async {
      final mockDio = MockDio(
        onGet: (path, {data, options, queryParameters}) async {
          expect(path, 'notifications');
          expect(queryParameters, {'page': 1, 'pageSize': 20, 'tab': 'all'});
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {
              'items': [
                {
                  'notiId': 'noti-123',
                  'recipientId': 'user-1',
                  'actorId': 'user-2',
                  'actorName': 'John Doe',
                  'type': 0,
                  'title': 'commented',
                  'message': 'Comment content',
                  'createdAt': '2023-10-01T12:00:00Z',
                  'read': false,
                }
              ],
              'unreadCount': 7,
              'hasMore': false,
            },
          );
        },
      );

      final dataSource = NotificationRemoteDataSourceImpl(dio: mockDio);

      final result = await dataSource.getNotifications(
        page: 1,
        pageSize: 20,
        tab: 'all',
      );

      expect(result.items.length, 1);
      expect(result.unreadCount, 7);
      expect(result.hasMore, false);
      expect(result.items.first.id, 'noti-123');
      expect(result.items.first.actorName, 'John Doe');
      expect(result.items.first.type, NotificationTypeEnum.comment);
      expect(result.items.first.isRead, false);
    });

    test('markAsRead returns true on 200', () async {
      final mockDio = MockDio(
        onPatch: (path, {data, options, queryParameters}) async {
          expect(path, 'notifications/noti-123/read');
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {},
          );
        },
      );

      final dataSource = NotificationRemoteDataSourceImpl(dio: mockDio);

      expect(await dataSource.markAsRead(notiId: 'noti-123'), true);
    });

    test('markAllAsRead returns updated count from response', () async {
      final mockDio = MockDio(
        onPatch: (path, {data, options, queryParameters}) async {
          expect(path, 'notifications/read-all');
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {'updatedCount': 3},
          );
        },
      );

      final dataSource = NotificationRemoteDataSourceImpl(dio: mockDio);

      expect(await dataSource.markAllAsRead(), 3);
    });

    test('deleteNotification returns true on 200', () async {
      final mockDio = MockDio(
        onDelete: (path, {data, options, queryParameters}) async {
          expect(path, 'notifications/noti-123');
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {},
          );
        },
      );

      final dataSource = NotificationRemoteDataSourceImpl(dio: mockDio);

      expect(await dataSource.deleteNotification(notiId: 'noti-123'), true);
    });
  });
}

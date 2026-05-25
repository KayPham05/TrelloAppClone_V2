import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:apptreolon/features/activity/data/datasources/notification_remote_datasource.dart';
import 'package:apptreolon/features/activity/domain/entities/notification_entity.dart';

class MockDio extends Fake implements Dio {
  final Future<Response<dynamic>> Function(String path, {Object? data, Options? options, Map<String, dynamic>? queryParameters})? onGet;
  final Future<Response<dynamic>> Function(String path, {Object? data, Options? options, Map<String, dynamic>? queryParameters})? onPatch;
  final Future<Response<dynamic>> Function(String path, {Object? data, Options? options, Map<String, dynamic>? queryParameters})? onDelete;

  MockDio({this.onGet, this.onPatch, this.onDelete});

  @override
  Future<Response<T>> get<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, void Function(int, int)? onReceiveProgress}) async {
    if (onGet != null) {
      final res = await onGet!(path, data: data, options: options, queryParameters: queryParameters);
      return res as Response<T>;
    }
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> patch<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, void Function(int, int)? onSendProgress, void Function(int, int)? onReceiveProgress}) async {
    if (onPatch != null) {
      final res = await onPatch!(path, data: data, options: options, queryParameters: queryParameters);
      return res as Response<T>;
    }
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> delete<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async {
    if (onDelete != null) {
      final res = await onDelete!(path, data: data, options: options, queryParameters: queryParameters);
      return res as Response<T>;
    }
    throw UnimplementedError();
  }
}

void main() {
  group('NotificationRemoteDataSource Tests', () {
    test('getNotifications trả về danh sách NotificationModel khi API thành công (200)', () async {
      print('\n======================================================');
      print('TEST CASE: getNotifications - Success (200)');
      print('======================================================');
      
      final mockData = [
        {
          "notiId": "noti-123",
          "recipientId": "user-1",
          "actorId": "user-2",
          "actor": {"userName": "John Doe"},
          "type": 0,
          "title": "đã bình luận",
          "message": "Nội dung bình luận...",
          "createdAt": "2023-10-01T12:00:00Z",
          "read": false
        }
      ];

      final mockDio = MockDio(
        onGet: (path, {data, options, queryParameters}) async {
          print('[MOCK] Call GET: $path');
          print('[MOCK] Query Params: $queryParameters');
          print('[MOCK] Returning Data: $mockData');
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: mockData,
          );
        },
      );

      final dataSource = NotificationRemoteDataSourceImpl(dio: mockDio);

      print('\n[ACT] Calling dataSource.getNotifications(page: 1, pageSize: 20)...');
      final result = await dataSource.getNotifications(page: 1, pageSize: 20);

      print('\n[ASSERT] Verifying parsed data:');
      print(' - Result Count: ${result.length}');
      expect(result.length, 1);
      
      final first = result.first;
      print(' - Notification ID: ${first.id}');
      print(' - Actor Name: ${first.actorName}');
      print(' - Notification Type: ${first.type}');
      print(' - Message: ${first.message}');
      print(' - Is Read: ${first.isRead}');
      
      expect(first.id, "noti-123");
      expect(first.actorName, "John Doe");
      expect(first.type, NotificationTypeEnum.comment);
      expect(first.isRead, false);
      print('Result: PASSED');
    });

    test('markAsRead trả về true khi API thành công (200)', () async {
      print('\n======================================================');
      print('TEST CASE: markAsRead - Success (200)');
      print('======================================================');
      
      final targetId = "noti-123";

      final mockDio = MockDio(
        onPatch: (path, {data, options, queryParameters}) async {
          print('[MOCK] Call PATCH: $path');
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {},
          );
        },
      );

      final dataSource = NotificationRemoteDataSourceImpl(dio: mockDio);

      print('\n[ACT] Calling dataSource.markAsRead(notiId: $targetId)...');
      final result = await dataSource.markAsRead(notiId: targetId);

      print('\n[ASSERT] Verifying response:');
      print(' - Return value: $result');
      expect(result, true);
      print('Result: PASSED');
    });

    test('markAllAsRead trả về 1 khi API thành công (200)', () async {
      print('\n======================================================');
      print('TEST CASE: markAllAsRead - Success (200)');
      print('======================================================');

      final mockDio = MockDio(
        onPatch: (path, {data, options, queryParameters}) async {
          print('[MOCK] Call PATCH: $path');
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {"message": "Success"},
          );
        },
      );

      final dataSource = NotificationRemoteDataSourceImpl(dio: mockDio);

      print('\n[ACT] Calling dataSource.markAllAsRead()...');
      final result = await dataSource.markAllAsRead();

      print('\n[ASSERT] Verifying response:');
      print(' - Return value: $result');
      expect(result, 1);
      print('Result: PASSED');
    });

    test('deleteNotification trả về true khi API thành công (200)', () async {
      print('\n======================================================');
      print('TEST CASE: deleteNotification - Success (200)');
      print('======================================================');
      
      final targetId = "noti-123";

      final mockDio = MockDio(
        onDelete: (path, {data, options, queryParameters}) async {
          print('[MOCK] Call DELETE: $path');
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {},
          );
        },
      );

      final dataSource = NotificationRemoteDataSourceImpl(dio: mockDio);

      print('\n[ACT] Calling dataSource.deleteNotification(notiId: $targetId)...');
      final result = await dataSource.deleteNotification(notiId: targetId);

      print('\n[ASSERT] Verifying response:');
      print(' - Return value: $result');
      expect(result, true);
      print('Result: PASSED');
    });
  });
}

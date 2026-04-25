import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import '../lib/features/activity/data/datasources/notification_remote_datasource.dart';
import '../lib/features/activity/domain/entities/notification_entity.dart';

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
      // 1. Arrange: Giả lập Dio trả về JSON mẫu
      final mockDio = MockDio(
        onGet: (path, {data, options, queryParameters}) async {
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: [
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
            ],
          );
        },
      );

      final dataSource = NotificationRemoteDataSourceImpl(dio: mockDio);

      // 2. Act: Gọi phương thức getNotifications
      final result = await dataSource.getNotifications(page: 1, pageSize: 20);

      // 3. Assert: Kiểm tra dữ liệu được parse đúng không
      expect(result.length, 1);
      expect(result.first.id, "noti-123");
      expect(result.first.actorName, "John Doe");
      expect(result.first.type, NotificationTypeEnum.comment);
      expect(result.first.isRead, false);
      expect(result.first.message, "Nội dung bình luận...");
    });

    test('markAsRead trả về true khi API thành công (200)', () async {
      // Arrange
      final mockDio = MockDio(
        onPatch: (path, {data, options, queryParameters}) async {
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {},
          );
        },
      );

      final dataSource = NotificationRemoteDataSourceImpl(dio: mockDio);

      // Act
      final result = await dataSource.markAsRead(notiId: "noti-123");

      // Assert
      expect(result, true);
    });

    test('markAllAsRead trả về 1 khi API thành công (200)', () async {
      // Arrange
      final mockDio = MockDio(
        onPatch: (path, {data, options, queryParameters}) async {
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {"message": "Success"},
          );
        },
      );

      final dataSource = NotificationRemoteDataSourceImpl(dio: mockDio);

      // Act
      final result = await dataSource.markAllAsRead();

      // Assert
      expect(result, 1);
    });

    test('deleteNotification trả về true khi API thành công (200)', () async {
      // Arrange
      final mockDio = MockDio(
        onDelete: (path, {data, options, queryParameters}) async {
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {},
          );
        },
      );

      final dataSource = NotificationRemoteDataSourceImpl(dio: mockDio);

      // Act
      final result = await dataSource.deleteNotification(notiId: "noti-123");

      // Assert
      expect(result, true);
    });
  });
}

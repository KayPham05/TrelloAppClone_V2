import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/board_model.dart';

abstract class BoardRemoteDataSource {
  Future<List<BoardModel>> getRecentBoards(String userUid);
  Future<List<BoardModel>> getAllBoards(String userUid);
  Future<void> createBoard({
    required String name,
    required String userUid,
    String? workspaceId,
    bool isPersonal = false,
    String? backgroundUrl,
    String? coverColor,
    String? visibility,
  });
}

class BoardRemoteDataSourceImpl implements BoardRemoteDataSource {
  final Dio client;

  BoardRemoteDataSourceImpl({required this.client});

  @override
  Future<List<BoardModel>> getRecentBoards(String userUid) async {
    try {
      final response = await client.get(
        '${ApiEndpoints.boards}/${ApiEndpoints.recentBoards}',
        queryParameters: {'userUId': userUid},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) {
          final boardMap = json['board'] ?? json;
          return BoardModel.fromJson(boardMap);
        }).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow;
    } catch (e) {
      throw Exception('Failed to load recent boards: $e');
    }
  }

  @override
  Future<List<BoardModel>> getAllBoards(String userUid) async {
    try {
      final response = await client.get(
        ApiEndpoints.boards,
        queryParameters: {'userUId': userUid},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => BoardModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow;
    } catch (e) {
      throw Exception('Failed to load all boards: $e');
    }
  }

  @override
  Future<void> createBoard({
    required String name,
    required String userUid,
    String? workspaceId,
    bool isPersonal = false,
    String? backgroundUrl,
    String? coverColor,
    String? visibility,
  }) async {
    try {
      await client.post(
        ApiEndpoints.boards,
        data: {
          'boardName': name,
          'userUId': userUid,
          'workspaceUId': workspaceId,
          'backgroundUrl': backgroundUrl,
          'visibility': visibility ?? 'Private',
          'isPersonal': isPersonal,
          'status': 'Active',
        },
      );
    } catch (e) {
      throw Exception('Failed to create board: $e');
    }
  }
}


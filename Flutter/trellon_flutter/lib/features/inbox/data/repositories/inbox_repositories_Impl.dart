import 'package:apptreolon/core/constants/api_endpoints.dart';
import 'package:apptreolon/features/card/domain/entities/card_entity.dart';
import 'package:apptreolon/features/inbox/domain/repositories/i_inbox_repositories.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../card/data/models/card_model.dart';

List<CardEntity> _parseInboxCards(List<dynamic> rawCards) {
  return rawCards
      .map(
        (item) => CardModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        ).toEntity(),
      )
      .toList(growable: false);
}

class InboxRepositoriesImpl extends InboxRepositories {
  final Dio dio;
  InboxRepositoriesImpl({required this.dio});

  @override
  Future<List<CardEntity>> getInboxCard({required String userUId}) async {
    try {
      final response = await dio.get('${ApiEndpoints.userInbox}/$userUId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        return compute(_parseInboxCards, data);
      }
      throw Exception("Lỗi lấy dữ liệu");
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        throw Exception(data['message']);
      } else if (data is String) {
        throw Exception(data);
      }
      throw Exception("Lỗi kết nối server");
    }
  }

  @override
  Future<CardEntity> addInboxCard({
    required String userUId,
    required String cardTitle,
  }) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.card}/$userUId/inbox',
        data: {'title': cardTitle},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CardModel.fromJson(response.data).toEntity();
      }
      throw Exception("Lỗi khi thêm thẻ");
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        throw Exception(data['message']);
      } else if (data is String) {
        throw Exception(data);
      }
      throw Exception("Lỗi kết nối server");
    }
  }
}

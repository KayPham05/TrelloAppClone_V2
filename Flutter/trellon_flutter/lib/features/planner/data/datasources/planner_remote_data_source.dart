import 'package:dio/dio.dart';
import '../../../card/data/models/card_model.dart';

abstract class PlannerRemoteDataSource {
  Future<Map<String, List<CardModel>>> getPlannerCards(DateTime from, DateTime to);
}

class PlannerRemoteDataSourceImpl implements PlannerRemoteDataSource {
  final Dio dio;

  PlannerRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, List<CardModel>>> getPlannerCards(DateTime from, DateTime to) async {
    try {
      final fromStr = '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
      final toStr = '${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}';
      
      final response = await dio.get('/v1/api/planner/calendar', queryParameters: {
        'from': fromStr,
        'to': toStr,
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final Map<String, List<CardModel>> result = {};
        
        data.forEach((key, value) {
          if (value is List) {
            result[key] = value.map((e) => CardModel.fromJson(e)).toList();
          }
        });
        
        return result;
      } else {
        throw Exception('Failed to load planner cards');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu planner: $e');
    }
  }
}

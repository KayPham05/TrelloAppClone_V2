import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/search_result_model.dart';

class SearchRemoteDataSource {
  final Dio client;

  SearchRemoteDataSource({required this.client});

  Future<SearchResultModel> search(String query, String userUId) async {
    try {
      final response = await client.get(
        ApiEndpoints.search,
        queryParameters: {
          'q': query,
          'userUId': userUId,
        },
      );
      
      if (response.statusCode == 200) {
        return SearchResultModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      throw Exception('Failed to perform search: $e');
    }
  }
}

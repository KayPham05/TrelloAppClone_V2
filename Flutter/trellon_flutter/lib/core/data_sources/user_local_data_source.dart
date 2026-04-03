import 'package:shared_preferences/shared_preferences.dart';

class UserLocalDataSource {
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }
}
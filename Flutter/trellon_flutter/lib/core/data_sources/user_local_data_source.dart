import 'package:shared_preferences/shared_preferences.dart';

class UserLocalDataSource {
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  Future<bool> getHasSeenIntroduction() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_introduction') ?? false;
  }

  Future<void> setHasSeenIntroduction(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_introduction', value);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
    await prefs.remove('access_token');
    await prefs.remove('user_name');
  }
}

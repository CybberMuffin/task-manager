import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<String> getReminders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('reminders');
  }

  static Future<bool> setReminders(String reminders) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('reminders', reminders);
  }

  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String> getSort() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('sort');
  }

  static setSort(String sort) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sort', sort);
  }
}

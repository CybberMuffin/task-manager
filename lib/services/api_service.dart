import 'package:http/http.dart' as http;
import 'package:task_manager/models/task.dart';
import 'dart:convert' as convert;
import 'package:task_manager/services/local_storage.dart';

class ApiService {
  static final String _apiUrl = 'https://testapi.doitserver.in.ua/api';

  static Future<dynamic> registerUser(Map<String, String> requestData) async {
    return await http.post('$_apiUrl/users', body: requestData);
  }

  static Future<dynamic> authorizeUser(Map<String, String> requestData) async {
    return await http.post('$_apiUrl/auth', body: requestData);
  }

  static Future<dynamic> createTask(Map<String, dynamic> json) async {
    return await http.post('$_apiUrl/tasks',
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer ' + await LocalStorage.getToken(),
          'Content-Type': 'application/json'
        },
        body: convert.jsonEncode(json));
  }

  static Future<dynamic> downloadTasks() async {
    return await http.get(
      '$_apiUrl/tasks',
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer ' + await LocalStorage.getToken(),
      },
    );
  }

  static Future editTask(
      int id, String title, DateTime date, Priority priority) async {
    return await http.put('$_apiUrl/tasks/$id',
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer ' + await LocalStorage.getToken(),
          'Content-Type': 'application/json',
        },
        body: convert.jsonEncode(Task.toJson(title, date, priority)));
  }

  static Future deleteTask(int id) async {
    return await http.delete('$_apiUrl/tasks/$id', headers: {
      'accept': 'application/json',
      'Authorization': 'Bearer ' + await LocalStorage.getToken(),
    });
  }
}

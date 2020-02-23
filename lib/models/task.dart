import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';

enum Priority {
  Low,
  Normal,
  High,
}

class Task {
  final int id;
  final String title;
  final Priority priority;
  final DateTime expirationDate;

  Task(
      {@required this.id,
      @required this.title,
      @required this.priority,
      @required this.expirationDate});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      priority: EnumToString.fromString(Priority.values, json['priority']),
      expirationDate:
          DateTime.fromMicrosecondsSinceEpoch(json['dueBy'] * 1000000),
    );
  }

  static toJson(String title, DateTime expirationDate, Priority priority) {
    int dueBy = (expirationDate.millisecondsSinceEpoch / 1000).round();
    print('due BY ==> ' + dueBy.toString());
    return {
      'title': title,
      'dueBy': dueBy,
      'priority': EnumToString.parse(priority),
    };
  }
}

import 'package:date_format/date_format.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/main.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/api_service.dart';
import 'package:task_manager/services/local_storage.dart';
import 'package:task_manager/views/reminders_screen.dart';
import 'package:task_manager/views/settings_page.dart';
import 'package:task_manager/views/task_creation_page.dart';
import 'dart:convert' as convert;
import 'package:task_manager/views/task_details_page.dart';

Map<Priority, Icon> priorityIcon = {
  Priority.Low: Icon(Icons.arrow_downward, size: 18.0),
  Priority.Normal: Icon(Icons.blur_circular, size: 18.0),
  Priority.High: Icon(Icons.arrow_upward, size: 18.0),
};

enum SortBy { name, priority, date }

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> _taskList = [];
  final globalKey = GlobalKey<ScaffoldState>();
  SortBy _selectedSort;
  bool _asc = true;

  @override
  void initState() {
    super.initState();
    _downloadTasks();
    _applySettings();
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      leading: IconButton(
        icon: Icon(Icons.notifications),
        onPressed: () => _navigateToReminders(),
      ),
      title: Text('My Tasks'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => _navigateToSettings(),
        ),
        GestureDetector(
          onTap: () => _sortList(_selectedSort),
          child: Row(
            children: <Widget>[
              Icon(_asc ? Icons.arrow_downward : Icons.arrow_upward),
              Text(EnumToString.parseCamelCase(_selectedSort) ?? "None"),
            ],
          ),
        ),
        PopupMenuButton(
          icon: Icon(Icons.sort),
          onSelected: (SortBy result) => _sortList(result),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<SortBy>>[
            PopupMenuItem<SortBy>(
              value: SortBy.name,
              child: Text(EnumToString.parseCamelCase(SortBy.name)),
            ),
            PopupMenuItem<SortBy>(
              value: SortBy.date,
              child: Text(EnumToString.parseCamelCase(SortBy.date)),
            ),
            PopupMenuItem<SortBy>(
              value: SortBy.priority,
              child: Text(EnumToString.parseCamelCase(SortBy.priority)),
            ),
          ],
        ),
      ],
    );

    var listView = _taskList.isNotEmpty
        ? ListView.separated(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: _taskList.length,
            separatorBuilder: (context, _) => Divider(),
            itemBuilder: (context, index) => ListTile(
              onTap: () => _navigateToTaskDetails(
                _taskList[index].id,
                _taskList[index].title,
                _taskList[index].expirationDate,
                _taskList[index].priority,
              ),
              title: Text(
                _taskList[index].title.length > 40
                    ? _taskList[index].title.substring(0, 30) + '...'
                    : _taskList[index].title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.keyboard_arrow_right, size: 34.0),
              subtitle: Container(
                margin: EdgeInsets.only(top: 10.0),
                child: Row(
                  children: <Widget>[
                    Text('Due to '),
                    Text(
                      formatDate(
                        _taskList[index].expirationDate,
                        [dd, '/', mm, '/', yyyy],
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 12.0),
                      child: Row(
                        children: <Widget>[
                          priorityIcon[_taskList[index].priority],
                          Text(
                            ' ' + EnumToString.parse(_taskList[index].priority),
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Center(
            child: Container(),
          );

    return Scaffold(
      key: globalKey,
      appBar: appBar,
      body: RefreshIndicator(
        child: listView,
        onRefresh: () async => await _downloadTasks(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _navigateToTaskCreation(),
      ),
    );
  }

  void _applySettings() async {
    String s = await LocalStorage.getSort();
    _sortList(EnumToString.fromString(SortBy.values, s));
  }

  void _sortList(SortBy sortType) {
    if (_selectedSort == sortType)
      setState(() {
        _taskList = _taskList.reversed.toList();
        _asc = !_asc;
      });
    else {
      setState(() => _asc = true);
      _selectedSort = sortType;
      switch (sortType) {
        case SortBy.name:
          setState(() => _taskList.sort((a, b) =>
              a.title.toLowerCase().compareTo(b.title.toLowerCase())));
          break;
        case SortBy.date:
          setState(() => _taskList.sort((a, b) => a.expirationDate.millisecond
              .compareTo(b.expirationDate.millisecond)));
          break;
        case SortBy.priority:
          setState(() => _taskList.sort((a, b) => Priority.values
              .indexOf(a.priority)
              .compareTo(Priority.values.indexOf(b.priority))));
          break;
        default:
      }
    }
  }

  Future _downloadTasks() async {
    _taskList = [];
    var response = await ApiService.downloadTasks();

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);

      setState(() => jsonResponse['tasks']
          .forEach((jsonTask) => _taskList.add(Task.fromJson(jsonTask))));
    }
  }

  Future _createTask(Map<String, dynamic> json) async {
    var response = await ApiService.createTask(json);
    var jsonResponse = convert.jsonDecode(response.body);

    switch (response.statusCode) {
      case 201:
        Task task = Task.fromJson(jsonResponse['task']);
        setState(() => _taskList.add(task));
        notificationService.sheludedNotification(
            task.id,
            task.title,
            EnumToString.parse(task.priority) + ' priority',
            task.expirationDate);
        showSnackBar('The task was successfully added');
        break;
      case 403:
        showSnackBar(jsonResponse['message']);
        break;
      case 422:
        showSnackBar(jsonResponse['message'] ?? 'Something went wrong');
        break;
      default:
        showSnackBar('Something went wrong');
        break;
    }
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  void _navigateToTaskCreation() async {
    final Map<String, dynamic> json = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskCreationPage()),
    );

    if (json != null) _createTask(json);
  }

  void _navigateToTaskDetails(
      int id, String title, DateTime date, Priority priority) async {
    final bool editResult = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TaskDetailsPage(id, title, date, priority)),
    );

    if (editResult != null) {
      if (editResult) {
        _downloadTasks();
        showSnackBar('The task was successfully updated');
      } else {
        setState(() => _taskList.removeWhere((task) => task.id == id));
        notificationService.deleteNotification(id);
        showSnackBar('The task was successfully removed');
      }
    }
  }

  void _navigateToReminders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RemindersScreen()),
    );
  }

  void showSnackBar(String text) {
    final snackBar = SnackBar(
      content: Text(text),
    );
    globalKey.currentState.showSnackBar(snackBar);
  }
}

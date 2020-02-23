import 'package:date_format/date_format.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/api_service.dart';
import 'package:task_manager/views/task_creation_page.dart';
import 'package:task_manager/views/task_list_page.dart';

class TaskDetailsPage extends StatelessWidget {
  final int _id;
  final String _title;
  final DateTime _date;
  final Priority _priority;

  const TaskDetailsPage(this._id, this._title, this._date, this._priority);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => navigateToTaskEditing(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 5.0),
              color: Colors.grey[300],
              child: ListTile(
                title: Text(
                  _title,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle:
                    Text(formatDate(_date, [DD, ' ', dd, ' ', M, ', ', yyyy])),
              ),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Priority', style: TextStyle(fontSize: 16.0)),
                  Row(
                    children: <Widget>[
                      priorityIcon[_priority],
                      Text(
                        ' ' + EnumToString.parse(_priority),
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider()
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.transparent,
        child: RaisedButton(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 15.0),
            child: Text(
              'Delete event',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          onPressed: () => _deleteTask(context, _id),
        ),
      ),
    );
  }

  void navigateToTaskEditing(context) async {
    final bool editResult = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TaskCreationPage(
              id: _id,
              initialTitle: _title,
              initialDate: _date,
              initialPriority: _priority)),
    );

    if (editResult != null) Navigator.pop(context, editResult);
  }

  Future _deleteTask(BuildContext context, int id) async {
    var response = await ApiService.deleteTask(id);

    if (response.statusCode == 202) Navigator.pop(context, false);
  }
}

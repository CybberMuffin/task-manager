import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/main.dart';
import 'package:task_manager/models/reminder.dart';

class RemindersScreen extends StatefulWidget {
  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _reminders = [];
  List notifications;

  @override
  void initState() {
    super.initState();
    initializeReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders'),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: _reminders.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) => ListTile(
          title: Text(_reminders[index].title),
          subtitle: Text(_reminders[index].description),
          trailing: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red[300],
              ),
              onPressed: () => deleteReminder(_reminders[index].id)),
        ),
      ),
    );
  }

  void deleteReminder(int id) {
    notificationService.deleteNotification(id);
    setState(() => _reminders.removeWhere((rem) => rem.id == id));
  }

  Future initializeReminders() async {
    var notifications = await notificationService.allNotificiations();
    setState(() => notifications.forEach((notification) => _reminders.add(
        Reminder(notification.id, notification.title, notification.body))));
  }
}

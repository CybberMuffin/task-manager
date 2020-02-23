import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_manager/services/notification_service.dart';
import 'package:task_manager/views/login_screen.dart';

final NotificationService notificationService = NotificationService();

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/services/local_storage.dart';
import 'package:task_manager/views/task_list_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _sort;

  @override
  void initState() {
    super.initState();
    _applySort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: ListTile(
          title: Text('Default sorting by ' + (_sort ?? '')),
          trailing: PopupMenuButton(
            icon: Icon(Icons.sort),
            onSelected: (SortBy result) => _selectDefaultSort(result),
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
        ),
      ),
    );
  }

  void _selectDefaultSort(result) async {
    await LocalStorage.setSort(EnumToString.parse(result));
    setState(() => _sort = EnumToString.parse(result));
  }

  void _applySort() async {
    var s = await LocalStorage.getSort();
    setState(() => _sort = s);
  }
}

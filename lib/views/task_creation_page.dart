import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/api_service.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:task_manager/main.dart';

Map<Priority, Color> selectedPriorityColor = {
  Priority.Low: Colors.green[300],
  Priority.Normal: Colors.yellow[300],
  Priority.High: Colors.red[300],
};

class TaskCreationPage extends StatefulWidget {
  final int id;
  final String initialTitle;
  final DateTime initialDate;
  final Priority initialPriority;

  const TaskCreationPage(
      {Key key,
      this.id,
      this.initialTitle,
      this.initialDate,
      this.initialPriority})
      : super(key: key);

  @override
  _TaskCreationPageState createState() => _TaskCreationPageState();
}

class _TaskCreationPageState extends State<TaskCreationPage> {
  GlobalKey<FormState> _formKey = GlobalKey();
  String _title;
  bool _validate = false;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Priority _selectedPriority = Priority.Normal;

  Duration _notificationDelay = Duration(minutes: 10);
  String _description;

  bool _onEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) {
      _title = widget.initialTitle;
      _selectedDate = widget.initialDate;
      _selectedPriority = widget.initialPriority;
      _onEdit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    const defaultMargin = EdgeInsets.all(10.0);

    var appBar = AppBar(
      title: Text(_onEdit ? 'Edit Task' : 'Create Task'),
      centerTitle: true,
      actions: <Widget>[
        _onEdit
            ? IconButton(
                icon: Icon(Icons.check),
                onPressed: () => _editTask(widget.id),
              )
            : Container(),
      ],
    );

    var titleField = TextFormField(
      initialValue: _onEdit ? _title : '',
      maxLines: null,
      decoration: InputDecoration(
        labelText: 'Title',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value.trim().isEmpty ? 'Enter the title' : null,
      onChanged: (input) => _title = input,
    );

    var priorityRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildPriorityButton(priority: Priority.Low),
        _buildPriorityButton(priority: Priority.Normal),
        _buildPriorityButton(priority: Priority.High),
      ],
    );

    var prioritySection = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: defaultMargin,
            child: Text(
              'Priority',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
        priorityRow,
      ],
    );

    var timeSection = Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: defaultMargin,
            child: Text(
              'Expiration Date',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Text(
            formatDate(
                _selectedDate, [dd, '.', mm, '.', yyyy, '  ', hh, ':', nn]),
            style: TextStyle(
              color: Colors.blue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );

    var descrField = TextFormField(
      initialValue: '',
      maxLines: null,
      decoration: InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
      ),
      onChanged: (input) => _description = input,
    );

    var notificationRow = GestureDetector(
      onTap: () async => await _selectDuration(context),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Notification', style: TextStyle(fontSize: 16.0)),
            Row(
              children: <Widget>[
                Text(
                  _notificationDelay.inMinutes.toString() + ' min before',
                  style: TextStyle(fontSize: 16.0),
                ),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ],
        ),
      ),
    );

    const divider = Divider(
      thickness: 1.5,
    );

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidate: _validate,
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(15.0),
                child: titleField,
              ),
              divider,
              Container(
                child: prioritySection,
              ),
              divider,
              Container(
                child: timeSection,
              ),
              divider,
              Container(
                margin: EdgeInsets.all(10.0),
                child: descrField,
              ),
              divider,
              notificationRow,
              divider,
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.transparent,
        child: RaisedButton(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 15.0),
            child: Text(
              _onEdit ? 'Delete event' : 'CREATE',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          onPressed: () => _onEdit ? _deleteTask(widget.id) : _submitForm(),
        ),
      ),
    );
  }

  Widget _buildPriorityButton({@required Priority priority}) {
    String text = EnumToString.parse(priority);
    print(_selectedPriority);
    return RaisedButton(
      child: Text(text),
      color: _colorPriorityMatching(priority: priority),
      onPressed: () => setState(() => _selectedPriority = priority),
    );
  }

  Color _colorPriorityMatching({@required Priority priority}) {
    return _selectedPriority == priority
        ? selectedPriorityColor[priority]
        : Colors.white;
  }

  Future _selectDuration(BuildContext context) async {
    Duration resultingDuration = await showDurationPicker(
      context: context,
      initialTime: _notificationDelay,
    );

    setState(() => _notificationDelay = resultingDuration);
  }

  Future _selectDate(BuildContext context) async {
    final DateTime pickedDay = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime.now().subtract(Duration(days: 1)),
        lastDate: DateTime(2101));
    if (pickedDay != null) setState(() => _selectedDate = pickedDay);

    await _selectTime(context);
    setState(() => _selectedDate = _selectedDate.add(
        Duration(hours: _selectedTime.hour, minutes: _selectedTime.minute)));
  }

  Future _selectTime(BuildContext context) async {
    final TimeOfDay pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          );
        });

    if (pickedTime != null && pickedTime != _selectedTime)
      setState(() => _selectedTime = pickedTime);
  }

  bool _confirmData() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      return true;
    } else {
      setState(() => _validate = true);
      return false;
    }
  }

  void _submitForm() {
    if (_confirmData()) {
      _onEdit ? _editTask(widget.id) : _createTask();
    }
  }

  void _createTask() {
    Navigator.pop(
        context, Task.toJson(_title, _selectedDate, _selectedPriority));
  }

  Future _editTask(int id) async {
    var response =
        await ApiService.editTask(id, _title, _selectedDate, _selectedPriority);

    if (response.statusCode > 200 && response.statusCode < 300) {
      notificationService.deleteNotification(id);
      notificationService.sheludedNotification(
          id,
          _title,
          _description ?? EnumToString.parse(_selectedPriority) + ' priority',
          _selectedDate.subtract(_notificationDelay));
      Navigator.pop(context, true);
    }
  }

  Future _deleteTask(int id) async {
    var response = await ApiService.deleteTask(id);

    if (response.statusCode == 202) Navigator.pop(context, false);
  }
}

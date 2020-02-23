import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/services/api_service.dart';
import 'dart:convert' as convert;
import 'package:task_manager/services/local_storage.dart';
import 'package:task_manager/views/task_list_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> _formKey = GlobalKey();
  bool _registration = false;
  String _email;
  String _pass;
  Widget _message;
  bool _validate = false;
  String _deafultError = 'Validation failed';

  @override
  Widget build(BuildContext context) {
    var title = Text(
      _registration ? 'Sign up' : 'Sign in',
      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    );

    var emailField = TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
      validator: (value) => validateField(value, 'Email'),
      onChanged: (input) => _email = input,
    );

    var passField = TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
      ),
      obscureText: true,
      validator: (value) => validateField(value, 'Password'),
      onChanged: (input) => _pass = input,
    );

    var switcher = ListTile(
      contentPadding: EdgeInsets.all(0),
      leading: Text(
        'Login / Register',
        style: TextStyle(fontSize: 18),
      ),
      trailing: Switch.adaptive(
          value: _registration,
          onChanged: (_) => setState(() => _registration = !_registration)),
    );

    var submitButton = Container(
      width: double.infinity,
      child: RaisedButton(
        color: Colors.blue,
        padding: EdgeInsets.all(10.0),
        child: Text(
          _registration ? 'REGISTER' : 'LOG IN',
          style: TextStyle(fontSize: 18),
        ),
        onPressed: () => _submitForm(),
      ),
    );

    const defaultMargin = EdgeInsets.symmetric(vertical: 10);

    return Scaffold(
      body: Form(
        key: _formKey,
        autovalidate: _validate,
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: defaultMargin,
                    child: title,
                  ),
                  _message ?? Container(),
                  Container(
                    margin: defaultMargin,
                    child: emailField,
                  ),
                  Container(
                    margin: defaultMargin,
                    child: passField,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: switcher,
                  ),
                  submitButton,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String validateField(String value, String field) {
    if (value.trim().isEmpty)
      return 'Enter your $field';
    else
      return null;
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

  void _submitForm() async {
    if (_confirmData()) {
      Map<String, String> requestData = {
        'email': _email,
        'password': _pass,
      };

      var response = _registration
          ? await ApiService.registerUser(requestData)
          : await ApiService.authorizeUser(requestData);

      var jsonResponse = convert.jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          LocalStorage.setToken(jsonResponse['token']);
          setState(() => _message = Container());
          navigateToTaskList();
          break;

        case 201:
          LocalStorage.setToken(jsonResponse['token']);
          setState(
            () => _message = Text(
              'Registration successful',
              style: TextStyle(color: Colors.green),
            ),
          );
          break;

        case 403:
          setState(
            () => _message = Text(
              jsonResponse['message'] ?? _deafultError,
              style: TextStyle(color: Colors.red),
            ),
          );
          break;

        case 422:
          setState(
            () => _message = Text(
              jsonResponse['fields']['email'][0] ?? _deafultError,
              style: TextStyle(color: Colors.red),
            ),
          );
          break;

        default:
          setState(
            () => _message = Text(
              'Something went wrong',
              style: TextStyle(color: Colors.red),
            ),
          );
          break;
      }
    }
  }

  void navigateToTaskList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskListPage()),
    );
  }
}

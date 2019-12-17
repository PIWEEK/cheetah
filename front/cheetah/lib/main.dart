import 'package:cheetah/create.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Cheetah',
        home: MyHomePage()
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _talks = [
    {'title': '111'},
    {'title': '222'},
    {'title': '333'},
    {'title': '444'},
    {'title': '555'},
    {'title': '666'},
    {'title': '777'},
    {'title': '888'},
    {'title': '999'},
    {'title': '111'},
    {'title': '222'},
    {'title': '333'},
    {'title': '444'},
    {'title': '555'},
    {'title': '666'},
    {'title': '777'},
    {'title': '888'},
    {'title': '999'},
  ];

  @override
  // void didChangeDependencies() async {
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: <Widget>[      // Add 3 lines from here...
          IconButton(icon: Icon(Icons.add), onPressed: _create),
        ],
      ),
      body: _buildChats(),
    );
  }

  Widget _buildChats() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;

          if (index < _talks.length) {
            return _buildRow(_talks[index]);
          }
        });
  }

  Widget _buildRow(talk) {
    return ListTile(
      title: Text(
          talk['title']
      ),
      onTap: _detail,
    );
  }

  Future<bool> requestContactsPermission() async {
    var permissionHandler = await PermissionHandler();

    var result = await permissionHandler.requestPermissions([PermissionGroup.contacts]);
    if (result[PermissionGroup.contacts] == PermissionStatus.granted) {
      return true;
    }

    return false;
  }

  void _checkPermissions() async {
    var contactsPermission = await requestContactsPermission();
    print('contactsPermission: $contactsPermission');
  }

  void _create() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Crear plan'),
            ),
            body: Center(
              child: CreateForm(),
            ),
          );
        },
      ),
    );
  }

  void _detail() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Detalle'),
            ),
            body: Center(
              child: Text('Detalle'),
            ),
          );
        },
      ),
    );
  }
}

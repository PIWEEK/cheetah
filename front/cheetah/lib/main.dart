import 'dart:convert';

import 'package:cheetah/create.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class Plan {
  final int id;
  final String name;
  final String description;

  Plan({this.id, this.name, this.description});

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

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
  Future<List<Plan>> plans;

  @override
  // void didChangeDependencies() async {
  void initState() {
    super.initState();
    _checkPermissions();
    plans = fetchPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: <Widget>[      // Add 3 lines from here...
          // IconButton(icon: Icon(Icons.add), onPressed: _create),
        ],
      ),
      body: FutureBuilder<List<Plan>>(
          future: plans,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildChats(snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return CircularProgressIndicator();
          }
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.add),
        onPressed: _create
      ),
    );
  }

  Widget _buildChats(List<Plan> plans) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;

          if (index < plans.length) {
            return _buildRow(plans[index]);
          }
        });
  }

  Widget _buildRow(Plan plan) {
    return ListTile(
      title: Text(
          plan.name
      ),
      onTap: _detail,
    );
  }

  Future<List<Plan>> fetchPlans() async {
    final response = await http.get('http://10.8.1.138:3000/mock/plans');

    if (response.statusCode == 200) {
      List<dynamic> plans = jsonDecode(response.body)['data']['result'];

      return plans.map((plan) => Plan.fromJson(plan)).toList();
    } else {
      throw Exception('Failed to load plans');
    }
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
    await requestContactsPermission();
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

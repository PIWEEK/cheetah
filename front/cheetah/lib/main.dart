import 'dart:convert';

import 'package:cheetah/create.dart';
import 'package:cheetah/plans.dart';
import 'package:cheetah/detail.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import './appconfig.dart';

void main() => runApp(MyApp());

class Plan {
  final int id;
  final String name;
  final String description;
  final int parentId;

  Plan({this.id, this.name, this.description, this.parentId});

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: int.parse(json['id']),
      name: json['name'],
      parentId: json['plan_id'],
      description: json['description'],
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cheetah',
        home: MyHomePage(),
        theme: ThemeData(
          primaryColor: Colors.deepOrange,
          accentColor: Colors.deepOrangeAccent
        )
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
    registerUser();
  }

  Future<Null> refreshList() async {
    setState(() {
      plans = fetchPlans();
    });

    await new Future.delayed(new Duration(seconds: 1));

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text('Chats'),
        actions: <Widget>[      // Add 3 lines from here...
          // IconButton(icon: Icon(Icons.add), onPressed: _create),
          FlatButton(
            textColor: Colors.white,
            child: Text(
              "Mis planes",
            ),
            onPressed: _myPlans,
          )
        ],
      ),
      body: FutureBuilder<List<Plan>>(
          future: fetchPlans(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildChats(snapshot.data);
            } else if (snapshot.hasError) {
              return Text("error");
            }
            return Center(
              child: CircularProgressIndicator()
            );
          }
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        child: new Icon(Icons.add),
        onPressed: _create
      ),
    );
  }

  Widget _buildChats(List<Plan> plansList) {
    return RefreshIndicator(
      child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, i) {
            final index = i;

            if (index < plansList.length) {
              return _buildRow(plansList[index]);
            }
          }),
      onRefresh: refreshList
    );
  }

  Widget _buildRow(Plan plan) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(5.0),
          child: ListTile(
          title: Text(
          plan.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16.0,
          )
          ),
          subtitle: Text(
              plan.description,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16.0,
                height: 2,
              )
          ),
          onTap: () {
            _detail(plan.id);
          },
        )
      )
    );
  }

  void registerUser() {
    String body = jsonEncode({
      'name': appData.name,
      'phone': appData.phone
    });

    http.post('http://10.8.1.138:3000/api/persons', body: body, headers: {'Content-Type': 'application/json'});
  }

  Future<List<Plan>> fetchPlans() async {
    final response = await http.get('http://10.8.1.138:3000/api/user-plans/${appData.phone}');

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

  void _create() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Crear plan'),
              backgroundColor: Colors.deepOrange,
            ),
            body: Center(
              child: CreateForm(),
            ),
          );
        },
      ),
    );

    setState(() {
      plans = fetchPlans();
    });
  }

  void _detail(int planId) {
    print('IR a plan');
    print(planId);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return PlanDetail(id: planId);
        },
      ),
    );
  }

  void _myPlans() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return MyPlans();
        },
      ),
    );
  }
}

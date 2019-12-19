import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './appconfig.dart';

class Plan {
  final String id;
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

class MyPlans extends StatefulWidget {
  @override
  MyPlansState createState() {
    return MyPlansState();
  }
}

class MyPlansState extends State<MyPlans> {
  Future<List<Plan>> plans;

  @override
  void initState() {
    super.initState();
    plans = fetchPlans();
  }

  Future<List<Plan>> fetchPlans() async {
    final response = await http.get('http://10.8.1.166:3000/api/plans/user/${appData.phone}');
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> plans = jsonDecode(response.body)['data']['result'];

      return plans.map((plan) => Plan.fromJson(plan)).toList();
    } else {
      throw Exception('Failed to load plans');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis planes'),
        backgroundColor: Colors.deepOrange,
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
        },
      ),
    );
  }

  Widget _buildChats(List<Plan> plans) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          final index = i ~/ 2;

          if (index < plans.length) {
            return _buildRow(plans[index]);
          }
        });
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
          )
      )
    );
  }

}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlanExtended {
  final int id;
  final String name;
  final String description;

  PlanExtended({this.id, this.name, this.description});

  factory PlanExtended.fromJson(Map<String, dynamic> json) {
    return PlanExtended(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class PlanDetail extends StatefulWidget {
  @override
  PlanDetailState createState() {
    return PlanDetailState();
  }
}

class PlanDetailState extends State<PlanDetail> {
  Future<PlanExtended> plan;

  @override
  void initState() {
    super.initState();
    plan = fetchPlans();
  }

  Future<PlanExtended> fetchPlans() async {
    var id = '2';

    final response = await http.get('http://10.8.1.138:3000/mock/plan/$id');

    if (response.statusCode == 200) {
      return PlanExtended.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to load plans');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan')
      ),
      body: Center(
          child: Container(
            child: FutureBuilder<PlanExtended>(
              future: plan,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text("${snapshot.data.name}");
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                return CircularProgressIndicator();
              },
            ),
          )
      ),
    );
  }
}
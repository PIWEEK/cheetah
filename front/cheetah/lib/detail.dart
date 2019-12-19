import 'dart:convert';

import 'package:cheetah/answer.dart';
import 'package:cheetah/newPlan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './appconfig.dart';

class PlanExtended {
  final int id;
  final String name;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final List<Answer> answers;

  PlanExtended({this.id, this.name, this.description, this.date, this.time, this.answers});

  factory PlanExtended.fromJson(Map<String, dynamic> json) {
    var time = json['time'].split(':');
    List<dynamic> answers = json['answers'];

    return PlanExtended(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      time: TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1])),
      answers: answers.map((anwer) => Answer.fromJson(anwer)).toList()
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
    // print(appData.phone);

    var id = '2';

    final response = await http.get('http://10.8.1.138:3000/mock/plan/$id');

    if (response.statusCode == 200) {
      return PlanExtended.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to load plans');
    }
  }

  Widget _buildRow(Answer answer) {
    return AnswerWidget(
        answer: answer
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: FutureBuilder<PlanExtended>(
          future: plan,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int lastIndex = snapshot.data.answers.length;

              return ListView.builder(
                itemBuilder: (context, index) {
                  if (index == lastIndex) {
                    return NewPlanWidget();
                  } else {
                    return _buildRow(snapshot.data.answers[index]);
                  }
                },
                itemCount: snapshot.data.answers.length + 1,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return CircularProgressIndicator();
          },
        )
      ),
    );
  }
}
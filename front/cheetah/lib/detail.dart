import 'dart:convert';

import 'package:cheetah/answer.dart';
import 'package:cheetah/newPlan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './appconfig.dart';

class PlanDetail extends StatefulWidget {
  final int id;

  PlanDetail({this.id});

  @override
  PlanDetailState createState() {
    return PlanDetailState(id: id);
  }
}

class PlanDetailState extends State<PlanDetail> {
  Future<PlanExtended> plan;
  PlanExtended _plan;
  final int id;

  PlanDetailState({this.id});

  @override
  void initState() {
    super.initState();
    plan = fetchPlans();
  }

  Future<PlanExtended> fetchPlans() async {
    final response = await http.get('http://10.8.1.138:3000/api/plans/$id');

    if (response.statusCode == 200) {
      setState(() {});
      _plan = PlanExtended.fromJson(jsonDecode(response.body)['data']['result']);

      return _plan;
    } else {
      throw Exception('Failed to load plans');
    }
  }

  Widget _buildRow(Answer answer) {
    return AnswerWidget(
      plan: _plan,
      answer: answer
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_plan == null ? 'Plan' : _plan.name),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: FutureBuilder<PlanExtended>(
          future: plan,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Answer> userAnsers = snapshot.data.answers.where((Answer answer) {
                print(answer.phone);
                return answer.phone == appData.phone;
              }).toList();

              int lastIndex = userAnsers.length;
              print(lastIndex);
              return ListView.builder(
                itemBuilder: (context, index) {
                  if (index == lastIndex) {
                    return NewPlanWidget(plan_id: _plan.id);
                  } else {
                    return _buildRow(userAnsers[index]);
                  }
                },
                itemCount: userAnsers.length + 1,
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
import 'dart:convert';

import 'package:cheetah/answer.dart';
import 'package:cheetah/newPlan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './appconfig.dart';

class PlanDetail extends StatefulWidget {
  @override
  PlanDetailState createState() {
    return PlanDetailState();
  }
}

class PlanDetailState extends State<PlanDetail> {
  Future<PlanExtended> plan;
  PlanExtended _plan;

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
      setState(() {});
      _plan = PlanExtended.fromJson(jsonDecode(response.body)['data']);

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
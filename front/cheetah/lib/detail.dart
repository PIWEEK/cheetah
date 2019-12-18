import 'dart:convert';

import 'package:cheetah/answer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/*

      name: 'plan 1',
      descripcion: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus dignissim mattis purus, et aliquet enim vestibulum in. Praesent quis dui interdum, feugiat nisi posuere, porttitor risus. Phasellus sit amet enim egestas, dapibus nulla eu, finibus ipsum. In sit amet augue neque. Maecenas tincidunt a arcu eu dapibus. Quisque gravida tortor at rutrum finibus. Nullam ac molestie ante. Ut ac congue erat. Sed nisi purus, gravida a nisl et, euismod vestibulum metus. Pellentesque commodo porta viverra. Maecenas venenatis congue lacus, in viverra lorem tincidunt eget.',
      date: new Date().toUTCString(),
      time: '12:00',

           plan_id: 4,
          anwer: null,
          date: '2019-12-18 23:00:00.000Z',
          time: '22:45'
 */

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
        title: Text('Plan')
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: FutureBuilder<PlanExtended>(
          future: plan,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemBuilder: (context, index) => _buildRow(snapshot.data.answers[index]),
                itemCount: snapshot.data.answers.length,
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
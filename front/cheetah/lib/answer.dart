import 'dart:convert';

import 'package:cheetah/appconfig.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Answer {
  final int plan_id;
  final DateTime date;
  final TimeOfDay time;
  final String phone;
  final bool answer;

  Answer({this.plan_id, this.date, this.time, this.answer, this.phone});

  factory Answer.fromJson(Map<String, dynamic> json) {
    print(json);
    var time = json['time'].split(':');

    print('creando');
    print(json['answer']);

    return Answer(
        plan_id: json['plan_id'],
        date: DateTime.parse(json['date']),
        time: TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1])),
        answer: json['answer'],
        phone: json['person_phone'],
    );
  }
}

class PlanExtended {
  final int id;
  final String name;
  final String description;
  final String author;
  final DateTime date;
  final TimeOfDay time;
  final String authorPhone;
  final List<Answer> answers;

  PlanExtended({this.id, this.name, this.description, this.date, this.time, this.answers, this.author, this.authorPhone});

  factory PlanExtended.fromJson(Map<String, dynamic> json) {
    print(json);
    var time = json['time'].split(':');
    List<dynamic> answers = json['answers'];

    answers = answers.map((anwer) => Answer.fromJson(anwer)).toList();

    return PlanExtended(
        id: int.parse(json['id']),
        name: json['name'],
        description: json['description'],
        author: json['owner_name'],
        authorPhone: json['owner_phone'],
        date: DateTime.parse(json['date']),
        time: TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1])),
        answers: answers
    );
  }
}

class AnswerWidget extends StatefulWidget {
  final Answer answer;
  final PlanExtended plan;

  AnswerWidget({this.answer, this.plan});

  @override
  AnswerState createState() {
    return AnswerState(plan: this.plan, answer: this.answer, currentAnswer: this.answer.answer);
  }
}

class AnswerState extends State<AnswerWidget> {
  Answer answer;
  bool currentAnswer;
  PlanExtended plan;

  AnswerState({this.plan, this.answer, this.currentAnswer});

  answerPlan(bool value) {
    if (currentAnswer != value) {
      setState(() {
        currentAnswer = value;
      });
    }

    var map = new Map<String, dynamic>();
    map["id"] = answer.plan_id;
    map["value"] = value;

    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Envíando respuesta')));

    http.post('http://10.8.1.138:3000/mock/answer', body: json.encode(map)).then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error saving data");
      }
    });
  }

  Widget _question() {
    print('00000');
    print(answer.answer);
    if (plan.id != answer.plan_id || appData.phone == plan.authorPhone) {
      return RichText(
        softWrap: true,
        text: TextSpan(
          text: '¿Qué tal quedar el ',
          style: TextStyle(color: Colors.blueGrey, fontSize: 16.0, fontWeight: FontWeight.w700),
          children: <TextSpan>[
            TextSpan(text: '${answer.date.day}/${answer.date.month}/${answer.date.year}', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' a las '),
            TextSpan(text: '${answer.time.hour}:${answer.time.minute}', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: '?'),
          ],
        ),
      );
    }

    return RichText(
      softWrap: true,
      text: TextSpan(
        text: '',
        style: TextStyle(color: Colors.blueGrey, fontSize: 16.0, fontWeight: FontWeight.w700),
        children: <TextSpan>[
          TextSpan(text: plan.author, style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' ha propuesto un plan con la siguiente descripción:'),
          const TextSpan(
            text: '\n',
          ),
          const TextSpan(
            text: '\n',
          ),
          TextSpan(text: plan.description),
          const TextSpan(
            text: '\n',
          ),
          const TextSpan(
            text: '\n',
          ),
          TextSpan(text: '¿Qué tal quedar el '),
          TextSpan(text: '${answer.date.day}/${answer.date.month}/${answer.date.year}', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' a las '),
          TextSpan(text: '${answer.time.hour}:${answer.time.minute}', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: '?'),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
     padding: EdgeInsets.all(10.0),
     child: Column(
       children: [
         Row(
           children: <Widget>[
             CircleAvatar(
               backgroundColor: Colors.white,
               radius: 35.5,
               backgroundImage: AssetImage('assets/images/ic_launcher.png'),
             ),
             SizedBox(width: 10.0),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[
                 Text(
                   'Cheetah',
                   style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold),
                 ),
                 SizedBox(height: 5.0),
                 Container(
                   width: MediaQuery.of(context).size.width * 0.70,
                   child: _question()
                 )
               ],
             )
           ],
         ),
         SizedBox(height: 5.0),
          Row(
           children: <Widget>[
             Expanded(
               child: FlatButton(
                 color: currentAnswer != null && currentAnswer ? Colors.deepOrangeAccent : Colors.grey,
                 textColor: Colors.white,
                 padding: EdgeInsets.all(3.0),
                 splashColor: Colors.deepOrange,
                 onPressed: () {
                   answerPlan(true);
                 },
                 child: Text(
                   "Sí",
                   style: TextStyle(fontSize: 14.0),
                 )
               ),
             ),
             SizedBox(width: 10.0),
            Expanded(
              child: FlatButton(
                 color: currentAnswer != null && !currentAnswer ? Colors.deepOrangeAccent : Colors.grey,
                 textColor: Colors.white,
                 padding: EdgeInsets.all(3.0),
                 splashColor: Colors.deepOrange,
                 onPressed: () {
                   answerPlan(false);
                 },
                 child: Text(
                   "No",
                   style: TextStyle(fontSize: 14.0),
                 )
             )
            )
           ],
         ),
       ]
     )
    );
  }
}
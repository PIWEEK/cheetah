import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Answer {
  final int id;
  final DateTime date;
  final TimeOfDay time;
  final List<Answer> anwers;

  Answer({this.id, this.date, this.time, this.anwers});

  factory Answer.fromJson(Map<String, dynamic> json) {
    var time = json['time'].split(':');

    return Answer(
        id: json['id'],
        date: DateTime.parse(json['date']),
        time: TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1]))
    );
  }
}

class AnswerWidget extends StatefulWidget {
  final Answer answer;

  AnswerWidget({this.answer});

  @override
  AnswerState createState() {
    return AnswerState(answer: this.answer);
  }
}

class AnswerState extends State<AnswerWidget> {
  Answer answer;

  AnswerState({this.answer});

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
               radius: 35.5,
               backgroundImage: AssetImage('assets/images/avatar.png'),
             ),
             SizedBox(width: 10.0),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[
                 Text(
                   'Cheetah',
                   style: TextStyle(color: Colors.grey, fontSize: 15.0, fontWeight: FontWeight.bold),
                 ),
                 SizedBox(height: 5.0),
                 Text(
                   '¿Qué tal te viene quedar a las 3:00?',
                   style: TextStyle(color: Colors.blueGrey, fontSize: 15.0, fontWeight: FontWeight.w600),
                 ),
               ],
             )
           ],
         ),
         Row(
           children: <Widget>[
             FlatButton(
               color: Colors.blue,
               textColor: Colors.white,
               padding: EdgeInsets.all(3.0),
               splashColor: Colors.blueAccent,
               onPressed: () {
                 /*...*/
               },
               child: Text(
                 "Sí",
                 style: TextStyle(fontSize: 14.0),
               )
             ),
             SizedBox(width: 10.0),
             FlatButton(
                 color: Colors.blue,
                 textColor: Colors.white,
                 padding: EdgeInsets.all(3.0),
                 splashColor: Colors.blueAccent,
                 onPressed: () {
                   /*...*/
                 },
                 child: Text(
                   "No",
                   style: TextStyle(fontSize: 14.0),
                 )
             )
           ],
         )
       ]
     )
    );
  }
}
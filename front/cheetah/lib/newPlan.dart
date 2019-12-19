import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class newPlan {
  final int plan_id;
  final DateTime date;
  final TimeOfDay time;
  final bool answer;

  newPlan({this.plan_id, this.date, this.time, this.answer});

  factory newPlan.fromJson(Map<String, dynamic> json) {
    var time = json['time'].split(':');

    return newPlan(
        plan_id: json['plan_id'],
        date: DateTime.parse(json['date']),
        time: TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1])),
        answer: json['answer']
    );
  }
}

class NewPlanWidget extends StatefulWidget {
  NewPlanWidget();

  @override
  NewPlanState createState() {
    return NewPlanState();
  }
}

class _EventData {
  DateTime date = null;
  TimeOfDay time = null;
}

class NewPlanState extends State<NewPlanWidget> {
  _EventData _data = new _EventData();
  bool currentAnswer;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    _data.date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    setState(() {});
  }

  Future<void> _selectTime(BuildContext context) async {
    _data.time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now()
    );

    setState(() {});
  }

  _save() {

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
                        style: TextStyle(color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.70,
                        child: RichText(
                          softWrap: true,
                          text: TextSpan(
                            text: '¿Quieres hacer una contrapropuesta?',
                            style: TextStyle(color: Colors.blueGrey, fontSize: 15.0, fontWeight: FontWeight.w600)
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
              if (currentAnswer == null)
              Row(
                children: <Widget>[
                  FlatButton(
                      color: Colors.deepOrangeAccent,
                      textColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                      splashColor: Colors.deepOrange,
                      onPressed: () {
                        setState(() {
                          currentAnswer = true;
                        });
                      },
                      child: Text(
                        "Añadir contrapropuesta",
                        style: TextStyle(fontSize: 14.0),
                      )
                  )
                ],
              ),
              if (currentAnswer != null && currentAnswer == true)
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      Text('¿Cuando te gustaria quedar?'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FlatButton(
                                  color: Colors.deepOrange,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    _selectDate(context);
                                  },
                                  child: Text('Seleccionar fecha',)
                              ),
                            ]
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FlatButton(
                                  color: Colors.deepOrange,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    _selectTime(context);
                                  },
                                  child: Text('Seleccionar hora',)
                              ),
                            ]
                        ),
                      ),
                      if (_data.time != null && _data.date != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                FlatButton(
                                    color: Colors.deepOrange,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      _save();
                                    },
                                    child: Text('Guardar',)
                                ),
                              ]
                          ),
                        ),
                    ]
                ),
            ]
        )
    );
  }
}
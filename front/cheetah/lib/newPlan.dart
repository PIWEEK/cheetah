import 'dart:convert';

import 'package:cheetah/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './appconfig.dart';

class NewPlanWidget extends StatefulWidget {
  final int plan_id;

  NewPlanWidget({this.plan_id});

  @override
  NewPlanState createState() {
    return NewPlanState(plan_id: plan_id);
  }
}

class _EventData {
  DateTime date = null;
  TimeOfDay time = null;
}

class NewPlanState extends State<NewPlanWidget> {
  final int plan_id;
  bool showAddNewPlan = true;

  _EventData _data = new _EventData();
  bool currentAnswer;

  NewPlanState({this.plan_id});

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
    String map = jsonEncode({
      'date': '${_data.date.year}-${_data.date.month}-${_data.date.day + 1}',
      'time': '${_data.time.hour}:${_data.time.minute}',
      'owner_phone': appData.phone,
      'parent_id': plan_id
    });

    http.post('http://10.8.1.138:3000/api/plans', body: map, headers: {'Content-Type': 'application/json'}).then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error saving data");
      }
    });

    print('sdfdsf');

    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Envíando contrapropuesta')));

    setState(() {
      showAddNewPlan = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String _date = '';

    if (_data.date != null) {
      _date = '${_data.date.year} - ${_data.date.month} - ${_data.date.day}';
    }

    String _time = '';

    if (_data.time != null) {
      _time = formatTimeOfDay(_data.time);
    }

    if (showAddNewPlan) {
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
                          style: TextStyle(color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5.0),
                        Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.70,
                          child: RichText(
                            softWrap: true,
                            text: TextSpan(
                                text: '¿Quieres hacer una contrapropuesta?',
                                style: TextStyle(color: Colors.blueGrey,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600)
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
                                Text(
                                  " ${_date}",
                                  style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
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
                                Text(
                                  " ${_time}",
                                  style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ),
                              ]
                          ),
                        ),
                        if (_data.time != null && _data.date != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: <Widget>[
                                  RaisedButton(
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

    return SizedBox(height: 0);
  }
}
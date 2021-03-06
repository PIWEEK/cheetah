import 'dart:convert';

import 'package:cheetah/contacts.dart';
import 'package:cheetah/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import './appconfig.dart';

// https://medium.com/flutterpub/sample-form-part-1-flutter-35664d57b0e5

class CreateForm extends StatefulWidget {
  @override
  CreateFormState createState() {
    return CreateFormState();
  }
}

class _EventData {
  String name = '';
  String description = '';
  DateTime date = null;
  TimeOfDay time = null;
  int min_attendees = 0;
  List<String> phones = [];
}

class CreateFormState extends State<CreateForm > {
  final _formKey = GlobalKey<FormState>();

  _EventData _data = new _EventData();
  String _time = '';
  String _date = '';
  bool requestInProgress = false;

  final DateTime selectedDate = null;
  final TimeOfDay selectedTime = null;

  Future createPost({String body}) async {
    return http.post('http://10.8.1.138:3000/api/plans', body: body, headers: {'Content-Type': 'application/json'}).then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error saving data");
      }

      return jsonDecode(response.body);
    });
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

  void getContacts() async {
    _data.phones = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Contacts()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_data.date != null) {
      _date = '${_data.date.year} - ${_data.date.month} - ${_data.date.day}';
    }

    if (_data.time != null) {
      _time = formatTimeOfDay(_data.time);
    }

    return Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Obligatorio';
                    }
                    return null;
                  },
                  onSaved: (String value) {
                    setState(() {
                      _data.name = value;
                    });
                  }
              ),
              TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Descripción *',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Obligatorio';
                    }
                    return null;
                  },
                  onSaved: (String value) {
                    setState(() {
                      _data.description = value;
                    });
                  }
              ),
              new TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Número mínimo de asistentes',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                  onSaved: (String value) {
                    setState(() {
                      _data.min_attendees = int.parse(value);
                    });
                  }
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: <Widget>[
                   Expanded(
                     child: FlatButton(
                         shape: RoundedRectangleBorder(side: BorderSide(color: Colors.deepOrange), borderRadius: new BorderRadius.circular(3.0)),
                         color: Colors.white,
                         textColor: Colors.deepOrange,
                         onPressed: () {
                           _selectDate(context);
                         },
                         child: Text('Seleccionar fecha',)
                     ),
                   ),
                   Expanded(
                     child: Align(
                       alignment: Alignment.centerRight,
                       child: Text(
                         " ${_date}",
                         style: TextStyle(
                             color: Colors.deepOrange,
                             fontWeight: FontWeight.bold,
                             fontSize: 18.0),
                       ),
                     ),
                   ),
                 ]
             ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                            shape: RoundedRectangleBorder(side: BorderSide(color: Colors.deepOrange), borderRadius: new BorderRadius.circular(3.0)),
                            color: Colors.white,
                            textColor: Colors.deepOrange,
                            onPressed: () {
                              _selectTime(context);
                            },
                            child: Text('Seleccionar hora',)
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            " ${_time}",
                            style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0),
                          ),
                        ),
                      ),
                    ]
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                          shape: RoundedRectangleBorder(side: BorderSide(color: Colors.deepOrange), borderRadius: new BorderRadius.circular(3.0)),
                          color: Colors.white,
                          textColor: Colors.deepOrange,
                          onPressed: () {
                            getContacts();
                          },
                          child: Text('Invitados: ${_data.phones.length}',)
                      ),
                    ),
                    SizedBox(
                      width: 186.0
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Colors.deepOrange,
                        textColor: Colors.white,
                        onPressed: () async {
                          if (_formKey.currentState.validate() && !requestInProgress) {
                            requestInProgress = true;
                            _formKey.currentState.save();

                            print(_data.phones.map((phone) {
                              return {
                                'required': false,
                                'phone': phone
                              };
                            }));

                            if (appData.phone == "600000001") {
                              _data.phones = ['600000002', '600000003'];
                            } else if (appData.phone == "600000002") {
                              _data.phones = ['600000001', '600000003'];
                            } else {
                              _data.phones = ['600000001', '600000002'];
                            }

                            String map = jsonEncode({
                              'name': _data.name,
                              'description': _data.description,
                              'date': '${_data.date.year}-${_data.date.month}-${_data.date.day}',
                              'time': '${_data.time.hour}:${_data.time.minute}',
                              'min_people': _data.min_attendees,
                              'people': _data.phones.map((phone) {
                                return {
                                  'required': false,
                                  'phone': phone
                                };
                              }).toList(),
                              'owner_phone': appData.phone
                            });

                            Scaffold.of(context)
                                .showSnackBar(SnackBar(content: Text('Envíando datos')));

                            await createPost(body: map);
                            requestInProgress = false;
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Enviar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}

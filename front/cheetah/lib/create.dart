import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

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
}

/*

Future<Post> createPost(String url, {Map body}) async {
  return http.post(url, body: body).then((http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    return Post.fromJson(json.decode(response.body));
  });
}
 */

class CreateFormState extends State<CreateForm > {
  final _formKey = GlobalKey<FormState>();

  _EventData _data = new _EventData();
  String _time = '';
  String _date = '';

  final DateTime selectedDate = null;
  final TimeOfDay selectedTime = null;

  Future createPost({Map body}) async {
    print('Empieza: ${body['title']}');

    return http.post('http://10.8.1.138:3000/mock/create', body: body).then((http.Response response) {
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

  @override
  Widget build(BuildContext context) {
    if (_data.date != null) {
      _date = '${_data.date.year} - ${_data.date.month} - ${_data.date.day}';
    }

    if (_data.time != null) {
      _time = '${_data.time.hour} : ${_data.time.minute}';
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
              Text(
                " ${_date}",
                style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0),
              ),
              FlatButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  child: Text('Seleccionar fecha',)
              ),
              Text(
                " ${_time}",
                style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0),
              ),
              FlatButton(
                  onPressed: () {
                    _selectTime(context);
                  },
                  child: Text('Seleccionar hora',)
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();

                      var map = new Map<String, dynamic>();
                      map["name"] = _data.name;
                      map["description"] = _data.description;
                      map["date"] = _data.date.toUtc().toString();
                      map["time"] = '${_data.time.hour}:${_data.time.minute}';
                      map["min_attendees"] = _data.min_attendees.toString();

                      Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text('Envíando datos')));

                      var p = await createPost(body: map);
                      print('Respuesta: ${p['data']['name']}');
                    }
                  },
                  child: Text('Enviar'),
                ),
              ),
            ],
          ),
        )
    );
  }
}

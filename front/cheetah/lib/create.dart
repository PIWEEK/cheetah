import 'dart:convert';

import 'package:flutter/material.dart';
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
  String title = '';
  String description = '';
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

  // https://flutter.dev/docs/cookbook/networking/fetch-data
  // Future<http.Response> fetchPost() {
  //  return http.get('https://jsonplaceholder.typicode.com/posts/1');
  //}

  Future createPost({Map body}) async {
    print('Empieza: ${body['title']}');

    return http.post('http://10.8.1.138:3000/mock/create', body: body).then((http.Response response) {
      print('1');
      final int statusCode = response.statusCode;
      print('2');
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      print('3');
      return jsonDecode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
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
                      _data.title = value;
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();

                      print('Titulo: ${_data.title}');
                      print('Descripción: ${_data.description}');

                      var map = new Map<String, dynamic>();
                      map["title"] = _data.title;

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

import 'package:flutter/material.dart';
import 'package:http/http.dart';
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
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();

                      print('Titulo: ${_data.title}');
                      print('Descripción: ${_data.description}');

                      Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text('Envíando datos')));
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

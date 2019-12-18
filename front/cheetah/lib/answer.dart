import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Answer extends StatefulWidget {
  @override
  AnswerState createState() {
    return AnswerState();
  }
}

class AnswerState extends State<Answer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('111'),
        Text('222'),
      ],
    );
  }
}
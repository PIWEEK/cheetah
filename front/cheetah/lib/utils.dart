import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatTimeOfDay(TimeOfDay tod) {
  final now = new DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
  final format = DateFormat.Hm();
  return format.format(dt);
}
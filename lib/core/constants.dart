import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//global constants
const List<String> days = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday",
];

// router path names
abstract class AppRoutes {
  static const String home = '/home-page';
  static const String createRoutinePage = '/create-routine-page';
}

// global helper functions
TimeOfDay stringToTimeOfDay(String tod) {
  final format = DateFormat.jm();
  return TimeOfDay.fromDateTime(format.parse(tod));
}

String timeOfDayToString(TimeOfDay tod) {
  final DateTime now = DateTime.now();
  final DateTime dateTime =
      DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
  return DateFormat.jm().format(dateTime);
}

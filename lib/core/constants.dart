import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubit/category_cubit/category_cubit.dart';

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
  static const String categoryListPage = '/category-list-page';
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

void displaySnackBar(BuildContext context, {required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<dynamic> addNewCategoryDialog(BuildContext context,
    {required TextEditingController controller}) {
  final CategoryCubit categoryCubit = context.read<CategoryCubit>();
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add new Category'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Enter category name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              categoryCubit.addCategory(controller.text);
              Navigator.pop(context);
            }
          },
          child: const Text(
            'Save',
          ),
        ),
      ],
    ),
  );
}

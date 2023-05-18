import 'package:flutter/material.dart';

import '../collections/category.dart';
import '../collections/routine.dart';
import '../core/constants.dart';
import '../database/database.dart';

class CreateRoutinePage extends StatefulWidget {
  const CreateRoutinePage({super.key, this.routine});

  final Routine? routine;

  static Route route({Routine? routine}) => MaterialPageRoute<void>(
      builder: (_) => CreateRoutinePage(
            routine: routine,
          ));

  @override
  State<CreateRoutinePage> createState() => _CreateRoutinePageState();
}

class _CreateRoutinePageState extends State<CreateRoutinePage> {
  late List<Category> categories = [];
  late Category dropdownCategory = Category.empty;

  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedDay = days[0];

  late final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _timeController = TextEditingController();
  late final TextEditingController _newCategoryController =
      TextEditingController();

  late final Database db = Database();

  @override
  void initState() {
    super.initState();
    if (!isRoutineNull()) {
      _titleController.text = widget.routine!.title;
      _timeController.text = widget.routine!.startTime;
      selectedDay = widget.routine!.day;
      selectedTime = stringToTimeOfDay(widget.routine!.startTime);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _readCategories());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  bool isRoutineNull() => widget.routine == null;

  // String _getFormattedTime() {
  //   return "${selectedTime.hour}:${selectedTime.minute} ${selectedTime.period.name}";
  // }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );

    if (timeOfDay != null && timeOfDay != selectedTime) {
      selectedTime = timeOfDay;
      _timeController.text = timeOfDayToString(selectedTime);
    }
  }

  void _readCategories() async {
    List<Category> newCategories = await db.getCategories();
    setState(() {
      categories = newCategories;
      if (categories.isNotEmpty) {
        if (isRoutineNull()) {
          dropdownCategory = categories.first;
        } else {
          dropdownCategory = widget.routine!.category.value!;
        }
      }
    });
  }

  String _getAppBarTitle() {
    if (isRoutineNull()) return 'Add Routine';
    return 'Update Routine';
  }

  String _getSubmitButtonTitle() {
    if (isRoutineNull()) return 'Add';
    return 'Update';
  }

  List<Widget>? _createAppBarActions() {
    if (isRoutineNull()) return null;
    return [
      IconButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content:
                const Text('Are you sure you want to delete this routine?'),
            actions: [
              TextButton(
                onPressed: () => db
                    .deleteRoutine(widget.routine!.id)
                    .then((_) => Navigator.of(context).pop(true)),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ).then((value) {
          if (value) {
            Navigator.pop(context);
          }
        }),
        icon: const Icon(
          Icons.delete,
          color: Colors.red,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: _createAppBarActions(),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 32,
        ),
        children: [
          const _Heading(text: 'Category'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Category>(
                  value: dropdownCategory,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    dropdownCategory = value ?? dropdownCategory;
                  }),
                ),
              ),
              IconButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add new Category'),
                    content: TextField(
                      controller: _newCategoryController,
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
                          if (_newCategoryController.text.isNotEmpty) {
                            db
                                .addCategory(
                              categoryName: _newCategoryController.text,
                            )
                                .then((_) {
                              _newCategoryController.clear();
                              _readCategories();
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'Save',
                        ),
                      ),
                    ],
                  ),
                ).then((_) {
                  _newCategoryController.clear();
                }),
                icon: const Icon(Icons.add_circle_outline_outlined),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _Heading(text: 'Title'),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Routine title',
            ),
          ),
          const SizedBox(height: 16),
          const _Heading(text: 'Start Time'),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    hintText: 'time',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _selectTime(context),
                child: const Icon(Icons.calendar_month),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _Heading(text: 'Select day'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedDay,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: days
                .map(
                  (day) => DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() {
              selectedDay = value ?? selectedDay;
            }),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (_titleController.text.isEmpty ||
                    _timeController.text.isEmpty ||
                    dropdownCategory.isEmpty) return;
                if (isRoutineNull()) {
                  db
                      .addRoutine(
                        Routine()
                          ..title = _titleController.text
                          ..startTime = _timeController.text
                          ..day = selectedDay
                          ..category.value = dropdownCategory,
                      )
                      .then((_) => Navigator.pop(context));
                } else {
                  db
                      .updateRoutine(
                        Routine()
                          ..id = widget.routine!.id
                          ..title = _titleController.text
                          ..startTime = _timeController.text
                          ..day = selectedDay
                          ..category.value = dropdownCategory,
                      )
                      .then((_) => Navigator.pop(context));
                }
              },
              child: Text(_getSubmitButtonTitle()),
            ),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.left,
    );
  }
}

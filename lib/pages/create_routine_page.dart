import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../collections/category.dart';
import '../collections/routine.dart';
import '../core/constants.dart';
import '../cubit/category_cubit/category_cubit.dart';
import '../cubit/routine_cubit/routine_cubit.dart';

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
  // late List<Category> categories = [];
  late final ValueNotifier<Category> dropDownCategory =
      ValueNotifier(Category.empty);

  TimeOfDay selectedTime = TimeOfDay.now();
  late final ValueNotifier<String> selectedDay = ValueNotifier(days[0]);

  late final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _timeController = TextEditingController();
  late final TextEditingController _newCategoryController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!isRoutineNull()) {
      _titleController.text = widget.routine!.title;
      _timeController.text = widget.routine!.startTime;
      selectedDay.value = widget.routine!.day;
      selectedTime = stringToTimeOfDay(widget.routine!.startTime);
    }
  }

  @override
  void dispose() {
    dropDownCategory.dispose();
    selectedDay.dispose();
    _titleController.dispose();
    _timeController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  bool isRoutineNull() => widget.routine == null;

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

  String _getAppBarTitle() {
    if (isRoutineNull()) return 'Add Routine';
    return 'Update Routine';
  }

  String _getSubmitButtonTitle() {
    if (isRoutineNull()) return 'Add';
    return 'Update';
  }

  List<Widget>? _createAppBarActions(BuildContext context) {
    if (isRoutineNull()) return null;
    final RoutineCubit routineCubit = context.read<RoutineCubit>();
    return [
      IconButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content:
                const Text('Are you sure you want to delete this routine?'),
            actions: [
              TextButton(
                onPressed: () {
                  routineCubit.deleteRoutine(routineId: widget.routine!.id);
                  Navigator.of(context).pop(true);
                },
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
    final RoutineCubit routineCubit = context.read<RoutineCubit>();
    final CategoryCubit categoryCubit = context.read<CategoryCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: _createAppBarActions(context),
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
                child: BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoriesLoaded) {
                      final List<Category> newCategories = state.categories;
                      if (newCategories.isNotEmpty) {
                        if (isRoutineNull()) {
                          dropDownCategory.value = newCategories.last;
                        } else {
                          dropDownCategory.value =
                              widget.routine!.category.value!;
                        }
                      }
                      return ValueListenableBuilder<Category>(
                        valueListenable: dropDownCategory,
                        builder: (BuildContext context, _, __) {
                          return DropdownButtonFormField<Category>(
                            value: dropDownCategory.value,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: newCategories
                                .map(
                                  (category) => DropdownMenuItem<Category>(
                                    value: category,
                                    child: Text(category.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => dropDownCategory.value =
                                value ?? dropDownCategory.value,
                          );
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              IconButton(
                onPressed: () => addNewCategoryDialog(context,
                        controller: _newCategoryController)
                    .then((_) {
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
            value: selectedDay.value,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: days
                .map(
                  (day) => DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                selectedDay.value = value ?? selectedDay.value,
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (_titleController.text.isEmpty ||
                    _timeController.text.isEmpty ||
                    dropDownCategory.value.isEmpty) return;
                if (isRoutineNull()) {
                  routineCubit.addRoutine(
                    routine: Routine()
                      ..title = _titleController.text
                      ..startTime = _timeController.text
                      ..day = selectedDay.value
                      ..category.value = dropDownCategory.value,
                  );
                } else {
                  routineCubit.updateRoutine(
                    routine: Routine()
                      ..id = widget.routine!.id
                      ..title = _titleController.text
                      ..startTime = _timeController.text
                      ..day = selectedDay.value
                      ..category.value = dropDownCategory.value,
                  );
                }
                Navigator.pop(context);
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

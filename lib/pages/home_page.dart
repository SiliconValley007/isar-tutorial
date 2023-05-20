import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routine/core/constants.dart';
import 'package:routine/cubit/routine_cubit/routine_cubit.dart';

import '../collections/routine.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => const HomePage());

  @override
  Widget build(BuildContext context) {
    final RoutineCubit routineCubit = context.read<RoutineCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.categoryListPage,
            ),
            icon: const Icon(
              Icons.category,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.createRoutinePage,
            ),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => routineCubit.searchRoutines(value),
              decoration: const InputDecoration(
                hintText: 'Search routines...',
                hintStyle: TextStyle(color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<RoutineCubit, RoutineState>(
              listener: (context, state) {
                if (state is RoutineAdded) {
                  displaySnackBar(
                    context,
                    message: 'Routine added successfully',
                  );
                } else if (state is RoutineUpdated) {
                  displaySnackBar(
                    context,
                    message: 'Routine updated successfully',
                  );
                } else if (state is RoutineDeleted) {
                  displaySnackBar(
                    context,
                    message: 'Routine deleted successfully',
                  );
                } else if (state is AllRoutinesDeleted) {
                  displaySnackBar(
                    context,
                    message: 'All Routine deleted successfully',
                  );
                }
              },
              builder: (context, state) {
                if (state is RoutinesLoaded) {
                  final List<Routine> routines = state.routines;
                  if (routines.isEmpty) {
                    if (state.isSearching) {
                      return const Center(
                        child: Text("No matching routines found"),
                      );
                    } else {
                      return const Center(
                        child: Text(
                          "No Routines added.\nAdd Some",
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      final Routine currentRoutine = routines[index];
                      return Card(
                        elevation: 5,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          side: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentRoutine.title,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const WidgetSpan(
                                      child: Icon(Icons.schedule),
                                    ),
                                    TextSpan(
                                      text: currentRoutine.startTime,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const WidgetSpan(
                                      child: Icon(Icons.calendar_month),
                                    ),
                                    TextSpan(
                                      text: currentRoutine.day,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          trailing: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.createRoutinePage,
                              arguments: currentRoutine,
                            ),
                            child:
                                const Icon(Icons.keyboard_arrow_right_outlined),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => routineCubit.deleteAllRoutines(),
        label: const Text('Clear All'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

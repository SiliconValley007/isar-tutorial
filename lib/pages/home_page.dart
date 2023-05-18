import 'package:flutter/material.dart';
import 'package:routine/core/constants.dart';
import 'package:routine/database/database.dart';

import '../collections/routine.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => const HomePage());

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Database db = Database();

  List<Routine> _routines = [];

  late final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _readRoutines();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _readRoutines() async {
    List<Routine> newRoutines = await db.getRoutines();
    setState(() {
      _routines = newRoutines;
    });
  }

  void searchRoutines(String keyword) async {
    if (keyword.isEmpty) {
      _readRoutines();
    } else {
      final List<Routine> searchedRoutines =
          await db.searchRoutinesByTitle(keyword);
      setState(() {
        _routines = searchedRoutines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.createRoutinePage,
            ).then((_) => _readRoutines()),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: _routines.isEmpty
          ? const Center(
              child: Text(
                'No Records added.\nAdd Some',
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: searchRoutines,
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
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _routines.length,
                    itemBuilder: (context, index) {
                      final Routine currentRoutine = _routines[index];
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
                            ).then((_) => _readRoutines()),
                            child:
                                const Icon(Icons.keyboard_arrow_right_outlined),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => db.deleteAllRoutines().then((_) => _readRoutines()),
        label: const Text('Clear All'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

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
  late final ValueNotifier<String> searchText = ValueNotifier('');

  // List<Routine> _routines = [];

  // late final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _readRoutines();
  }

  @override
  void dispose() {
    // searchController.dispose();
    searchText.dispose();
    super.dispose();
  }

  // Future<void> _readRoutines() async {
  //   List<Routine> newRoutines = await db.getRoutines();
  //   _routines = newRoutines;
  //   // setState(() {
  //   //   _routines = newRoutines;
  //   // });
  // }

  // void searchRoutines(String keyword) async {
  //   if (keyword.isEmpty) {
  //     _readRoutines();
  //   } else {
  //     final List<Routine> searchedRoutines =
  //         await db.searchRoutinesByTitle(keyword);
  //     setState(() {
  //       _routines = searchedRoutines;
  //     });
  //   }
  // }

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
              onChanged: (value) => searchText.value = value,
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
            child: ValueListenableBuilder<String>(
              valueListenable: searchText,
              builder: (context, value, child) => StreamBuilder<List<Routine>>(
                stream: db.watchRoutines(keyword: value),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Unknown error. Restart app"),
                    );
                  }
                  if (snapshot.hasData) {
                    final List<Routine> routines = snapshot.data ?? [];
                    if (routines.isEmpty) {
                      if (searchText.value.isNotEmpty) {
                        return Center(
                          child: Text(
                              "No Routines with title - ${searchText.value}"),
                        );
                      } else {
                        return const Center(
                          child: Text("No Routines added /n Add Some"),
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
                              child: const Icon(
                                  Icons.keyboard_arrow_right_outlined),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => db.deleteAllRoutines(),
        label: const Text('Clear All'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'collections/category.dart';
import 'collections/routine.dart';
import 'database/database.dart';
import 'pages/home_page.dart';
import 'router/app_router.dart';

void main() async {
  // we add this line so that the code we put before runApp() are invoked. By default this line is present inside the runApp() function.
  WidgetsFlutterBinding.ensureInitialized();

  final dir =
        await getApplicationSupportDirectory(); // we use this as this is not directly related to the user's storage space and can be used by apps

    // instance of the isar database
    final Isar isar = await Isar.open(
      [
        RoutineSchema,
        CategorySchema
      ], // passing in the two schemas we generated with build runner
      directory: dir.path,
    );
    
  Database db = Database();
  db.init(isar); //creating and initializing isar db
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routine App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const HomePage(),
    );
  }
}

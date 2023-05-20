import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:routine/cubit/category_cubit/category_cubit.dart';

import 'collections/category.dart';
import 'collections/routine.dart';
import 'cubit/routine_cubit/routine_cubit.dart';
import 'database/database.dart';
import 'pages/home_page.dart';
import 'repository/repository.dart';
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
  ); //creating and initializing isar db
  final Database db = Database(isar: isar);
  runApp(MyApp(
    db: db,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.db});

  final Database db;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CategoryRepository>(
            create: (context) => CategoryRepository(db: db)),
        RepositoryProvider<RoutineRepository>(
            create: (context) => RoutineRepository(db: db)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RoutineCubit>(
            create: (context) =>
                RoutineCubit(repository: context.read<RoutineRepository>()),
          ),
          BlocProvider<CategoryCubit>(
            create: (context) =>
                CategoryCubit(repository: context.read<CategoryRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Routine App',
          theme: ThemeData(
            primarySwatch: Colors.purple,
          ),
          debugShowCheckedModeBanner: false,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const HomePage(),
        ),
      ),
    );
  }
}

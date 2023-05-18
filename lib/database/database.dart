import 'dart:developer';

import 'package:isar/isar.dart';

import '../collections/category.dart';
import '../collections/routine.dart';

class Database {
  static late final Isar _isar;
  void init(Isar isar) {
    // final dir = await getApplicationDocumentsDirectory(); // we don't use this directory as this is where the user of the device stores its personal files
    _isar = isar;
  }

  // create operation
  Future<void> addCategory({required String categoryName}) async {
    final IsarCollection<Category> categories = _isar.categorys;
    final newCategory = Category()..name = categoryName;
    await _isar.writeTxn(() async => await categories.put(newCategory));
  }

  // read operation
  Future<List<Category>> getCategories() async {
    final IsarCollection<Category> categories = _isar.categorys;
    return await categories.where().findAll();
  }

  Category getFirstCategory() {
    final IsarCollection<Category> categories = _isar.categorys;
    Category category = Category()..name = '';
    categories
        .where()
        .findFirst()
        .then((categorie) => category = categorie ?? Category()
          ..name = '');
    return category;
  }

  Future<void> addRoutine(Routine routine) async {
    log(routine.category.value?.name ?? "Add Routine function: category null");
    final IsarCollection<Routine> routines = _isar.routines;
    await _isar.writeTxn(() async {
      await routines.put(routine);
      routine.category.save();
    });
  }

  Future<List<Routine>> getRoutines() async {
    final IsarCollection<Routine> routines = _isar.routines;
    return await routines.where().findAll();
  }

  Future<void> updateRoutine(Routine routine) async {
    final IsarCollection<Routine> routines = _isar.routines;
    await _isar.writeTxn(() async {
      // final getRoutine = await routines.get(routine.id);
      // getRoutine!
      //   ..title = routine.title
      //   ..category.value = routine.category.value
      //   ..day = routine.day
      //   ..startTime = routine.startTime;
      // await routines.put(getRoutine);
      // getRoutine.category.save();

      // does the same thing as the above commented out code, just fewer lines of code
      await routines.put(routine);
      routine.category.save();
    });
  }

  Future<void> deleteRoutine(int routineId) async {
    final IsarCollection<Routine> routines = _isar.routines;
    await _isar.writeTxn(() async => await routines.delete(routineId));
  }

  Future<List<Routine>> searchRoutinesByTitle(String keyword) async {
    final IsarCollection<Routine> routines = _isar.routines;
    return await routines.filter().titleContains(keyword).findAll();
  }

  Future<void> deleteAllRoutines() async {
    final IsarCollection<Routine> routines = _isar.routines;
    final allRoutines = await getRoutines();
    await _isar.writeTxn(() async {
      for (Routine routine in allRoutines) {
        routines.delete(routine.id);
      }
    });
  }

  /// watches and searches for routines present in the database
  Stream<List<Routine>> watchRoutines({String keyword = ''}) async* {
    final IsarCollection<Routine> routines = _isar.routines;
    if (keyword.isNotEmpty) {
      yield* routines
          .filter()
          .titleContains(keyword, caseSensitive: false)
          .watch(fireImmediately: true);
    } else {
      yield* routines.where().watch(fireImmediately: true);
    }
  }

  Stream<List<Category>> watchCategories() async* {
    yield* _isar.categorys.where().watch(fireImmediately: true);
  }
}

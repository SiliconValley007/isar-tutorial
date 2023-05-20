import 'dart:developer';

import 'package:isar/isar.dart';

import '../collections/category.dart';
import '../collections/routine.dart';

class Database {
  final Isar _isar;

  const Database({required Isar isar}) : _isar = isar;

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
  
  Future<void> deleteCategory(int categoryId) async {
    final IsarCollection<Category> categories = _isar.categorys;
    await _isar.writeTxn(() async => await categories.delete(categoryId));
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

  Stream<List<Category>> watchCategories({String keyword = ''}) async* {
    final IsarCollection<Category> categories = _isar.categorys;
    if (keyword.isNotEmpty) {
      yield* categories
          .filter()
          .nameContains(keyword, caseSensitive: false)
          .watch(fireImmediately: true);
    } else {
      yield* categories.where().watch(fireImmediately: true);
    }
  }
}

import '../collections/routine.dart';
import '../database/database.dart';

class RoutineRepository {
  final Database db;

  const RoutineRepository({required this.db});

  Future<void> addRoutine(Routine routine) async {
    await db.addRoutine(routine);
  }

  Future<void> updateRoutine(Routine routine) async {
    await db.updateRoutine(routine);
  }

  Future<void> deleteRoutine(int routineId) async {
    await db.deleteRoutine(routineId);
  }

  Future<void> deleteAllRoutines() async {
    await db.deleteAllRoutines();
  }

  Stream<List<Routine>> watchRoutines({String keyword = ''}) async* {
    yield* db.watchRoutines(keyword: keyword);
  }

  Future<List<Routine>> getRoutines() async {
    return await db.getRoutines();
  }
}

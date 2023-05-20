import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routine/repository/routine_repository.dart';

import '../../collections/routine.dart';

part 'routine_state.dart';

class RoutineCubit extends Cubit<RoutineState> {
  RoutineCubit({required RoutineRepository repository})
      : _repository = repository,
        super(RoutinesLoading()) {
    _routinesSubscription = _repository.watchRoutines().listen((routines) {
      emit(RoutinesLoaded(routines: routines));
    });

    _searchTimer = Timer(duration, () {});
  }
  late final RoutineRepository _repository;
  late StreamSubscription<List<Routine>> _routinesSubscription;
  String _searchKeyword = '';
  Timer? _searchTimer;

  static const Duration duration = Duration(milliseconds: 300);

  @override
  Future<void> close() {
    _routinesSubscription.cancel();
    _searchTimer?.cancel();
    return super.close();
  }

  void _updateStream() {
    _routinesSubscription.cancel();
    if (_searchKeyword.isEmpty) {
      _routinesSubscription = _repository.watchRoutines().listen((routines) {
        emit(RoutinesLoaded(routines: routines));
      });
    } else {
      _routinesSubscription =
          _repository.watchRoutines(keyword: _searchKeyword).listen((routines) {
        emit(RoutinesLoaded(routines: routines, isSearching: true));
      });
    }
  }

  void searchRoutines(String keyword) {
    if (_searchKeyword != keyword) {
      if (_searchTimer != null && _searchTimer!.isActive) {
        _searchTimer!.cancel();
      }

      _searchTimer = Timer(duration, () {
        _searchKeyword = keyword;
        _updateStream();
      });
    }
  }

  // void loadRoutines() async {
  //   final List<Routine> routines = await db.getRoutines();
  //   emit(RoutinesLoaded(routines: routines));
  // }

  void addRoutine({required Routine routine}) async {
    await _repository.addRoutine(routine);
    emit(RoutineAdded());
  }

  void updateRoutine({required Routine routine}) async {
    await _repository.updateRoutine(routine);
    emit(RoutineUpdated());
  }

  void deleteRoutine({required int routineId}) async {
    await _repository.deleteRoutine(routineId);
    emit(RoutineDeleted());
  }

  void deleteAllRoutines() async {
    await _repository.deleteAllRoutines();
    emit(AllRoutinesDeleted());
  }
}

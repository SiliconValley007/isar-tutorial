part of 'routine_cubit.dart';

abstract class RoutineState extends Equatable {
  const RoutineState();

  @override
  List<Object> get props => [];
}

class RoutinesLoading extends RoutineState {}

class RoutineAdded extends RoutineState {}

class RoutineUpdated extends RoutineState {}

class RoutineDeleted extends RoutineState {}

class AllRoutinesDeleted extends RoutineState {}

class RoutinesLoaded extends RoutineState {
  final List<Routine> routines;
  final bool isSearching;

  @override
  List<Object> get props => [
        routines,
        isSearching,
      ];

  const RoutinesLoaded({required this.routines, this.isSearching = false});
}

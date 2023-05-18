// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

import 'category.dart';

part 'routine.g.dart';

@Collection(inheritance: false)
class Routine extends Equatable {
  Id id = Isar.autoIncrement;

  // when creating a table, you should not initialize its properties. Therefore the late modifier to remove the error
  String title = '';

  // routines should be sorted according to time
  @Index() // default index, routines will be sorted in ascending order of their startTime
  String startTime = '';

  @Index(caseSensitive: false) // we want to search day in any case
  String day = '';

  @Index(composite: [
    CompositeIndex('title')
  ]) // this sets  the title and category as composite index and therefore these two will be displayed together
  //this will only hold a category that is already present in the database, and then the category will be linked to this collection
  var category = IsarLink<Category>();

  @ignore
  static Routine empty = Routine();

  @ignore
  bool get isEmpty => this == empty;
  @ignore
  bool get isNotEmpty => this != empty;

  @override 
  @ignore
  List<Object?> get props => [
        id,
        title,
        startTime,
        day,
        category,
      ];
}

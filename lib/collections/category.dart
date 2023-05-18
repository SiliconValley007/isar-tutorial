// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

part 'category.g.dart';

// ignore: must_be_immutable
@Collection(inheritance: false)
class Category extends Equatable {
  Id id = Isar.autoIncrement;
  @Index(unique: true) // category names will be unique
  String name = '';

  @ignore
  static Category empty = Category();

  @ignore
  bool get isEmpty => this == empty;
  @ignore
  bool get isNotEmpty => this != empty;

  @override 
  @ignore
  List<Object?> get props => [
        id,
        name,
      ];
}

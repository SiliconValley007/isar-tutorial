part of 'category_cubit.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoriesLoading extends CategoryState {}

class CategoryAdded extends CategoryState {}

class CategoryUpdated extends CategoryState {}

class CategoryDeleted extends CategoryState {}

class CategoriesLoaded extends CategoryState {
  final List<Category> categories;
  final bool isSearching;

  @override
  List<Object> get props => [
        categories,
        isSearching,
      ];

  const CategoriesLoaded({required this.categories, this.isSearching = false});
}

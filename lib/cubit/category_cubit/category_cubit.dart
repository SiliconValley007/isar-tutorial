import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../collections/category.dart';
import '../../repository/repository.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit({required CategoryRepository repository})
      : _repository = repository,
        super(CategoriesLoading()) {
    _categoriesSubscription =
        _repository.watchCategories().listen((categories) {
      emit(CategoriesLoaded(categories: categories));
    });

    _searchTimer = Timer(duration, () {});
  }

  final CategoryRepository _repository;
  late StreamSubscription<List<Category>> _categoriesSubscription;
  String _searchKeyword = '';
  Timer? _searchTimer;

  static const Duration duration = Duration(milliseconds: 300);

  @override
  Future<void> close() {
    _categoriesSubscription.cancel();
    _searchTimer?.cancel();
    return super.close();
  }

  void addCategory(String categoryName) async {
    await _repository.addCategory(categoryName);
    emit(CategoryAdded());
  }
  
  void deleteCategory(int categoryId) async {
    await _repository.deleteCategory(categoryId);
    emit(CategoryAdded());
  }

  void getCategories() async {
    final List<Category> categories = await _repository.getCategories();
    emit(CategoriesLoaded(categories: categories));
  }

  void _updateStream() {
    _categoriesSubscription.cancel();
    if (_searchKeyword.isEmpty) {
      _categoriesSubscription =
          _repository.watchCategories().listen((categories) {
        emit(CategoriesLoaded(categories: categories));
      });
    } else {
      _categoriesSubscription = _repository
          .watchCategories(keyword: _searchKeyword)
          .listen((categories) {
        emit(CategoriesLoaded(categories: categories, isSearching: true));
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
}

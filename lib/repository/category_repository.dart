import 'package:routine/collections/category.dart';

import '../database/database.dart';

class CategoryRepository {
  final Database db;

  const CategoryRepository({required this.db});

  Future<void> addCategory(String categoryName) async {
    db.addCategory(categoryName: categoryName);
  }
  
  Future<void> deleteCategory(int categoryId) async {
    db.deleteCategory(categoryId);
  }

  Future<List<Category>> getCategories() async {
    return await db.getCategories();
  }

  Stream<List<Category>> watchCategories({String keyword = ''}) async* {
    yield* db.watchCategories(keyword: keyword);
  }
}

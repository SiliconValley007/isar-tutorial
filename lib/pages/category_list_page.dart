import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../collections/category.dart';
import '../core/constants.dart';
import '../cubit/category_cubit/category_cubit.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => const CategoryListPage());

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  late final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CategoryCubit categoryCubit = context.read<CategoryCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () =>
                addNewCategoryDialog(context, controller: controller).then((_) {
              controller.clear();
            }),
            icon: const Icon(Icons.add_circle_outline_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => categoryCubit.searchRoutines(value),
              decoration: const InputDecoration(
                hintText: 'Search categories...',
                hintStyle: TextStyle(color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                if (state is CategoriesLoaded) {
                  final List<Category> categories = state.categories;
                  if (categories.isEmpty) {
                    if (state.isSearching) {
                      return const Center(
                        child: Text("No matching categories found"),
                      );
                    } else {
                      return const Center(
                        child: Text(
                          "No categories added.\nAdd Some",
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final Category category = categories[index];
                      return ListTile(
                        title: Text(category.name),
                        trailing: IconButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: const Text(
                                  'Are you sure you want to delete this category?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    categoryCubit.deleteCategory(category.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}

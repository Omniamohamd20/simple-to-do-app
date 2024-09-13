import 'package:simple_todo_app/helpers/sql_helper.dart';
import 'package:simple_todo_app/models/category.dart';
import 'package:simple_todo_app/pages/categories_ops.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_todo_app/pages/home_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryData> categories = []; // Initialize as an empty list
  bool _showWidget = false;
  int pressedCount = 0;

  @override
  void initState() {
    super.initState();
    getCategories(); // Call this in initState
  }

  void getCategories() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('categories');

      categories = data.isNotEmpty
          ? data.map((item) => CategoryData.fromJson(item)).toList()
          : [];
    } catch (e) {
      print('Error In get data: $e');
      categories = []; // Ensure it's an empty list on error
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () async {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => CategoriesOpsPage()),
              );
              if (result ?? false) {
                getCategories();
              }
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search, filter, sort row
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 295,
                  height: 50,
                  child: TextField(
                    onChanged: (value) async {
                      var sqlHelper = GetIt.I.get<SqlHelper>();
                      var result = await sqlHelper.db!.rawQuery("""
                        SELECT * FROM Categories
                        WHERE name LIKE '%$value%';
                      """);
                      categories = result.isNotEmpty
                          ? result
                              .map((item) => CategoryData.fromJson(item))
                              .toList()
                          : [];
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          bottomLeft: Radius.circular(5.0),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(1)),
                      ),
                      hintText: 'Search',
                    ),
                  ),
                ),
                // Sorting and filtering buttons...
              ],
            ),
              const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length, // No null check needed
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(categories[index].name ?? 'No content'),
                    subtitle: Text('Details about ${categories[index].name}'),
                    onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => HomePage(id: categories[index].id!)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getSortedData(String columnName, String sortType) async {
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data = await sqlHelper.db!.rawQuery("""
      SELECT * FROM Categories ORDER BY $columnName ${sortType == "ASC" ? 'ASC' : 'DESC'};
    """);
    categories = data.isEmpty
        ? data.map((item) => CategoryData.fromJson(item)).toList()
        : [];
    setState(() {});
  }

  Future<void> onDeleteRow(int id) async {
    try {
      var dialogResult = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Category'),
            content:
                const Text('Are you sure you want to delete this category?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (dialogResult ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        var result = await sqlHelper.db!.delete(
          'categories',
          where: 'id =?',
          whereArgs: [id],
        );
        if (result > 0) {
          getCategories();
        }
      }
    } catch (e) {
      print('Error in delete data: $e');
    }
  }
}

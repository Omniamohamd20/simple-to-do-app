import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_todo_app/models/note.dart';
import 'package:simple_todo_app/pages/notes_ops.dart';
import '../helpers/sql_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = []; // Initialize with an empty list
  bool _showWidget = false;
  bool stockFilterPressed = false;
  bool availableFilterPressed = false;

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  void getNotes() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""SELECT * FROM Notes;""");

      setState(() {
        notes = data.isNotEmpty
            ? data.map((item) => Note.fromJson(item)).toList()
            : [];
      });
    } catch (e) {
      print('Error in fetching data: $e');
      setState(() {
        notes = []; // Reset notes on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: () async {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => NotesOps()),
              );
              if (result ?? false) {
                getNotes();
              }
            },
            icon: const Icon(Icons.add),
          ),
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
                Expanded(
                  child: TextField(
                    onChanged: (value) async {
                      var sqlHelper = GetIt.I.get<SqlHelper>();
                      var result = await sqlHelper.db!.rawQuery("""
                        SELECT * FROM Notes
                        WHERE name LIKE '%$value%';
                      """);
                      setState(() {
                        notes = result.isNotEmpty
                            ? result.map((item) => Note.fromJson(item)).toList()
                            : [];
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                // Other filter/sort buttons...
              ],
            ),
            SizedBox(height: 10),
            if (_showWidget)
              // Widget for filters
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter options here
                ],
              ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(notes[index].name ?? 'No content'),
                    subtitle: Text('Details about ${notes[index].name}'),
                    onTap: () {
                      // Handle note tap
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
}
//   Future<void> getSortedData(String columnName, String sortType) async {
//     var sqlHelper = GetIt.I.get<SqlHelper>();
//     var data;
//     if (sortType == "ASC") {
//       data = await sqlHelper.db!.rawQuery("""
// SELECT * FROM Products ORDER BY $columnName ASC;
// """);
//     }
//     if (sortType == "DESC") {
//       data = await sqlHelper.db!.rawQuery("""
// SELECT * FROM Products ORDER BY $columnName DESC;
// """);
//     }
//     if (data.isNotEmpty) {
//       products = [];
//       for (var item in data) {
//         products!.add(Product.fromJson(item));
//       }
//     } else {
//       products = [];
//     }
//     setState(() {});
//   }

  

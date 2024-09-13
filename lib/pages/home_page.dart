import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_todo_app/models/task.dart';
import 'package:simple_todo_app/pages/tasks_ops.dart';
import 'package:simple_todo_app/widgets/categories_drop_down.dart';
import 'package:simple_todo_app/widgets/task_card.dart';
import '../helpers/sql_helper.dart';

class HomePage extends StatefulWidget {
  final int id;
  const HomePage({super.key,required this.id});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasks = []; // Initialize with an empty list
  bool _showWidget = false;
  bool stockFilterPressed = false;
  bool availableFilterPressed = false;

  @override
  void initState() {
    super.initState();
    getTask();
  }

  void getTask() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();

      // Check if db is null
      if (sqlHelper.db == null) {
        print('Database is not initialized.');
        return;
      }

     var data = await sqlHelper.db!.rawQuery(
      """SELECT * FROM tasks WHERE id LIKE '%${widget.id}%';""");
      

      setState(() {
        tasks = data.isNotEmpty
            ? data.map((item) => Task.fromJson(item)).toList()
            : [];
      });
    } catch (e) {
      print('Error in fetching data: $e');
      setState(() {
        tasks = []; // Reset tasks on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('tasks'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu_open_outlined),
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

                      // Check if db is null
                      if (sqlHelper.db == null) {
                        print('Database is not initialized.');
                        return;
                      }

                      var result = await sqlHelper.db!.rawQuery("""
                        SELECT * FROM tasks
                        WHERE name LIKE '%$value%';
                      """);
                      setState(() {
                        tasks = result.isEmpty
                            ? result.map((item) => Task.fromJson(item)).toList()
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
            const SizedBox(height: 10),
            if (_showWidget)
              // Widget for filters

              const SizedBox(height: 10),
            // tasks[index].name ?? 'No content'
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    child: TaskCard(
                      title: tasks[index].name ?? 'No content',
                      description: tasks[index].categoryDesc ?? 'No content',
                      isCompleted: tasks[index].isDone ?? false,
                      onTap: () {
                        setState(() {
                          var isdone = tasks[index].isDone;
                          isdone = !isdone!;
                        });
                      },
                    ),
                    onLongPress: () {
                      onDeleteRow(tasks[index].id!);
                    },
                  );
                },
              ),
            ),
            FloatingActionButton(
              onPressed: () async {
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => TasksOps()),
                );
                if (result ?? false) {
                  getTask();
                }
                // Handle adding a new task
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Add a new task!')),
                );
              },
              child: Icon(Icons.add),
              tooltip: 'Add Task',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onDeleteRow(int id) async {
    try {
      var dialogResult = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete task'),
              content: const Text('Are you sure you want to delete this task?'),
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
          });

      if (dialogResult ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        var result = await sqlHelper.db!.delete(
          'tasks',
          where: 'id =?',
          whereArgs: [id],
        );
        if (result > 0) {
          getTask();
        }
      }
    } catch (e) {
      print('Error In delete data $e');
    }
  }
}

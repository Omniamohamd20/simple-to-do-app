import 'package:simple_todo_app/helpers/sql_helper.dart';
import 'package:simple_todo_app/models/task.dart';
import 'package:simple_todo_app/widgets/app_elevated_button.dart';
import 'package:simple_todo_app/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_todo_app/widgets/categories_drop_down.dart';

class TasksOps extends StatefulWidget {
  final Task? task;
  const TasksOps({this.task, super.key});

  @override
  State<TasksOps> createState() => _TasksOpsState();
}

class _TasksOpsState extends State<TasksOps> {
  var formKey = GlobalKey<FormState>();
  late TextEditingController nameController; // Use late
  late TextEditingController contentController; // Use late
  late TextEditingController imageController; // Use late
  bool isDone = false;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    setInitialData();
  }

  void setInitialData() {
    nameController = TextEditingController(text: widget.task?.name ?? '');
    contentController = TextEditingController(text: widget.task?.content ?? '');
    imageController = TextEditingController(text: widget.task?.image ?? '');
    isDone = widget.task?.isDone ?? false;
    selectedCategoryId = widget.task?.categoryId;
  }

  @override
  void dispose() {
    nameController.dispose(); // Dispose controllers
    contentController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Update' : 'Add New'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppTextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                  label: 'Name',
                ),
                const SizedBox(height: 20),
                AppTextFormField(
                  controller: contentController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                  label: 'Description',
                ),
                const SizedBox(height: 20),
                AppTextFormField(
                  controller: imageController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Image Url is required';
                    }
                    return null;
                  },
                  label: 'Image Url',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Switch(
                      value: isDone,
                      onChanged: (value) {
                        setState(() {
                          isDone = value;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    const Text('Is Available'),
                    
                  ],
                ),
                  CategoriesDropDown(
                  selectedValue: selectedCategoryId,
                  onChanged: (categoryId) {
                    setState(() {
                      selectedCategoryId = categoryId;
                    });
                  },
                ),
                const SizedBox(height: 20),
                AppElevatedButton(
                  label: 'Submit',
                  onPressed: () async {
                    await onSubmit();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.task != null) {
          // Update logic
          await sqlHelper.db!.update(
            'tasks',
            {
              'name': nameController.text,
              'content': contentController.text,
              'image': imageController.text,
              'isDone': isDone,
              'categoryId': selectedCategoryId,
            },
            where: 'id =?',
            whereArgs: [widget.task!.id], // Use ! safely
          );
        } else {
          await sqlHelper.db!.insert('tasks', {
            'name': nameController.text,
            'content': contentController.text,
            'image': imageController.text,
            'isDone': isDone,
            'categoryId': selectedCategoryId,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text('task Saved Successfully'),
        ));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error In Create task: $e'),
      ));
    }
  }
}

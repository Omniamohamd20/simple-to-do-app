import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_todo_app/helpers/sql_helper.dart';
import 'package:simple_todo_app/models/note.dart';
import 'package:simple_todo_app/widgets/app_elevated_button.dart';
import 'package:simple_todo_app/widgets/app_text_form_field.dart';

class NotesOps extends StatefulWidget {
  final Note? note;
  const NotesOps({this.note, super.key});

  @override
  State<NotesOps> createState() => _NotesOpsState();
}

class _NotesOpsState extends State<NotesOps> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController; // Use late initialization
  late TextEditingController contentController; // Use late initialization
  late TextEditingController imageController; // Use late initialization
  bool isDone = false;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    setInitialData();
  }

  void setInitialData() {
    // Initialize controllers
    nameController = TextEditingController(text: widget.note?.name);
    contentController = TextEditingController(text: widget.note?.content);
    imageController = TextEditingController(
        text: widget.note?.image); // Initialize image controller

    isDone = widget.note?.isDone ?? false;
    selectedCategoryId = widget.note?.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note != null ? 'Update' : 'Add New'),
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
                    if (value!.isEmpty) {
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
                    if (value!.isEmpty) {
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
                    if (value!.isEmpty) {
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
        if (widget.note != null) {
          // Update logic
          await sqlHelper.db!.update(
            'notes',
            {
              'name': nameController.text,
              'content': contentController.text,
              'image': imageController.text,
              'isDone': isDone,
              'categoryId': selectedCategoryId,
            },
            where: 'id =?',
            whereArgs: [widget.note?.id],
          );
        } else {
          // Insert logic
          await sqlHelper.db!.insert('notes', {
            'name': nameController.text,
            'content': contentController.text,
            'image': imageController.text,
            'isDone': isDone,
            'categoryId': selectedCategoryId,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Note saved successfully'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error in creating note: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    nameController.dispose();
    contentController.dispose();
    imageController.dispose();
    super.dispose();
  }
}

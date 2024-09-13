import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_todo_app/helpers/sql_helper.dart';

class AddNote extends StatefulWidget {
 
  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  var formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();

  TextEditingController contentController = TextEditingController();

  bool isDone = false;

  int? selectedCategoryId;

  @override

  void initState() {
    setInitialData();

    super.initState();
  }

  void setInitialData() {
    titleController = TextEditingController();
   contentController =
        TextEditingController();

    // isDone = widget.product?.isAvailable ?? false;
    // selectedCategoryId = widget.product?.categoryId;
    setState(() {});
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Pass the new note back to the home page
                onSubmit();
                Navigator.pop(context); // Go back after saving
              },
              child: Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        await sqlHelper.db!.insert('products', {
          'name': titleController.text,
          'content': contentController.text,
          'isDone': isDone,
          'categoryId': selectedCategoryId,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text('Category Saved Successfully')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error In Create Category : $e')));
    }
  }
}

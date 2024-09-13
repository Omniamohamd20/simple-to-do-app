import 'package:simple_todo_app/helpers/sql_helper.dart';
import 'package:simple_todo_app/models/category.dart';
import 'package:simple_todo_app/widgets/app_elevated_button.dart';
import 'package:simple_todo_app/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CategoriesOpsPage extends StatefulWidget {
  final CategoryData? categoryData;
  const CategoriesOpsPage({this.categoryData, super.key});

  @override
  State<CategoriesOpsPage> createState() => _CategoriesOpsPageState();
}

class _CategoriesOpsPageState extends State<CategoriesOpsPage> {
  var formKey = GlobalKey<FormState>();
  late TextEditingController nameController; // Change to late

  @override
  void initState() {
    super.initState();
    // Initialize nameController safely
    nameController =
        TextEditingController(text: widget.categoryData?.name ?? '');
  }

  @override
  void dispose() {
    nameController.dispose(); // Dispose controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryData != null ? 'Update' : 'Add New'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              AppTextFormField(
                controller: nameController, // No null check necessary
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
                label: 'Name',
              ),
              SizedBox(height: 20),
              SizedBox(height: 50),
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
    );
  }

  Future<void> onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        if (widget.categoryData != null) {
          // Update logic
          await sqlHelper.db!.update(
            'categories',
            {
              'name': nameController.text,
            },
            where: 'id =?',
            whereArgs: [widget.categoryData!.id], // Use ! here safely
          );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text('Category updated Successfully'),
          ));
          Navigator.pop(context, true);
        } else {
          // Insert logic
          await sqlHelper.db!.insert('categories', {
            'name': nameController.text,
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text('Category Saved Successfully'),
          ));
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error In Create Category: $e'),
      ));
    }
  }
}

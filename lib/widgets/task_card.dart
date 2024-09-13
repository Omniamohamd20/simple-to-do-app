import 'package:flutter/material.dart';
class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isCompleted;
  
  final Function() onTap;

  const TaskCard({
    Key? key,
    required this.title,
    required this.description,
required this.onTap(),
    required this.isCompleted,
  }) : super(key: key);

Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.grey : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: isCompleted ? Colors.grey : Colors.black54,
              ),
            ),
            SizedBox(height: 16),
            
            if (!isCompleted)
              ElevatedButton(
                onPressed: () {
           onTap();
                },
                child: Text('Mark as Complete'),
              ),
          ],
        ),
      ),
    );
  }
}
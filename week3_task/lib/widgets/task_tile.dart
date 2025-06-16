import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  final String taskText;
  final bool isCompleted;
  final VoidCallback onTap;

  TaskTile({required this.taskText, required this.isCompleted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      title: Text(
        taskText,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
          color: isCompleted ? Colors.grey : Colors.black87,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.check_circle, color: isCompleted ? Colors.green : Colors.grey),
        onPressed: onTap,
      ),
    );
  }
}
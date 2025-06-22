import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  final String taskText;
  final bool isCompleted;
  final VoidCallback onTap;
  final bool isDarkTheme;

  TaskTile({required this.taskText, required this.isCompleted, required this.onTap, this.isDarkTheme = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      title: Text(
        taskText,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
          color: isDarkTheme ? (isCompleted ? Colors.white54 : Colors.white) : (isCompleted ? Colors.grey : Colors.black87),
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.check_circle, color: isDarkTheme ? (isCompleted ? Colors.green[300] : Colors.grey[400]) : (isCompleted ? Colors.green : Colors.grey)),
        onPressed: onTap,
      ),
    );
  }
}
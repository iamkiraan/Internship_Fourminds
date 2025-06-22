import 'package:flutter/material.dart';

class EmptyScreen extends StatelessWidget {
  final bool isDarkTheme;

  EmptyScreen({this.isDarkTheme = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: isDarkTheme ? Colors.blueGrey[800] : Colors.blue[100],
            child: Icon(Icons.person, size: 60, color: isDarkTheme ? Colors.white : Colors.blue[700]),
          ),
          SizedBox(height: 20),
          Text('All Done For Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkTheme ? Colors.white : Colors.blue[700])),
          Text('Next Task Tomorrow 3:55 PM', style: TextStyle(color: isDarkTheme ? Colors.white70 : Colors.grey[600])),
          Text('Time for a Break', style: TextStyle(color: isDarkTheme ? Colors.white70 : Colors.grey[600])),
        ],
      ),
    );
  }
}
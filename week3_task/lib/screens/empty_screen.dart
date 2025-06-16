import 'package:flutter/material.dart';

class EmptyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue[100],
            child: Icon(Icons.person, size: 60, color: Colors.blue[700]),
          ),
          SizedBox(height: 20),
          Text('All Done For Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[700])),
          Text('Next Task Tomorrow 3:55 PM', style: TextStyle(color: Colors.grey[600])),
          Text('Time for a Break', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThingsToDo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFE6F0FA),
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black87)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white70,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Color(0xFF2C2F33),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white), // For app bar title
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, // Text/icon color
            backgroundColor: Colors.blueGrey[700], // Button background
          ),
        ),
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,x
    );
  }
}
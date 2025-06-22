import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:week_task4/phone_auth_page.dart';
import 'package:week_task4/signup_screen.dart';

import 'auth_wrapper.dart';
import 'home_page.dart';
import 'login_screen.dart';
import 'otp_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
        '/phone': (context) => PhoneAuthPage(),
        '/otp': (context) => OTPPage(),
      },
    );
  }
}
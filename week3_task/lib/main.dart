import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThingsToDo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.lightBlue[100],
        padding: EdgeInsets.all(20),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Things ToDo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('username', _usernameController.text);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      }
                    },
                    child: Text('LOGIN'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<String> _tasks = ['Meeting with client 10:00 AM', 'Lunch with Julie 12:30 PM', 'Meet Josh 04:00 PM'];
  final List<String> _taskTimes = ['10:00 AM', '12:30 PM', '04:00 PM'];
  int _completedTasks = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks = prefs.getStringList('tasks') ?? _tasks;
      _completedTasks = prefs.getInt('completedTasks') ?? 0;
    });
  }

  void _toggleTaskCompletion(int index) async {
    setState(() {
      if (_tasks[index].contains('Completed')) {
        _tasks[index] = _tasks[index].replaceAll(' (Completed)', '');
        _completedTasks--;
      } else {
        _tasks[index] += ' (Completed)';
        _completedTasks++;
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks', _tasks);
    await prefs.setInt('completedTasks', _completedTasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ThingsToDo'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(onPressed: () => setState(() => _selectedIndex = 0), child: Text('DAILY')),
              ElevatedButton(onPressed: () => setState(() => _selectedIndex = 1), child: Text('WEEKLY')),
              ElevatedButton(onPressed: () => setState(() => _selectedIndex = 2), child: Text('MONTHLY')),
            ],
          ),
        ),
      ),
      body: _selectedIndex == 0
          ? Padding(
        padding: EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text('TODAY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Completed $_completedTasks/$_tasks.length'),
                ...List.generate(_tasks.length, (index) {
                  return ListTile(
                    title: Text(_tasks[index], style: _tasks[index].contains('Completed') ? TextStyle(decoration: TextDecoration.lineThrough) : null),
                    trailing: IconButton(
                      icon: Icon(Icons.check, color: _tasks[index].contains('Completed') ? Colors.green : Colors.grey),
                      onPressed: () => _toggleTaskCompletion(index),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      )
          : Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 100, color: Colors.blue),
                Text('All Done For Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Next Task Tomorrow 3:55 PM'),
                Text('Time for a Break'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
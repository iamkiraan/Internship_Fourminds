import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/task_tile.dart';
import 'empty_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Map<String, List<String>> _tasks = {
    'daily': ['Meeting with client 10:00 AM', 'Lunch with Julie 12:30 PM', 'Meet Josh 04:00 PM'],
    'weekly': ['Team meeting 09:00 AM', 'Project review 02:00 PM'],
    'monthly': ['Budget planning 10:00 AM', 'Client presentation 03:00 PM'],
  };
  Map<String, int> _completedTasks = {'daily': 0, 'weekly': 0, 'monthly': 0};
  final _taskController = TextEditingController();
  String _username = 'User';
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _tasks['daily'] = prefs.getStringList('daily_tasks') ?? _tasks['daily']!;
      _tasks['weekly'] = prefs.getStringList('weekly_tasks') ?? _tasks['weekly']!;
      _tasks['monthly'] = prefs.getStringList('monthly_tasks') ?? _tasks['monthly']!;
      _completedTasks['daily'] = prefs.getInt('daily_completed') ?? 0;
      _completedTasks['weekly'] = prefs.getInt('weekly_completed') ?? 0;
      _completedTasks['monthly'] = prefs.getInt('monthly_completed') ?? 0;
    });
  }

  void _toggleTaskCompletion(String period, int index) async {
    setState(() {
      if (_tasks[period]![index].contains(' (Completed)')) {
        _tasks[period]![index] = _tasks[period]![index].replaceAll(' (Completed)', '');
        _completedTasks[period] = _completedTasks[period]! - 1;
      } else {
        _tasks[period]![index] += ' (Completed)';
        _completedTasks[period] = _completedTasks[period]! + 1;
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('${period}_tasks', _tasks[period]!);
    await prefs.setInt('${period}_completed', _completedTasks[period]!);
  }

  void _addTask(String period) async {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks[period]!.add(_taskController.text);
      });
      _taskController.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('${period}_tasks', _tasks[period]!);
    }
  }

  void _showSettings() {
    final _nameController = TextEditingController(text: _username);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Change Name'),
            ),
            SwitchListTile(
              title: Text('Dark Theme'),
              value: _isDarkTheme,
              onChanged: (value) async {
                setState(() => _isDarkTheme = value);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isDarkTheme', value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              setState(() => _username = _nameController.text);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('username', _nameController.text);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periods = ['daily', 'weekly', 'monthly'];
    final currentTasks = _tasks[periods[_selectedIndex]]!;
    final currentCompleted = _completedTasks[periods[_selectedIndex]]!;

    return MaterialApp(
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('ThingsToDo - $_username', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue[700],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavButton('DAILY', 0),
                  _buildNavButton('WEEKLY', 1),
                  _buildNavButton('MONTHLY', 2),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: _showSettings,
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(periods[_selectedIndex].toUpperCase(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                  Text('Completed $currentCompleted/${currentTasks.length}', style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 10),
                  Expanded(
                    child: currentTasks.isEmpty
                        ? EmptyScreen()
                        : ListView.builder(
                      itemCount: currentTasks.length,
                      itemBuilder: (context, index) {
                        return TaskTile(
                          taskText: currentTasks[index],
                          isCompleted: currentTasks[index].contains(' (Completed)'),
                          onTap: () => _toggleTaskCompletion(periods[_selectedIndex], index),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskController,
                          decoration: InputDecoration(
                            hintText: 'Add new task',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.white70,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700], // Replaced 'primary' with 'backgroundColor'
                          shape: CircleBorder(),
                        ),
                        onPressed: () => _addTask(periods[_selectedIndex]),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(String title, int index) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedIndex == index ? Colors.blue[900] : Colors.blue[700], // Replaced 'primary' with 'backgroundColor'
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => setState(() => _selectedIndex = index),
      child: Text(title),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF1A1A40),
        scaffoldBackgroundColor: Color(0xFF2A2D43),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFFFF79C6),
          secondary: Color(0xFF8BE9FD),
        ),
      ),
      home: TaskListScreen(),
    );
  }
}

class Task {
  String title;
  String description;
  String startDate;
  String endDate;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'isCompleted': isCompleted,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      description: map['description'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      isCompleted: map['isCompleted'],
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final List<dynamic> taskList = jsonDecode(tasksString);
      setState(() {
        _tasks = taskList.map((task) => Task.fromMap(task)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString =
        jsonEncode(_tasks.map((task) => task.toMap()).toList());
    prefs.setString('tasks', tasksString);
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _markAsCompleted(int index) {
    setState(() {
      _tasks[index].isCompleted = true;
    });
    _saveTasks();
  }

  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF373A47),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.title,
                style: TextStyle(color: Colors.white),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Descrição:', style: TextStyle(color: Colors.white70)),
              Text(task.description, style: TextStyle(color: Colors.white)),
              SizedBox(height: 10),
              Text('Início:', style: TextStyle(color: Colors.white70)),
              Text(task.startDate, style: TextStyle(color: Colors.white)),
              SizedBox(height: 10),
              Text('Término:', style: TextStyle(color: Colors.white70)),
              Text(task.endDate, style: TextStyle(color: Colors.white)),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _markAsCompleted(_tasks.indexOf(task)),
                    child: Text(task.isCompleted
                        ? 'Concluído'
                        : 'Marcar como Concluído'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteTask(_tasks.indexOf(task));
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Excluir'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Tarefas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            final task = _tasks[index];
            return Container(
              margin: EdgeInsets.only(bottom: 16.0),
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Color(0xFF454954),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    color: Colors.white,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  'Início: ${task.startDate} | Fim: ${task.endDate}',
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: () => _showTaskDetails(task),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
          if (result != null && result is Task) {
            _addTask(result);
          }
        },
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Tarefa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  labelText: 'Título', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                  labelText: 'Descrição', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _startDateController,
              decoration: InputDecoration(
                  labelText: 'Data de Início', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _endDateController,
              decoration: InputDecoration(
                  labelText: 'Data de Término', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final task = Task(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  startDate: _startDateController.text,
                  endDate: _endDateController.text,
                );
                Navigator.pop(context, task);
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

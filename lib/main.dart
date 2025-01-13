import 'package:flutter/material.dart';
import 'package:todo_app/todo_sevice.dart';

void main() => runApp(TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  TodoListScreenState createState() => TodoListScreenState();
}

class TodoListScreenState extends State<TodoListScreen> {
  final TodoService _todoService = TodoService();
  List todos = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    try {
      final fetchedTodos = await _todoService.fetchTodos();
      setState(() {
        todos = fetchedTodos;
      });
    } catch (error) {
      // ignore: avoid_print
      print('Error: $error');
    }
  }

  Future<void> addTodo() async {
    final String title = _titleController.text;
    final String description = _descriptionController.text;

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter title and description')),
      );
      return;
    }

    try {
      await _todoService.addTodo(title, description);
      _titleController.clear();
      _descriptionController.clear();
      fetchTodos();
    } catch (error) {
      // ignore: avoid_print
      print('Error: $error');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _todoService.deleteTodo(id);
      fetchTodos();
    } catch (error) {
      // ignore: avoid_print
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        todo['title'] ?? 'No Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(todo['description'] ?? 'No Description'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.green),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => UpdateTodoDialog(
                                  id: todo['id'],
                                  currentTitle: todo['title'],
                                  currentDescription: todo['description'],
                                  fetchTodos: fetchTodos,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteTodo(todo['id']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                isDense: true,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                isDense: true,
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: addTodo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Add Todo'),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateTodoDialog extends StatefulWidget {
  final String id;
  final String currentTitle;
  final String currentDescription;
  final Future<void> Function() fetchTodos;

  const UpdateTodoDialog({
    super.key,
    required this.id,
    required this.currentTitle,
    required this.currentDescription,
    required this.fetchTodos,
  });

  @override
  UpdateTodoDialogState createState() => UpdateTodoDialogState();
}

class UpdateTodoDialogState extends State<UpdateTodoDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  final TodoService _todoService = TodoService();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.currentTitle);
    descriptionController =
        TextEditingController(text: widget.currentDescription);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Todo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await _todoService.updateTodo(
                widget.id,
                titleController.text,
                descriptionController.text,
              );
              await widget.fetchTodos();
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Todo updated successfully')),
              );
            } catch (e) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update Todo: $e')),
              );
            }
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}

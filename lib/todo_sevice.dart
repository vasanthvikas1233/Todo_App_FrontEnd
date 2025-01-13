import 'package:http/http.dart' as http;
import 'dart:convert';

class TodoService {
  final String baseUrl =
      'http://localhost:6001/api/todos'; // Replace with your backend URL

  Future<List<dynamic>> fetchTodos() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch todos');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  Future<void> addTodo(String title, String description) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title, 'description': description}),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to add todo');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete todo');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  Future<void> updateTodo(String id, String title, String description) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'description': description}),
    );

    if (response.statusCode == 200) {
      // ignore: avoid_print
      print('Todo updated successfully');
    } else {
      // ignore: avoid_print
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to update Todo');
    }
  }
}

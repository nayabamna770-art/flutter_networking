import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_signup_model.dart';
import '../models/todo_model.dart';

class ApiService {
  static const String baseUrl = 'http://89.117.50.168:1234';

  // Helper method to parse FastAPI error detail safely
  String _extractErrorMessage(dynamic detail, String fallback) {
    if (detail is String) {
      return detail;
    } else if (detail is List && detail.isNotEmpty) {
      // FastAPI 422 detail format: [{"loc": [...], "msg": "field required", "type": "value_error"}]
      final firstError = detail.first;
      if (firstError is Map && firstError.containsKey('msg')) {
        return firstError['msg'];
      }
    }
    return fallback;
  }

  // --- AUTHENTICATION ---
  Future<Map<String, dynamic>> signUp(UserSignUpModel user) async {
    final url = Uri.parse('$baseUrl/signup');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(user.toJson()),
      );

      // Try parsing JSON safely
      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        // If response body isn't valid JSON (e.g. 500 Internal Server Error string)
        return {
          'success': false,
          'message': 'Server error (${response.statusCode}): ${response.body}',
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Sign up successful!',
        };
      } else {
        return {
          'success': false,
          'message': _extractErrorMessage(data['detail'], 'Sign up failed'),
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/token');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {'username': email, 'password': password},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Login successful!',
          'token': data['access_token'],
        };
      } else {
        return {
          'success': false,
          'message': _extractErrorMessage(
            data['detail'],
            'Invalid credentials',
          ),
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // --- TO-DO ENDPOINTS ---
  Future<List<TodoModel>> fetchTodos(String token) async {
    final url = Uri.parse('$baseUrl/todos');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => TodoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  Future<TodoModel> addTodo(String token, String title) async {
    final url = Uri.parse('$baseUrl/todos');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return TodoModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add todo');
    }
  }

  Future<bool> deleteTodo(String token, String id) async {
    final url = Uri.parse('$baseUrl/todos/$id');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}

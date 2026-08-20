import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_signup_model.dart';
import '../models/todo_model.dart';

class LocalStorageService {
  Box get _usersBox => Hive.box('users');
  Box get _todosBox => Hive.box('todos');

  // ================= AUTHENTICATION =================

  Future<Map<String, dynamic>> signUp(UserSignUpModel user) async {
    final existingUser = _usersBox.get(user.email);
    if (existingUser != null) {
      return {
        'success': false,
        'message': 'User with this email already exists!',
      };
    }

    final userData = {
      'email': user.email,
      'password': user.password,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _usersBox.put(user.email, userData);

    return {
      'success': true,
      'message': 'Account created successfully!',
      'token': 'local_token_${DateTime.now().millisecondsSinceEpoch}',
      'data': userData,
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final userData = _usersBox.get(email);

    if (userData == null) {
      return {
        'success': false,
        'message': 'No account found with this email.',
      };
    }

    final userMap = Map<String, dynamic>.from(userData as Map);

    if (userMap['password'] != password) {
      return {
        'success': false,
        'message': 'Invalid password.',
      };
    }

    return {
      'success': true,
      'message': 'Login successful!',
      'token': 'local_token_${DateTime.now().millisecondsSinceEpoch}',
      'data': userMap,
    };
  }

  // ================= TODOS MANAGEMENT =================

  List<dynamic> getTodos() {
    return _todosBox.values.toList();
  }

  Future<void> saveAllTodos(List<TodoModel> todos) async {
    await _todosBox.clear();
    for (var todo in todos) {
      await _todosBox.put(todo.id, todo.toJson(includeId: true));
    }
  }

  Future<void> deleteTodo(String id) async {
    await _todosBox.delete(id);
  }
}
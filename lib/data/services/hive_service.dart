import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_signup_model.dart';

class LocalStorageService {
  // Use getters to safely fetch boxes after Hive initializes
  Box get _usersBox => Hive.box('users');
  Box get _todosBox => Hive.box('todos');
  Box get _sessionBox => Hive.box('session');

  // Helper to sanitize keys consistently
  String _formatKey(String key) => key.trim().toLowerCase();

  // Sign Up: Accepts UserSignUpModel and returns Map<String, dynamic>
  Future<Map<String, dynamic>> signUp(UserSignUpModel user) async {
    final cleanEmail = _formatKey(user.email);
    final cleanPassword = user.password.trim();

    if (_usersBox.containsKey(cleanEmail)) {
      return {
        'success': false,
        'message': 'User already registered!',
      };
    }

    // Save plain sanitized key and value
    await _usersBox.put(cleanEmail, cleanPassword);
    await _sessionBox.put('active_user', cleanEmail);

    return {
      'success': true,
      'message': 'Account created successfully!',
      'token': 'local_token_$cleanEmail',
      'data': {'email': cleanEmail},
    };
  }

  // Login: Returns Map<String, dynamic>
  Future<Map<String, dynamic>> login(String email, String password) async {
    final cleanEmail = _formatKey(email);
    final cleanPassword = password.trim();

    final storedPassword = _usersBox.get(cleanEmail);

    if (storedPassword == null || storedPassword.toString() != cleanPassword) {
      return {
        'success': false,
        'message': 'Invalid email or password',
      };
    }

    await _sessionBox.put('active_user', cleanEmail);

    return {
      'success': true,
      'message': 'Login successful!',
      'token': 'local_token_$cleanEmail',
      'data': {'email': cleanEmail},
    };
  }

  // Get Current Logged-In User
  String? getActiveUser() {
    final rawUser = _sessionBox.get('active_user');
    return rawUser != null ? _formatKey(rawUser.toString()) : null;
  }

  // Logout
  Future<void> logout() async {
    await _sessionBox.delete('active_user');
  }

  // Fetch To-Dos
  List<Map<String, dynamic>> getTodos() {
    final activeUser = getActiveUser();
    if (activeUser == null) return [];

    final rawList = _todosBox.get(activeUser, defaultValue: []);
    return (rawList as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // Add To-Do
  Future<void> addTodo(String title, String description) async {
    final activeUser = getActiveUser();
    if (activeUser == null) throw Exception('No active session!');

    final todos = getTodos();
    final newTodo = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title.trim(),
      'description': description.trim(),
      'is_completed': false,
    };

    todos.add(newTodo);
    await _todosBox.put(activeUser, todos);
  }

  // Delete To-Do
  Future<void> deleteTodo(String id) async {
    final activeUser = getActiveUser();
    if (activeUser == null) return;

    final todos = getTodos();
    todos.removeWhere((todo) => todo['id'] == id);
    await _todosBox.put(activeUser, todos);
  }

  // Toggle To-Do Status
  Future<void> toggleTodo(String id) async {
    final activeUser = getActiveUser();
    if (activeUser == null) return;

    final todos = getTodos();
    for (var todo in todos) {
      if (todo['id'] == id) {
        todo['is_completed'] = !(todo['is_completed'] as bool);
        break;
      }
    }
    await _todosBox.put(activeUser, todos);
  }
}
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_signup_model.dart';

class LocalStorageService {
  final Box _usersBox = Hive.box('users');
  final Box _todosBox = Hive.box('todos');
  final Box _sessionBox = Hive.box('session');

  // Sign Up: Accepts UserSignUpModel and returns Map<String, dynamic>
  Future<Map<String, dynamic>> signUp(UserSignUpModel user) async {
    if (_usersBox.containsKey(user.email)) {
      return {
        'success': false,
        'message': 'User already registered!',
      };
    }

    await _usersBox.put(user.email, user.password);
    await _sessionBox.put('active_user', user.email);

    return {
      'success': true,
      'message': 'Account created successfully!',
      'token': 'local_token_${user.email}',
      'data': {'email': user.email},
    };
  }

  // Login: Returns Map<String, dynamic>
  Future<Map<String, dynamic>> login(String email, String password) async {
    final storedPassword = _usersBox.get(email);

    if (storedPassword == null || storedPassword != password) {
      return {
        'success': false,
        'message': 'Invalid email or password',
      };
    }

    await _sessionBox.put('active_user', email);

    return {
      'success': true,
      'message': 'Login successful!',
      'token': 'local_token_$email',
      'data': {'email': email},
    };
  }

  // Get Current Logged-In User
  String? getActiveUser() {
    return _sessionBox.get('active_user');
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
    return (rawList as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // Add To-Do
  Future<void> addTodo(String title, String description) async {
    final activeUser = getActiveUser();
    if (activeUser == null) throw Exception('No active session!');

    final todos = getTodos();
    final newTodo = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'description': description,
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
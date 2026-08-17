import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  final Box _usersBox = Hive.box('users');
  final Box _todosBox = Hive.box('todos');
  final Box _sessionBox = Hive.box('session');

  // Sign Up: Store user credentials
  Future<void> signUp(String email, String password) async {
    if (_usersBox.containsKey(email)) {
      throw Exception('User already registered!');
    }
    await _usersBox.put(email, password);
  }

  // Login: Validate credentials & set active session
  Future<String> login(String email, String password) async {
    final storedPassword = _usersBox.get(email);
    if (storedPassword == null || storedPassword != password) {
      throw Exception('Invalid email or password');
    }
    await _sessionBox.put('active_user', email);
    return email;
  }

  // Get Current Logged-In User
  String? getActiveUser() {
    return _sessionBox.get('active_user');
  }

  // Logout
  Future<void> logout() async {
    await _sessionBox.delete('active_user');
  }

  // Fetch To-Dos for Current User
  List<Map<String, dynamic>> getTodos() {
    final activeUser = getActiveUser();
    if (activeUser == null) return [];

    final rawList = _todosBox.get(activeUser, defaultValue: []);
    
    // Cast dynamic Hive list back to List<Map<String, dynamic>>
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

  // Toggle To-Do Completion Status
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/todo_model.dart';
import '../data/services/hive_service.dart';
import 'todos_state.dart';

class TodosCubit extends Cubit<TodosState> {
  final LocalStorageService _hiveService;
  final SupabaseClient _supabase = Supabase.instance.client;

  TodosCubit(this._hiveService) : super(TodosInitial());

  // Get current authenticated user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<void> loadTodos() async {
    if (isClosed) return;
    emit(TodosLoading());
    try {
      // 1. Fetch online data from Supabase
      if (_currentUserId != null) {
        final response = await _supabase
            .from('todos')
            .select()
            .eq('user_id', _currentUserId!)
            .order('created_at', ascending: false);

        final remoteTodos = (response as List)
            .map((json) => TodoModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        // Save to local storage cache
      for (var todo in remoteTodos) {
 // Replace the for-loop on lines 33-35 with this single line:
await _hiveService.saveAllTodos(remoteTodos); // Use your HiveService's single save method
}
       // await _hiveService.saveTodo(remoteTodos);
      }

      // 2. Read from local Hive storage
      final rawTodos = _hiveService.getTodos();
      final todos = rawTodos.map((e) {
        final Map<String, dynamic> formattedMap = Map<String, dynamic>.from(e as Map);
        return TodoModel.fromJson(formattedMap);
      }).toList();

      if (isClosed) return;
      emit(TodosLoaded(todos));
    } catch (e) {
      if (isClosed) return;
      emit(TodosError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> addTodo(String title) async {
    if (isClosed) return;
    final userId = _currentUserId;
    if (userId == null) {
      emit(TodosError('User must be logged in to create a todo.'));
      return;
    }

    try {
      final newTodo = TodoModel(
        id: '', // Supabase auto-generates UUID primary key
        userId: userId,
        title: title,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Insert into Supabase (omitting ID field via toJson)
      await _supabase.from('todos').insert(newTodo.toJson(includeId: false));

      await loadTodos();
    } catch (e) {
      if (isClosed) return;
      emit(TodosError('Failed to add task: ${e.toString()}'));
    }
  }

  Future<void> toggleTodoStatus(String id, bool currentStatus) async {
    if (isClosed) return;
    try {
      await _supabase
          .from('todos')
          .update({'is_completed': !currentStatus})
          .eq('id', id);

      await loadTodos();
    } catch (e) {
      if (isClosed) return;
      emit(TodosError('Failed to update task status: ${e.toString()}'));
    }
  }

  Future<void> deleteTodo(String id) async {
    if (isClosed) return;
    try {
      await _supabase.from('todos').delete().eq('id', id);

      await loadTodos();
    } catch (e) {
      if (isClosed) return;
      emit(TodosError('Failed to delete task: ${e.toString()}'));
    }
  }
}
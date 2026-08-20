import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/todo_model.dart';
import '../data/services/hive_service.dart';
import 'todos_state.dart';

class TodosCubit extends Cubit<TodosState> {
  final LocalStorageService _hiveService;
  final SupabaseClient _supabase = Supabase.instance.client;

  TodosCubit(this._hiveService) : super(TodosInitial());

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<void> loadTodos() async {
    if (isClosed) return;
    emit(TodosLoading());
    try {
      if (_currentUserId != null) {
        final response = await _supabase
            .from('todos')
            .select()
            .eq('user_id', _currentUserId!)
            .order('created_at', ascending: false);

        final remoteTodos = (response as List)
            .map((json) => TodoModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        await _hiveService.saveAllTodos(remoteTodos);
      }

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

  Future<void> addTodo({
    required String title,
    String? description,
    String? fileUrl,
    String? fileName,
  }) async {
    if (isClosed) return;
    final userId = _currentUserId;
    if (userId == null) {
      emit(TodosError('User must be logged in to create a todo.'));
      return;
    }

    try {
      final newTodo = TodoModel(
        id: '',
        userId: userId,
        title: title,
        description: description,
        fileUrl: fileUrl,
        fileName: fileName,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

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
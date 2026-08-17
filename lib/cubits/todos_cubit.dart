import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/todo_model.dart';
import '../data/services/hive_service.dart';
import 'todos_state.dart';

class TodosCubit extends Cubit<TodosState> {
  final LocalStorageService _hiveService;

  TodosCubit(this._hiveService) : super(TodosInitial());

  Future<void> loadTodos() async {
    if (isClosed) return;
    emit(TodosLoading());
    try {
      final rawTodos = _hiveService.getTodos();
      final todos = rawTodos.map((e) => TodoModel.fromMap(e)).toList();
      
      if (isClosed) return;
      emit(TodosLoaded(todos));
    } catch (e) {
      if (isClosed) return;
      emit(TodosError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> addTodo(String title, String description) async {
    if (isClosed) return;
    try {
      await _hiveService.addTodo(title, description);
      
      // Reload updated local list
      await loadTodos();
    } catch (e) {
      if (isClosed) return;
      emit(TodosError('Failed to add task'));
    }
  }

  Future<void> deleteTodo(String id) async {
    if (isClosed) return;
    try {
      await _hiveService.deleteTodo(id);
      
      // Reload updated local list
      await loadTodos();
    } catch (e) {
      if (isClosed) return;
      emit(TodosError('Failed to delete task'));
    }
  }

  Future<void> toggleTodoStatus(String id) async {
    if (isClosed) return;
    try {
      await _hiveService.toggleTodo(id);
      
      // Reload updated local list
      await loadTodos();
    } catch (e) {
      if (isClosed) return;
      emit(TodosError('Failed to update task status'));
    }
  }
}
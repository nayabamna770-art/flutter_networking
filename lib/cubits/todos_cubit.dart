import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/todo_model.dart';
import '../data/services/api_service.dart';
import 'todos_state.dart';

class TodosCubit extends Cubit<TodosState> {
  final ApiService _apiService;

  TodosCubit(this._apiService) : super(TodosInitial());

  Future<void> loadTodos(String token) async {
    emit(TodosLoading());
    try {
      final todos = await _apiService.fetchTodos(token);
      emit(TodosLoaded(todos));
    } catch (e) {
      emit(TodosError(e.toString()));
    }
  }

  Future<void> addTodo(String token, String title) async {
    if (state is TodosLoaded) {
      final currentTodos = (state as TodosLoaded).todos;
      try {
        final newTodo = await _apiService.addTodo(token, title);
        emit(TodosLoaded([...currentTodos, newTodo]));
      } catch (e) {
        emit(TodosError('Failed to add todo'));
      }
    }
  }

  Future<void> deleteTodo(String token, String id) async {
    if (state is TodosLoaded) {
      final currentTodos = (state as TodosLoaded).todos;
      try {
        final success = await _apiService.deleteTodo(token, id);
        if (success) {
          final updatedTodos = currentTodos.where((t) => t.id != id).toList();
          emit(TodosLoaded(updatedTodos));
        }
      } catch (e) {
        emit(TodosError('Failed to delete todo'));
      }
    }
  }
}
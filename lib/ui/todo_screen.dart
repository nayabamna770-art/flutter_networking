// lib/ui/todo_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/todos_cubit.dart';
import '../cubits/todos_state.dart';
import 'app_style.dart';
import 'login_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TodosCubit>().loadTodos();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _titleController.clear();
                _descriptionController.clear();
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final description = _descriptionController.text.trim();
                if (title.isNotEmpty) {
                  context.read<TodosCubit>().addTodo(title, description);
                  _titleController.clear();
                  _descriptionController.clear();
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await context.read<AuthCubit>().signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppStyles.buildShaderText('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: CustomPaint(
        painter: WavesBackgroundPainter(
          primaryColor: AppStyles.primaryColor,
          secondaryColor: AppStyles.accentColor,
        ),
        child: SafeArea(
          child: BlocConsumer<TodosCubit, TodosState>(
            listener: (context, state) {
              if (state is TodosError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is TodosLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is TodosLoaded) {
                if (state.todos.isEmpty) {
                  return Center(
                    child: AppStyles.buildGlassContainer(
                      child: const Text(
                        'No tasks yet. Tap + to add one!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: state.todos.length,
                  itemBuilder: (context, index) {
                    final todo = state.todos[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: AppStyles.buildGlassContainer(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          leading: Checkbox(
                            value: todo.isCompleted,
                            activeColor: AppStyles.primaryColor,
                            onChanged: (_) {
                              context.read<TodosCubit>().toggleTodoStatus(
                                todo.id,
                              );
                            },
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              fontWeight: FontWeight.bold,
                              color: todo.isCompleted
                                  ? Colors.white54
                                  : Colors.white,
                            ),
                          ),
                          subtitle: todo.description.isNotEmpty
                              ? Text(
                                  todo.description,
                                  style: const TextStyle(color: Colors.white70),
                                )
                              : null,
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              context.read<TodosCubit>().deleteTodo(todo.id);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        backgroundColor: AppStyles.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

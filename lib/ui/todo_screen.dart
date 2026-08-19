import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../cubits/todos_cubit.dart';
import '../cubits/todos_state.dart';
import 'login_screen.dart';
import 'widgets/background_painter.dart';

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
    await Supabase.instance.client.auth.signOut();
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
        title: const Text('My Offline Tasks'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: CustomPaint(
        painter: HeaderBackgroundPainter(
          primaryColor: Colors.deepPurple,
          secondaryColor: Colors.purpleAccent,
        ),
        child: SafeArea(
          child: BlocConsumer<TodosCubit, TodosState>(
            listener: (context, state) {
              if (state is TodosError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
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
                  return const Center(
                    child: Text(
                      'No tasks yet. Tap + to add one!',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: state.todos.length,
                  itemBuilder: (context, index) {
                    final todo = state.todos[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: todo.isCompleted,
                          activeColor: Colors.deepPurple,
                          onChanged: (_) {
                            context
                                .read<TodosCubit>()
                                .toggleTodoStatus(todo.id);
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
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                        subtitle: todo.description.isNotEmpty
                            ? Text(todo.description)
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () {
                            context.read<TodosCubit>().deleteTodo(todo.id);
                          },
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
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
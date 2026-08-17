import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/todos_cubit.dart';
import '../cubits/todos_state.dart';
import 'widgets/background_painter.dart';

class TodosScreen extends StatefulWidget {
  final String token;

  const TodosScreen({super.key, required this.token});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TodosCubit>().loadTodos(widget.token);
  }

  @override
  void dispose() {
    _todoController.dispose();
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
          content: TextField(
            controller: _todoController,
            decoration: const InputDecoration(
              hintText: 'Enter task description...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = _todoController.text.trim();
                if (title.isNotEmpty) {
                  context.read<TodosCubit>().addTodo(widget.token, title);
                  _todoController.clear();
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          // 🎨 Custom Canvas Curved Header
          CustomPaint(
            size: Size(size.width, 220),
            painter: HeaderBackgroundPainter(
              primaryColor: Theme.of(context).colorScheme.primary,
              secondaryColor: Theme.of(context).colorScheme.tertiary,
            ),
          ),

          // 📱 Main Body
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Details
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "My Tasks",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Manage your daily workflow",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () {
                          // Logout logic/navigation back to Login
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // To-Do List Content Container
                Expanded(
                  child: BlocBuilder<TodosCubit, TodosState>(
                    builder: (context, state) {
                      if (state is TodosLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is TodosLoaded) {
                        if (state.todos.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No tasks yet!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: state.todos.length,
                          itemBuilder: (context, index) {
                            final todo = state.todos[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(
                                  todo.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    context.read<TodosCubit>().deleteTodo(
                                      widget.token,
                                      todo.id,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      } else if (state is TodosError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

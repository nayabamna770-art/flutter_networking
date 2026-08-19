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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyles.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            top: 28,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppStyles.buildHeaderTitle(
                'New Task',
                subtitle: 'What do you plan to complete?',
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Task Title',
                  prefixIcon: Icon(
                    Icons.check_circle_outline,
                    color: AppStyles.primaryViolet,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description (optional)',
                  prefixIcon: Icon(
                    Icons.notes_rounded,
                    color: AppStyles.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppStyles.buildPrimaryButton(
                  text: 'Save Task',
                  onPressed: () {
                    final title = _titleController.text.trim();
                    final description = _descriptionController.text.trim();
                    if (title.isNotEmpty) {
                      context.read<TodosCubit>().addTodo(title, description);
                      _titleController.clear();
                      _descriptionController.clear();
                      Navigator.pop(sheetContext);
                    }
                  },
                ),
              ),
            ],
          ),
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
        title: const Text('My Tasks ✨'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppStyles.surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppStyles.borderLight),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: AppStyles.textPrimary,
                size: 20,
              ),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ),
        ],
      ),
      body: CustomPaint(
        painter: VibrantMeshPainter(),
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
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppStyles.primaryViolet,
                  ),
                );
              }

              if (state is TodosLoaded) {
                if (state.todos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppStyles.primaryViolet.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.task_alt_rounded,
                            size: 52,
                            color: AppStyles.primaryViolet,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No active tasks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppStyles.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap the button below to add your first task',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppStyles.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  itemCount: state.todos.length,
                  itemBuilder: (context, index) {
                    final todo = state.todos[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: AppStyles.buildCardContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: 1.1,
                              child: Checkbox(
                                value: todo.isCompleted,
                                activeColor: AppStyles.accentAmber,
                                checkColor: AppStyles.primaryDark,
                                side: const BorderSide(
                                  color: AppStyles.textSecondary,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                onChanged: (_) {
                                  context.read<TodosCubit>().toggleTodoStatus(
                                    todo.id,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    todo.title,
                                    style: TextStyle(
                                      decoration: todo.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: todo.isCompleted
                                          ? AppStyles.textSecondary
                                          : AppStyles.textPrimary,
                                    ),
                                  ),
                                  if (todo.description.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      todo.description,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: todo.isCompleted
                                            ? AppStyles.textSecondary
                                                  .withValues(alpha: 0.6)
                                            : AppStyles.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                              onPressed: () {
                                context.read<TodosCubit>().deleteTodo(todo.id);
                              },
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTodoDialog,
        backgroundColor: AppStyles.primaryViolet,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: const Text(
          'New Task',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

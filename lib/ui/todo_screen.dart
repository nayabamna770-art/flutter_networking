// lib/ui/todo_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
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
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppStyles.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add New Task',
            style: TextStyle(color: AppStyles.textPrimary),
          ),
          content: TextField(
            controller: _taskController,
            autofocus: true,
            style: const TextStyle(color: AppStyles.textPrimary),
            decoration: const InputDecoration(
              hintText: 'What needs to be done?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _taskController.clear();
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppStyles.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryViolet,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final title = _taskController.text.trim();
                if (title.isNotEmpty) {
                  // Updated to use the state's existing _taskController
                  context.read<TodosCubit>().addTodo(title);
                  _taskController.clear();
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text(
                'Add Task',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: CustomPaint(
          painter: DynamicBackgroundPainter(),
          child: SafeArea(
            child: Column(
              children: [
                // Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppStyles.buildHeaderTitle(
                        'My Tasks 📝',
                        subtitle: 'Organize your daily routine',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: AppStyles.textSecondary,
                          size: 26,
                        ),
                        onPressed: () {
                          context.read<AuthCubit>().signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Todo List Builder
                Expanded(
                  child: BlocBuilder<TodosCubit, TodosState>(
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.task_alt_rounded,
                                  size: 64,
                                  color: AppStyles.textSecondary,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No tasks yet!',
                                  style: TextStyle(
                                    color: AppStyles.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ).animate().fade().scale(),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          itemCount: state.todos.length,
                          itemBuilder: (context, index) {
                            final todo = state.todos[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: AppStyles.buildCardContainer(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    context
                                        .read<TodosCubit>()
                                        .toggleTodoStatus(
                                          todo.id,
                                          todo.isCompleted,
                                        );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(
                                            context,
                                          ).size.height *
                                          0.01,
                                    ),
                                    child: Row(
                                      children: [
                                        Theme(
                                          data: ThemeData(
                                            unselectedWidgetColor:
                                                AppStyles.borderLight,
                                          ),
                                          child: Checkbox(
                                            value: todo.isCompleted,
                                            activeColor: AppStyles.primaryViolet,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            onChanged: (bool? newValue) {
                                              context
                                                  .read<TodosCubit>()
                                                  .toggleTodoStatus(
                                                    todo.id,
                                                    todo.isCompleted,
                                                  );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            todo.title,
                                            style: TextStyle(
                                              color: todo.isCompleted
                                                  ? AppStyles.textSecondary
                                                  : AppStyles.textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              decoration: todo.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.redAccent,
                                            size: 22,
                                          ),
                                          onPressed: () {
                                            context
                                                .read<TodosCubit>()
                                                .deleteTodo(todo.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                                .animate()
                                .fade(duration: 300.ms)
                                .slideY(begin: 0.1, end: 0);
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ],
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
      ),
    );
  }
}
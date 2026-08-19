// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'cubits/auth_cubit.dart' as app_auth;
import 'cubits/todos_cubit.dart';
import 'data/services/hive_service.dart';
import 'ui/app_style.dart';
import 'ui/login_screen.dart';
import 'ui/todo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage
  await Hive.initFlutter();
  await Hive.openBox('users');
  await Hive.openBox('todos');

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://pbogqvmzratfdbjfxdhi.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBib2dxdm16cmF0ZmRiamZ4ZGhpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcwMzE0MDksImV4cCI6MjEwMjYwNzQwOX0.vMfbem8c964MR-aaUZ4LmSwHnbMV1bfKM9nk8sU03kg',
  );

  final hiveService = LocalStorageService();

  runApp(MyApp(hiveService: hiveService));
}

class MyApp extends StatelessWidget {
  final LocalStorageService hiveService;

  const MyApp({super.key, required this.hiveService});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MultiBlocProvider(
      providers: [
        BlocProvider<app_auth.AuthCubit>(
          create: (context) => app_auth.AuthCubit(hiveService),
        ),
        BlocProvider<TodosCubit>(create: (context) => TodosCubit(hiveService)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppStyles.theme,
        home: session != null ? const TodoScreen() : const LoginScreen(),
      ),
    );
  }
}

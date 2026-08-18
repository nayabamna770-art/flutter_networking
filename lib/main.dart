import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:hive_flutter/hive_flutter.dart';
import 'cubits/auth_cubit.dart';
import 'cubits/todos_cubit.dart';
import 'data/services/hive_service.dart';
import 'ui/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://pbogqvmzratfdbjfxdhi.supabase.co/rest/v1/',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBib2dxdm16cmF0ZmRiamZ4ZGhpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcwMzE0MDksImV4cCI6MjEwMjYwNzQwOX0.vMfbem8c964MR-aaUZ4LmSwHnbMV1bfKM9nk8sU03kg',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LocalStorageService localStorageService = LocalStorageService();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(localStorageService)),
        BlocProvider(create: (_) => TodosCubit(localStorageService)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Networking App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

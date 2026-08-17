import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'cubits/auth_cubit.dart';
import 'cubits/todos_cubit.dart';
import 'data/services/hive_service.dart';
import 'ui/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Open boxes matching the exact keys used in LocalStorageService
  await Hive.openBox('users');
  await Hive.openBox('todos');
  await Hive.openBox('session');

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

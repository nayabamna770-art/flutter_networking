import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/auth_cubit.dart' as app_auth;
import 'data/services/hive_service.dart';
import 'ui/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = LocalStorageService();

  runApp(MyApp(hiveService: hiveService));
}

class MyApp extends StatelessWidget {
  final LocalStorageService hiveService;

  const MyApp({super.key, required this.hiveService});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<app_auth.AuthCubit>(
      create: (context) => app_auth.AuthCubit(hiveService),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      ),
    );
  }
}
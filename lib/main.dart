import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'cubits/auth_cubit.dart';
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
    return BlocProvider(
      create: (context) => AuthCubit(hiveService),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      ),
    );
  }
}
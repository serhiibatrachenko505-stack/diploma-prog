import 'package:flutter/material.dart';
import 'package:diploma_work_prog/data/db/app_db.dart';
import 'package:diploma_work_prog/data/db/db_seeder.dart';
import 'package:diploma_work_prog/ui/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDb.instance.db;

  await DbSeeder.instance.seed();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
      ),

      home: LoginScreen(),
    );
  }
}
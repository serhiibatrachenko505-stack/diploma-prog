import 'package:diploma_work_prog/data/db/app_db.dart';
import 'package:diploma_work_prog/data/db/db_seeder.dart';
import 'package:diploma_work_prog/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';

/// Application entry point.
///
/// Initializes Flutter bindings, opens the local database,
/// runs database seeding, and starts the root widget of the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDb.instance.db;

  await DbSeeder.instance.seed();

  runApp(const MyApp());
}

/// Root widget of the application.
///
/// Configures the main Material app, theme settings,
/// and the initial screen shown to the user.
class MyApp extends StatelessWidget {
  /// Creates the root application widget.
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
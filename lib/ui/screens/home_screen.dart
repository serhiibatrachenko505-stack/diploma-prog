import 'package:diploma_work_prog/models/user.dart';
import 'package:diploma_work_prog/ui/screens/cabinet_screen.dart';
import 'package:diploma_work_prog/ui/screens/macro_calculator_screen.dart';
import 'package:diploma_work_prog/ui/screens/main_vitamin_calculator_screen.dart';
import 'package:diploma_work_prog/ui/screens/meal_plan_generator_screen.dart';
import 'package:flutter/material.dart';

/// Main application screen shown after successful login.
///
/// Acts as the entry point to the authenticated part of the app
/// and provides access to the main functional sections.
///
/// The screen keeps the current [UserModel] in its local state so that
/// child tabs can update user data (for example assigned meal plan,
/// username, or email) and keep all tabs synchronized.
class HomeScreen extends StatefulWidget {
  /// Currently authenticated user displayed and used across the home flow.
  final UserModel user;

  /// Creates the main screen for the provided authenticated [user].
  const HomeScreen({super.key, required this.user});

  /// Creates the mutable state for [HomeScreen].
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  /// Updates the locally stored authenticated user.
  ///
  /// This callback is passed to child screens so they can notify the home
  /// screen when user-related data changes.
  void _handleUserUpdated(UserModel updatedUser) {
    setState(() => _user = updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const MacroCalculatorScreen(),
      const MainVitaminCalculatorScreen(),
      MealPlanGeneratorScreen(
        user: _user,
        onUserUpdated: _handleUserUpdated,
      ),
      CabinetScreen(
        user: _user,
        onUserUpdated: _handleUserUpdated,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            label: 'CC',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist_outlined),
            label: 'Vitamins',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            label: 'Meal Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Cabinet',
          ),
        ],
      ),
    );
  }
}
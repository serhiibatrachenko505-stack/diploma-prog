import 'package:flutter/material.dart';
import 'package:diploma_work_prog/models/user.dart';
import 'package:diploma_work_prog/ui/screens/macro_calculator_screen.dart';
import 'package:diploma_work_prog/ui/screens/main_vitamin_calculator_screen.dart';
import 'package:diploma_work_prog/ui/screens/cabinet_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  void _comingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const MacroCalculatorScreen(),
      const MainVitaminCalculatorScreen(),
      const _ComingSoonBody(),
      CabinetScreen(user: widget.user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),

      body: pages[_index],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) {
          if (i == 2) {
            _comingSoon();
          }

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
            label: 'Plan',
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

class _ComingSoonBody extends StatelessWidget {
  const _ComingSoonBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Coming soon...',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
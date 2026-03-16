import 'package:diploma_work_prog/ui/screens/day_vitamin_calculator_screen.dart';
import 'package:diploma_work_prog/ui/screens/single_vitamin_calculator_screen.dart';
import 'package:diploma_work_prog/ui/widgets/primary_button.dart';
import 'package:flutter/material.dart';

/// Entry screen for the vitamin calculation module.
///
/// Allows the user to choose between the available vitamin
/// calculation modes, such as single-product mode and daily mode.
class MainVitaminCalculatorScreen extends StatelessWidget {
  /// Creates the main vitamin calculator selection screen.
  const MainVitaminCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitamin calculator'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose calculator mode',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              PrimaryButton(
                text: 'Single product',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SingleVitaminCalculatorScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              PrimaryButton(
                text: 'Daily mode',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DayVitaminCalculatorScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              const Text(
                'Tip: In daily mode, add multiple products and then calculate.',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
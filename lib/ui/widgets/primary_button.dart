import 'package:flutter/material.dart';

/// Reusable primary action button used across the application.
///
/// Displays the provided text and triggers the given callback
/// when pressed.
class PrimaryButton extends StatelessWidget {
  /// Text displayed on the button.
  final String text;
  /// Callback executed when the button is pressed.
  final VoidCallback onPressed;

  /// Creates a primary button with the given label and action.
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        child: Text(text)
    );
  }
}

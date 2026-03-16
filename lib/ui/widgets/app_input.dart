import 'package:flutter/material.dart';

/// Reusable text input widget used across the application forms.
///
/// Supports plain text input, password visibility toggle,
/// custom keyboard type, and optional validation logic.
class AppInput extends StatefulWidget {
  /// Placeholder text displayed inside the input field.
  final String hint;
  /// Controller used to read and manage the current input value.
  final TextEditingController controller;
  /// Keyboard type used for this input field.
  final TextInputType keyboardType;
  /// Whether the input text should be hidden, for example for passwords.
  final bool obscure;
  /// Optional validation function used by form validation.
  final String? Function(String?)? validator;

  /// Creates a reusable input widget with optional password behavior
  /// and validation support.
  const AppInput({
    super.key,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.validator,
  });

  /// Creates the mutable state for [AppInput].
  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscure,
      style: const TextStyle(color: Colors.black87),
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hint,
        suffixIcon: widget.obscure
            ? IconButton(
          onPressed: () {
            if (!mounted) return;
            setState(() => _obscure = !_obscure);
          },
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
        )
            : null,
      ),
    );
  }
}
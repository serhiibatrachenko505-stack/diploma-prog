import 'package:flutter/material.dart';

class AppInput extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscure;
  final String? Function(String?)? validator;

  const AppInput({
    super.key,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.validator,
  });

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
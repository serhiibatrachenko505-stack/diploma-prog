import 'package:diploma_work_prog/services/auth_service.dart';
import 'package:diploma_work_prog/ui/widgets/app_input.dart';
import 'package:diploma_work_prog/ui/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService auth;

  RegisterScreen({
    super.key,
    AuthService? auth
  }) : auth = auth ?? AuthService();

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late final AuthService _auth;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _auth = widget.auth;
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validateUsername(String? v) {
    final value = (v ?? '').trim();

    if(value.isEmpty) return 'Username cannot be empty.';
    return null;
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();

    if(value.isEmpty) return 'Email cannot be empty.';
    if(!value.contains('@') || !value.contains('.')){
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    final value = (v ?? '');

    if(value.isEmpty) return 'Password cannot be empty.';
    if(value.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  String? _validateConfirm(String? v) {
    final value = (v ?? '');

    if (value.isEmpty) return 'Confirm your password.';
    if (value != _passwordCtrl.text) return 'Passwords do not match.';
    return null;
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if(!isValid) return;

    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _isLoading = true);

    final res = await _auth.register(
        username: username,
        email: email,
        password: password
    );

    if(!mounted) return;

    setState(() => _isLoading = false);
    
    if(res.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Registration successful. Please log in.')
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? 'Registration failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),

      body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    const Text(
                      'Create account',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 28),

                    AppInput(
                        key: const Key('reg_username'),
                        hint: 'Username',
                        controller: _usernameCtrl,
                        keyboardType: TextInputType.text,
                        validator: _validateUsername,
                    ),

                    const SizedBox(height: 16),

                    AppInput(
                        key: const Key('reg_email'),
                        hint: 'Email',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.text,
                        validator: _validateEmail,
                    ),

                    const SizedBox(height: 16),

                    AppInput(
                        key: const Key('reg_password'),
                        hint: 'Password',
                        controller: _passwordCtrl,
                        obscure: true,
                        validator: _validatePassword,
                    ),

                    const SizedBox(height: 16),

                    AppInput(
                        key: const Key('reg_confirm'),
                        hint: 'Confirm password',
                        controller: _confirmCtrl,
                        obscure: true,
                        validator: _validateConfirm,
                    ),

                    const SizedBox(height: 24),

                    PrimaryButton(
                        text: _isLoading ? 'Creating...' : 'Register',
                        onPressed: _isLoading ? () {} : _submit,
                    ),

                    const SizedBox(height: 14),

                    TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Already have an account? Log in'),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }
}
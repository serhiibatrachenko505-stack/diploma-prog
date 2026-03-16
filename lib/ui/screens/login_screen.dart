import 'package:diploma_work_prog/models/user.dart';
import 'package:diploma_work_prog/services/auth_service.dart';
import 'package:diploma_work_prog/ui/screens/home_screen.dart';
import 'package:diploma_work_prog/ui/screens/register_screen.dart';
import 'package:diploma_work_prog/ui/widgets/app_input.dart';
import 'package:diploma_work_prog/ui/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final AuthService auth;

  LoginScreen({super.key, AuthService? auth}) : auth = auth ?? AuthService();

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late final AuthService _auth;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth;
  }

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validateLogin(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Enter username or email.';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Enter password.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if(!isValid) return;

    final login = _loginCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _isLoading = true);

    final res = await _auth.login(
        login: login,
        password: password
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if(res.ok && res.user != null){
      final UserModel user = res.user!;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(user: user),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? 'Login failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                          ),

                          const SizedBox(height: 28),

                          AppInput(
                            key: const Key('login_login'),
                            hint: 'Username or Email',
                            controller: _loginCtrl,
                            keyboardType: TextInputType.text,
                            validator: _validateLogin,
                          ),

                          const SizedBox(height: 16),

                          AppInput(
                            key: const Key('login_password'),
                            hint: 'Password',
                            controller: _passwordCtrl,
                            obscure: true,
                            validator: _validatePassword,
                          ),

                          const SizedBox(height: 24),

                          PrimaryButton(
                            text: _isLoading ? 'Logging in...' : 'Login',
                            onPressed: _isLoading ? () {} : _submit,
                          ),

                          const SizedBox(height: 14),

                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegisterScreen(auth: _auth),
                                ),
                              );
                            },
                            child: const Text("Don't have an account? Register"),
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
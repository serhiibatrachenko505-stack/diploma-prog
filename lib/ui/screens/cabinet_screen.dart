import 'package:diploma_work_prog/data/dao/user_dao.dart';
import 'package:diploma_work_prog/data/db/app_db.dart';
import 'package:diploma_work_prog/models/user.dart';
import 'package:diploma_work_prog/services/auth_service.dart';
import 'package:diploma_work_prog/ui/widgets/app_input.dart';
import 'package:diploma_work_prog/ui/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class CabinetScreen extends StatefulWidget {
  final UserModel user;
  final UserDao userDao;
  final AuthService authService;

  CabinetScreen({
    super.key,
    required this.user,
    UserDao? userDao,
    AuthService? authService,
  })  : userDao = userDao ?? UserDao(),
        authService = authService ?? AuthService();

  @override
  State<CabinetScreen> createState() => _CabinetScreenState();
}

class _CabinetScreenState extends State<CabinetScreen> {
  late UserModel _user;

  String? _mealPlanDescription;
  bool _isLoadingPlan = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;

    _loadMealPlanDescription();
  }

  Future<void> _loadMealPlanDescription() async {
    final planId = _user.mealPlanId;

    if (planId == null) {
      setState(() => _mealPlanDescription = null);
      return;
    }

    setState(() => _isLoadingPlan = true);

    try {
      final db = await AppDb.instance.db;

      final rows = await db.query(
        'meal_plans',
        columns: ['description'],
        where: 'id = ?',
        whereArgs: [planId],
        limit: 1,
      );

      if (!mounted) return;

      if (rows.isEmpty) {
        setState(() => _mealPlanDescription = null);
      } else {
        setState(() => _mealPlanDescription = rows.first['description'] as String?);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _mealPlanDescription = null);
    } finally {
      if (mounted) {
        setState(() => _isLoadingPlan = false);
      }
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<String?> _askText({
    required String title,
    required String hint,
    String initialValue = '',
  }) async {
    return showDialog<String?>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: initialValue);

        return AlertDialog(
          title: Text(title),
          content: AppInput(
            hint: hint,
            controller: ctrl,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeUsername() async {
    if (_user.id == null) {
      _showSnack('Cannot update username: user id is null.');
      return;
    }

    final newValue = await _askText(
      title: 'Change username',
      hint: 'New username',
      initialValue: _user.username,
    );

    if (newValue == null) return;
    final trimmed = newValue.trim();
    if (trimmed.isEmpty) {
      _showSnack('Username cannot be empty.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = await widget.userDao.updateUserName(_user, trimmed);

      if (!mounted) return;
      setState(() => _user = updated);
      _showSnack('Username updated.');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changeFullName() async {
    if (_user.id == null) {
      _showSnack('Cannot update full name: user id is null.');
      return;
    }

    final newValue = await _askText(
      title: 'Change full name',
      hint: 'Full name (leave empty to remove)',
      initialValue: _user.fullName ?? '',
    );

    if (newValue == null) return;

    setState(() => _isSaving = true);

    try {
      final updated = await widget.userDao.updateFullName(_user, newValue);

      if (!mounted) return;
      setState(() => _user = updated);
      _showSnack('Full name updated.');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changeEmail() async {
    if (_user.id == null) {
      _showSnack('Cannot update email: user id is null.');
      return;
    }

    final newValue = await _askText(
      title: 'Change email',
      hint: 'New email',
      initialValue: _user.email,
    );

    if (newValue == null) return;
    final trimmed = newValue.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      _showSnack('Please enter a valid email.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = await widget.userDao.updateEmail(_user, trimmed);

      if (!mounted) return;
      setState(() => _user = updated);
      _showSnack('Email updated.');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    if (_user.id == null) {
      _showSnack('Cannot change password: user id is null.');
      return;
    }

    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Change password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppInput(
                hint: 'Current password',
                controller: oldCtrl,
                obscure: true,
              ),
              const SizedBox(height: 10),
              AppInput(
                hint: 'New password',
                controller: newCtrl,
                obscure: true,
              ),
              const SizedBox(height: 10),
              AppInput(
                hint: 'Confirm new password',
                controller: confirmCtrl,
                obscure: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    final shouldSave = ok ?? false;

    oldCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();

    if (!shouldSave) return;

    setState(() => _isSaving = true);

    try {
      final res = await widget.authService.changePassword(
        userId: _user.id!,
        oldPassword: oldCtrl.text,
        newPassword: newCtrl.text,
        confirmNewPassword: confirmCtrl.text,
      );

      if (!mounted) return;

      if (res.ok && res.user != null) {
        setState(() => _user = res.user!);
        _showSnack('Password updated.');
      } else {
        _showSnack(res.error ?? 'Password update failed.');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullNameText = (_user.fullName == null || _user.fullName!.trim().isEmpty)
        ? '-'
        : _user.fullName!.trim();

    final planText = (_user.mealPlanId == null)
        ? 'Not set'
        : (_isLoadingPlan
        ? 'Loading...'
        : (_mealPlanDescription ?? 'Plan #${_user.mealPlanId}'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cabinet'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              _infoRow('Username:', _user.username),
              _infoRow('Full name:', fullNameText),
              _infoRow('Email:', _user.email),
              _infoRow('Diet plan:', planText),

              const SizedBox(height: 18),

              const Text(
                'Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              PrimaryButton(
                text: 'Change username',
                onPressed: _isSaving ? () {} : _changeUsername,
              ),
              const SizedBox(height: 10),

              PrimaryButton(
                text: 'Change full name',
                onPressed: _isSaving ? () {} : _changeFullName,
              ),
              const SizedBox(height: 10),

              PrimaryButton(
                text: 'Change email',
                onPressed: _isSaving ? () {} : _changeEmail,
              ),
              const SizedBox(height: 10),

              PrimaryButton(
                text: 'Change password',
                onPressed: _isSaving ? () {} : _changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
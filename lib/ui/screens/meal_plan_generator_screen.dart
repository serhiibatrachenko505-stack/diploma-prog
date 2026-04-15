import 'package:diploma_work_prog/models/meal_plan.dart';
import 'package:diploma_work_prog/models/user.dart';
import 'package:diploma_work_prog/services/meal_plan_generator_service.dart';
import 'package:diploma_work_prog/ui/widgets/app_input.dart';
import 'package:diploma_work_prog/ui/widgets/primary_button.dart';
import 'package:flutter/material.dart';

/// Screen that collects questionnaire answers and generates a meal plan.
///
/// The screen uses a rule-based service to select one of the seeded
/// meal plans, saves it for the current user, and displays the result.
class MealPlanGeneratorScreen extends StatefulWidget {
  /// Currently authenticated user for whom the meal plan is generated.
  final UserModel user;

  /// Callback invoked when the user object is updated after saving.
  ///
  /// This allows parent widgets to keep the latest user state,
  /// including the newly assigned `mealPlanId`.
  final ValueChanged<UserModel> onUserUpdated;

  /// Service used to generate and save a meal plan.
  final MealPlanGeneratorService service;

  /// Creates the meal plan generator screen.
  ///
  /// An optional custom [service] may be injected for testing.
  MealPlanGeneratorScreen({
    super.key,
    required this.user,
    required this.onUserUpdated,
    MealPlanGeneratorService? service,
  }) : service = service ?? MealPlanGeneratorService();

  /// Creates the mutable state for [MealPlanGeneratorScreen].
  @override
  State<MealPlanGeneratorScreen> createState() =>
      _MealPlanGeneratorScreenState();
}

class _MealPlanGeneratorScreenState extends State<MealPlanGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  late UserModel _user;

  Gender _gender = Gender.male;
  ActivityLevel _activityLevel = ActivityLevel.medium;
  MealGoal _goal = MealGoal.maintenance;

  bool _isDonor = false;
  bool _prefersLowCarb = false;
  bool _hasLittleTimeToCook = false;
  bool _officeLifestyle = false;

  bool _isSaving = false;

  MealPlan? _generatedPlan;
  List<String> _notes = const [];

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _genderLabel(Gender value) {
    switch (value) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
    }
  }

  String _activityLabel(ActivityLevel value) {
    switch (value) {
      case ActivityLevel.low:
        return 'Low';
      case ActivityLevel.medium:
        return 'Medium';
      case ActivityLevel.high:
        return 'High';
    }
  }

  String _goalLabel(MealGoal value) {
    switch (value) {
      case MealGoal.weightLoss:
        return 'Weight loss';
      case MealGoal.maintenance:
        return 'Weight maintenance';
      case MealGoal.muscleGain:
        return 'Muscle gain';
    }
  }

  Future<void> _generatePlan() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    final age = int.parse(_ageCtrl.text.trim());
    final weight = double.parse(_weightCtrl.text.trim());
    final height = double.parse(_heightCtrl.text.trim());

    final answers = MealPlanSurveyAnswers(
      gender: _gender,
      age: age,
      weightKg: weight,
      heightCm: height,
      activityLevel: _activityLevel,
      goal: _goal,
      isDonor: _isDonor,
      prefersLowCarb: _prefersLowCarb,
      hasLittleTimeToCook: _hasLittleTimeToCook,
      officeLifestyle: _officeLifestyle,
    );

    setState(() => _isSaving = true);

    try {
      final res = await widget.service.assignPlan(
        user: _user,
        answers: answers,
      );

      if (!mounted) return;

      if (res.ok && res.user != null && res.plan != null) {
        setState(() {
          _user = res.user!;
          _generatedPlan = res.plan;
          _notes = res.notes;
        });

        widget.onUserUpdated(_user);
        _showSnack('Meal plan generated and saved.');
      } else {
        _showSnack(res.error ?? 'Meal plan generation failed.');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _validateAge(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Age is required.';

    final parsed = int.tryParse(text);
    if (parsed == null) return 'Enter a valid integer age.';
    if (parsed < 10 || parsed > 120) return 'Age must be between 10 and 120.';

    return null;
  }

  String? _validateWeight(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Weight is required.';

    final parsed = double.tryParse(text);
    if (parsed == null) return 'Enter a valid weight.';
    if (parsed <= 0 || parsed > 500) return 'Weight must be between 1 and 500 kg.';

    return null;
  }

  String? _validateHeight(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Height is required.';

    final parsed = double.tryParse(text);
    if (parsed == null) return 'Enter a valid height.';
    if (parsed < 80 || parsed > 250) return 'Height must be between 80 and 250 cm.';

    return null;
  }

  Widget _buildResultCard() {
    final plan = _generatedPlan;

    if (plan == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generated plan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            plan.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(plan.description),
          if (_notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Additional notes:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            ..._notes.map(
                  (note) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $note'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Meal Plan Generator',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Answer the questionnaire and the app will assign one of the available meal plans.',
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<Gender>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                ),
                items: Gender.values
                    .map(
                      (value) => DropdownMenuItem(
                    value: value,
                    child: Text(_genderLabel(value)),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _gender = value);
                },
              ),
              const SizedBox(height: 12),

              AppInput(
                hint: 'Age',
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                validator: _validateAge,
              ),
              const SizedBox(height: 12),

              AppInput(
                hint: 'Weight (kg)',
                controller: _weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateWeight,
              ),
              const SizedBox(height: 12),

              AppInput(
                hint: 'Height (cm)',
                controller: _heightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateHeight,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<ActivityLevel>(
                initialValue: _activityLevel,
                decoration: const InputDecoration(
                  labelText: 'Activity level',
                ),
                items: ActivityLevel.values
                    .map(
                      (value) => DropdownMenuItem(
                    value: value,
                    child: Text(_activityLabel(value)),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _activityLevel = value);
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<MealGoal>(
                initialValue: _goal,
                decoration: const InputDecoration(
                  labelText: 'Main goal',
                ),
                items: MealGoal.values
                    .map(
                      (value) => DropdownMenuItem(
                    value: value,
                    child: Text(_goalLabel(value)),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _goal = value);
                },
              ),
              const SizedBox(height: 12),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('I am a donor'),
                value: _isDonor,
                onChanged: (value) {
                  setState(() => _isDonor = value);
                },
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('I prefer a low-carb approach'),
                value: _prefersLowCarb,
                onChanged: (value) {
                  setState(() => _prefersLowCarb = value);
                },
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('I have little time for cooking'),
                value: _hasLittleTimeToCook,
                onChanged: (value) {
                  setState(() => _hasLittleTimeToCook = value);
                },
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('I have a mostly office / sedentary lifestyle'),
                value: _officeLifestyle,
                onChanged: (value) {
                  setState(() => _officeLifestyle = value);
                },
              ),

              const SizedBox(height: 16),

              PrimaryButton(
                text: _isSaving ? 'Generating...' : 'Generate plan',
                onPressed: _isSaving ? () {} : _generatePlan,
              ),

              const SizedBox(height: 16),

              if (_isSaving) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 16),
              ],

              _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }
}
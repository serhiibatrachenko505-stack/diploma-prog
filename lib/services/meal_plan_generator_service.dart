import 'package:diploma_work_prog/data/dao/meal_plan_dao.dart';
import 'package:diploma_work_prog/data/dao/user_dao.dart';
import 'package:diploma_work_prog/models/meal_plan.dart';
import 'package:diploma_work_prog/models/user.dart';

/// Supported gender values used in the meal plan questionnaire.
enum Gender {
  /// Male gender option.
  male,

  /// Female gender option.
  female,
}

/// Supported activity levels used in the meal plan questionnaire.
enum ActivityLevel {
  /// Low physical activity level.
  low,

  /// Medium physical activity level.
  medium,

  /// High physical activity level.
  high,
}

/// Supported main goals used for meal plan selection.
enum MealGoal {
  /// Goal focused on losing body weight.
  weightLoss,

  /// Goal focused on maintaining current body weight.
  maintenance,

  /// Goal focused on gaining muscle mass.
  muscleGain,
}

/// Stores the questionnaire answers used for meal plan generation.
///
/// The current version of the generator uses a rule-based approach:
/// answers are matched against simple business rules and one of the
/// existing seeded meal plans is selected.
class MealPlanSurveyAnswers {
  /// Gender selected by the user.
  final Gender gender;

  /// Age of the user in full years.
  final int age;

  /// Current body weight in kilograms.
  final double weightKg;

  /// Current height in centimeters.
  final double heightCm;

  /// Current physical activity level.
  final ActivityLevel activityLevel;

  /// Main user goal for the generated meal plan.
  final MealGoal goal;

  /// Whether the user marked themselves as a blood donor.
  final bool isDonor;

  /// Whether the user prefers a low-carb approach.
  final bool prefersLowCarb;

  /// Whether the user has little time for cooking.
  final bool hasLittleTimeToCook;

  /// Whether the user has a mostly office / sedentary lifestyle.
  final bool officeLifestyle;

  /// Creates a questionnaire answer object.
  const MealPlanSurveyAnswers({
    required this.gender,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.activityLevel,
    required this.goal,
    required this.isDonor,
    required this.prefersLowCarb,
    required this.hasLittleTimeToCook,
    required this.officeLifestyle,
  });
}

/// Generates and assigns meal plans to users.
///
/// The service reads available meal plans from the database, determines
/// the most appropriate plan using questionnaire answers, saves the
/// selected plan identifier for the user, and returns the updated state.
class MealPlanGeneratorService {
  /// DAO used to read meal plans from the database.
  final MealPlanDao mealPlanDao;

  /// DAO used to update the assigned meal plan for the user.
  final UserDao userDao;

  /// Creates a meal plan generator service.
  ///
  /// Optional custom DAO instances may be injected for testing.
  MealPlanGeneratorService({
    MealPlanDao? mealPlanDao,
    UserDao? userDao,
  })  : mealPlanDao = mealPlanDao ?? MealPlanDao(),
        userDao = userDao ?? UserDao();

  /// Generates a meal plan for the provided [user] based on [answers].
  ///
  /// The method:
  /// 1. determines the best matching seeded meal plan;
  /// 2. stores its identifier in `users.meal_plan_id`;
  /// 3. returns the updated [UserModel], selected [MealPlan],
  ///    and additional recommendation notes.
  ///
  /// Returns a record with:
  /// - `ok` — `true` if generation and saving succeeded;
  /// - `error` — an error message if the operation failed;
  /// - `user` — updated user with the selected meal plan id;
  /// - `plan` — selected meal plan;
  /// - `notes` — additional recommendation notes for the user.
  Future<({
  bool ok,
  String? error,
  UserModel? user,
  MealPlan? plan,
  List<String> notes,
  })> assignPlan({
    required UserModel user,
    required MealPlanSurveyAnswers answers,
  }) async {
    if (user.id == null) {
      return (
      ok: false,
      error: 'Cannot assign meal plan: user id is null.',
      user: null as UserModel?,
      plan: null as MealPlan?,
      notes: const <String>[],
      );
    }

    try {
      final plan = await _choosePlan(answers);

      final updatedRows = await userDao.setMealPlan(user.id!, plan.id);
      if (updatedRows != 1) {
        return (
        ok: false,
        error: 'Meal plan saving failed.',
        user: null as UserModel?,
        plan: null as MealPlan?,
        notes: const <String>[],
        );
      }

      final updatedUser = user.copyWith(mealPlanId: plan.id);
      final notes = _buildNotes(answers);

      return (
      ok: true,
      error: null,
      user: updatedUser,
      plan: plan,
      notes: notes,
      );
    } catch (e) {
      return (
      ok: false,
      error: 'Meal plan generation failed: $e',
      user: null as UserModel?,
      plan: null as MealPlan?,
      notes: const <String>[],
      );
    }
  }

  /// Chooses the most suitable meal plan for the provided [answers].
  ///
  /// The current implementation uses simple business rules and maps
  /// questionnaire outcomes to one of the seeded reference plans.
  Future<MealPlan> _choosePlan(MealPlanSurveyAnswers answers) async {
    if (answers.goal == MealGoal.muscleGain) {
      return _requirePlanByPrefix('Muscle gain plan');
    }

    if (answers.prefersLowCarb) {
      return _requirePlanByPrefix('Low-carb plan');
    }

    if (answers.goal == MealGoal.weightLoss) {
      return _requirePlanByPrefix('Weight loss plan');
    }

    if (answers.hasLittleTimeToCook || answers.officeLifestyle) {
      return _requirePlanByPrefix('Simple office plan');
    }

    return _requirePlanByPrefix('Weight maintenance plan');
  }

  /// Loads a meal plan whose description starts with [prefix].
  ///
  /// Throws a [StateError] if the required seeded plan is missing.
  Future<MealPlan> _requirePlanByPrefix(String prefix) async {
    final plan = await mealPlanDao.findByDescriptionPrefix(prefix);

    if (plan == null) {
      throw StateError('Required meal plan not found: $prefix');
    }

    return plan;
  }

  /// Builds additional human-readable notes for the generated result.
  ///
  /// These notes do not affect plan selection, but provide extra guidance
  /// based on the questionnaire answers.
  List<String> _buildNotes(MealPlanSurveyAnswers answers) {
    final notes = <String>[];

    if (answers.isDonor) {
      notes.add(
        'Because you marked yourself as a donor, monitor iron intake and consider consulting a healthcare professional when adjusting your diet.',
      );
    }

    if (answers.goal == MealGoal.weightLoss &&
        answers.activityLevel == ActivityLevel.high) {
      notes.add(
        'With high activity and a weight-loss goal, avoid an excessive calorie deficit.',
      );
    }

    if (answers.hasLittleTimeToCook || answers.officeLifestyle) {
      notes.add(
        'Try to keep regular meals and prepare simple snacks in advance to avoid random overeating.',
      );
    }

    if (answers.age < 18) {
      notes.add(
        'For users under 18, major nutrition changes should be reviewed with a parent or healthcare specialist.',
      );
    }

    return notes;
  }
}
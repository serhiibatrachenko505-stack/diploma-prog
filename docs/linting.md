# Linting Guide

## 1. General Information

This document describes the linting and static analysis configuration used in the Diploma Work Prog project.

The project is implemented in Flutter/Dart, so linting is based on the standard Dart/Flutter static analyzer and the `flutter_lints` rule set. This approach helps maintain consistent code style, detect common mistakes before runtime, improve readability, and increase maintainability of the project structure.

---

## 2. Selected Linter

The project uses:
- Dart/Flutter static analyzer
- `flutter_lints`

This solution was selected because it is the standard and recommended linting approach for Flutter applications. It integrates well with Flutter tooling, works both from the command line and inside IDEs, and supports configuration through `analysis_options.yaml`.

---

## 3. Why This Linter Was Chosen

The selected linting approach is well suited for this project because the application is built with Flutter and structured into several logical layers such as data access, services, models, and UI screens.

The most important code quality aspects for this project are:
- consistent code style;
- clear import structure;
- improved readability;
- easier maintenance of DAO, service, and UI layers;
- prevention of common coding mistakes;
- stronger type safety.

Using the built-in analyzer together with `flutter_lints` makes it possible to apply project-wide rules without introducing third-party tools that are not directly related to the Flutter ecosystem.

---

## 4. Linting Configuration

The linting configuration is stored in the root-level file `analysis_options.yaml`.

The project uses the recommended Flutter lint rules and extends them with additional checks. The configuration includes:
- the `flutter_lints` rule set;
- exclusion of generated or service directories from analysis;
- stricter language checks for type safety;
- additional rules for style and maintainability.

The current configuration is focused on practical use in the project and includes checks such as:
- avoiding debug prints in application code;
- preferring consistent quote style;
- requiring explicit return types;
- checking import ordering;
- enabling stricter type analysis.

---

## 5. Main Rules Used in the Project

The project uses both the default rules from `flutter_lints` and several additional rules configured in `analysis_options.yaml`.

Examples of the enabled rules:
- `avoid_print` — discourages using `print()` in production code;
- `prefer_single_quotes` — enforces a more consistent string style;
- `always_declare_return_types` — improves readability by requiring explicit return types;
- `directives_ordering` — checks correct grouping and sorting of import directives;
- `strict-casts` — enables stricter checks for unsafe casts;
- `strict-raw-types` — discourages the use of raw generic types without explicit type arguments.

These rules were selected because they improve consistency, reduce ambiguity, and help keep the code base easier to read and maintain.

---

## 6. Ignored Files and Directories

Some directories should not be analyzed because they are generated automatically or are not intended for manual editing.

The following directories are excluded from analysis:
- `build/**`
- `.dart_tool/**`

This exclusion keeps linting focused on the actual project source code and prevents noise caused by generated artifacts.

---

## 7. How to Run the Linter

The main command used to run linting in this project is:

```bash
flutter analyze
```

This command performs static analysis of the Flutter project and reports errors, warnings, and lint information messages.

An optional automatic fix command can also be used in some cases:

```bash
dart fix --apply
```

This command can automatically apply some safe fixes suggested by the analyzer.

---

## 8. Linting Results in This Project

After configuring the analyzer rules, the project was checked with `flutter analyze`.

The initial run reported 20 issues. All of them were related to `directives_ordering`, meaning incorrect ordering of import directives.

After fixing the import ordering problems in the affected files, the analyzer reported 0 issues.

This means:
- initial issues: 20
- remaining issues after fixes: 0
- fixed issues: 20

Therefore, 20 out of 20 detected issues were fixed, which means 100% of the reported issues were resolved.

---

## 9. How the Percentage of Fixed Issues Was Determined

The percentage of fixed issues was calculated using the following formula:

```text
fixed_percentage = (initial_issues - remaining_issues) / initial_issues * 100%
```

For this project:
- `initial_issues = 20`
- `remaining_issues = 0`

So:

```text
(20 - 0) / 20 * 100% = 100%
```

This value was determined by comparing the analyzer output before and after the fixes.

---

## 10. Git Hooks

To improve development workflow, a pre-commit hook script is prepared for the project.

The purpose of the hook is to run linting before creating a Git commit. If linting fails, the commit should be aborted so that problematic code is not committed to the repository.

The hook logic is based on running:

```bash
flutter analyze
```

If the analyzer reports problems that should block the commit, the hook returns a non-zero exit code and prevents the commit from being created.

Because Git hooks are stored locally in `.git/hooks`, they are not committed directly to the repository. For that reason, a versioned hook script is stored in the project as a regular file and can be copied into the local Git hooks directory when needed.

---

## 11. Integration with the Build Process

Linting is also integrated into the general project verification process before building or releasing the application.

A recommended verification sequence for the project is:

```bash
flutter analyze
flutter test
flutter build apk --release
```

This approach ensures that:
- static analysis is completed first;
- tests are executed before release build generation;
- the release build is created only after code quality checks pass.

In addition, a helper script such as `check.bat` may be used to perform combined verification more conveniently.

---

## 12. Static Type Checking

The project uses Dart static typing together with stricter analyzer language checks.

Unlike some other ecosystems, Dart does not require a separate external type checker such as `mypy` or TypeScript, because static type checking is already part of the language and the analyzer toolchain.

In this project, stricter type checking is reinforced through analyzer settings such as:
- `strict-casts: true`
- `strict-raw-types: true`

These settings help detect unsafe casts and the use of generic types without explicit type parameters.

---

## 13. Complex Code Quality Check Command

For practical development and maintenance, the project can use a combined code quality check process.

The recommended minimal sequence is:

```bash
flutter analyze
flutter test
```

This sequence checks:
- code quality and lint rules;
- static analysis status;
- correctness of automated tests.

For convenience, this process may be wrapped into a helper script such as `check.bat` or another local automation script.

---

## 14. Summary

The linting configuration added to this project improves code consistency, enforces clearer structure, and helps detect quality problems early.

The project now includes:
- configured analyzer rules in `analysis_options.yaml`;
- documented linting procedure;
- fixed analyzer issues;
- prepared hook support for pre-commit verification;
- integration of linting into the project quality check workflow;
- stricter static type checking through analyzer configuration.

This makes the code base easier to maintain and better prepared for further development, review, and release preparation.
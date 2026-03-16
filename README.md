# Diploma Work Prog (Flutter) — Nutrition App (SQLite)

A Flutter mobile application for nutrition-related calculations and local data storage using SQLite.

This project is a diploma / academic prototype focused on an offline-first approach. All core operations are performed locally on the device without a separate server, and the initial reference data is automatically inserted during the first application launch.

---

## 1. Project Purpose

The application is designed for:
- user registration and authentication;
- calorie and macronutrient calculation;
- vitamin calculation for a single product;
- daily vitamin intake calculation for multiple products;
- viewing and editing user profile data.

---

## 2. Main Features

### Authentication
- register with username + email + password;
- login using username or email;
- passwords are stored as SHA-256 hash + random salt;
- password change flow with current password verification.

### Calorie / Macro Calculator
- search foods by name;
- add multiple food items to a list;
- calculate total Kcal / Proteins / Fats / Carbohydrates.

### Vitamin Calculator

#### Single Product Mode
- select one food product;
- enter portion weight in grams;
- calculate vitamin content for the selected portion.

#### Daily Mode
- add multiple food items;
- select gender and weight category;
- calculate:
  - total amount of each vitamin;
  - share of each vitamin in the total amount;
  - ratio to the daily recommended norm.

### Cabinet (Profile)
- view:
  - username;
  - full name;
  - email;
  - diet plan (if assigned);
- actions:
  - change username;
  - change full name;
  - change email;
  - change password.

---

## 3. Architecture and Structural Elements

This project is a mobile client-side application, not a web-based client-server system. Therefore, its architecture differs from a typical server-based software solution.

### The project includes
- Flutter UI;
- business logic implemented as a service layer;
- DAO layer for data access;
- local SQLite database;
- initial seeding mechanism for reference data;
- Android runtime environment for application execution.

### The project does not include
- web server;
- application server;
- separate server-side DBMS;
- external file storage;
- caching services such as Redis or Memcached;
- separate backend API.

### Architecture Diagram

```text
+---------------------------------------------------+
|                 Android Device                    |
|                                                   |
|  +---------------------------------------------+  |
|  |              Flutter Application            |  |
|  |                                             |  |
|  |  UI Layer                                   |  |
|  |  - LoginScreen                              |  |
|  |  - RegisterScreen                           |  |
|  |  - HomeScreen                               |  |
|  |  - MacroCalculatorScreen                    |  |
|  |  - Vitamin Screens                          |  |
|  |  - CabinetScreen                            |  |
|  |                                             |  |
|  |  Service Layer                              |  |
|  |  - AuthService                              |  |
|  |  - NutritionCalculator                      |  |
|  |  - VitaminCalculator                        |  |
|  |                                             |  |
|  |  DAO Layer                                  |  |
|  |  - UserDao                                  |  |
|  |  - FoodDao                                  |  |
|  |  - VitaminDao                               |  |
|  |  - VitFoodDao                               |  |
|  |                                             |  |
|  |  DB Layer                                   |  |
|  |  - AppDb                                    |  |
|  |  - DbSeeder                                 |  |
|  |                                             |  |
|  |  Utils                                      |  |
|  |  - HashUtil                                 |  |
|  +---------------------------------------------+  |
|                     |                             |
|                     v                             |
|             Local SQLite Database                 |
|   users / meal_plans / food / vitamins / vit_food|
+---------------------------------------------------+

### Dependency Flow

```text
UI (screens/widgets)
    -> Services
        -> DAO
            -> AppDb
                -> SQLite
```

---

## 4. Tech Stack

- Flutter / Dart
- sqflite + path
- local SQLite database
- crypto (SHA-256 hashing)
- Android platform tools / emulator for running the application

---

## 5. Project Structure

### Root Structure

```text
android/                   Android-specific project files
lib/                       Main application source code
test/                      Tests
docs/                      Deployment, update, backup documentation
README.md                  Developer documentation
pubspec.yaml               Flutter dependencies
pubspec.lock               Locked package versions
analysis_options.yaml      Analyzer rules
LICENSE                    License information
```

### Structure of `lib/`

```text
lib/
  main.dart

  data/
    db/
      app_db.dart
      db_seeder.dart
    dao/
      user_dao.dart
      food_dao.dart
      vitamin_dao.dart
      vit_food_dao.dart

  models/
    user.dart
    food.dart
    vitamin.dart
    portion.dart

  services/
    auth_service.dart
    calculators/
      macro_calculator.dart
      vitamin_calculator.dart

  utils/
    hash_utils/
      pswd_hash_util.dart

  ui/
    screens/
      login_screen.dart
      register_screen.dart
      home_screen.dart
      macro_calculator_screen.dart
      main_vitamin_calculator_screen.dart
      single_vitamin_calculator_screen.dart
      day_vitamin_calculator_screen.dart
      cabinet_screen.dart
    widgets/
      app_input.dart
      primary_button.dart
```

### Short Description of Main Parts
- `main.dart` — application entry point, database initialization, and seeding start.
- `data/db/` — database opening, table creation, and initial data population.
- `data/dao/` — SQL queries and table access logic.
- `models/` — application data models.
- `services/` — business logic layer.
- `utils/` — helper utilities, including password hashing.
- `ui/screens/` — application screens.
- `ui/widgets/` — reusable UI components.

---

## 6. Database Schema (SQLite)

The project uses the following tables:

- `meal_plans(id, description)`
- `users(id, username UNIQUE, email UNIQUE, full_name NULL, password_hash, password_salt, created_at, meal_plan_id FK)`
- `vitamins(id, name UNIQUE)`
- `food(id, name UNIQUE, kcal_per100g, proteins_per100g, fats_per100g, carbohydrates_per100g)`
- `vit_food(id, food_id FK, vitamin_id FK, amount_per_100g, UNIQUE(food_id, vitamin_id))`

Foreign keys are enabled with:

```sql
PRAGMA foreign_keys = ON;
```

---

## 7. Developer Setup Guide

Below is a step-by-step guide for a developer who wants to join the project and run it from scratch on a freshly installed operating system.

### 7.1. Install Required Software

The following software must be installed:
1. Git
2. Flutter SDK
3. Android Studio
4. Android SDK
5. Android emulator or physical Android device
6. JDK (usually installed together with Android Studio)
7. Optional: VS Code or Android Studio as IDE

### 7.2. Configure Flutter Environment

1. Download Flutter SDK.
2. Extract it to a convenient folder, for example:
  - `C:\flutter` on Windows
  - or another directory without spaces in the path.
3. Add `flutter/bin` to the system `PATH`.
4. Open a new terminal and run:

```bash
flutter doctor
```

5. Make sure Flutter toolchain and Android toolchain are detected correctly.
6. If Android licenses have not been accepted yet, run:

```bash
flutter doctor --android-licenses
```

and accept all licenses.

### 7.3. Configure Android Studio

1. Install Android Studio.
2. During the first launch, install:
  - Android SDK;
  - Android SDK Platform;
  - Android SDK Build-Tools;
  - Android Emulator;
  - Platform Tools.
3. Create at least one Android Virtual Device (AVD) if the project will be run in an emulator.

### 7.4. Clone the Repository

Open a terminal, go to the directory where the project should be stored, and run:

```bash
git clone https://github.com/serhiibatrachenko505-stack/diploma-prog.git
cd diploma-prog
```

### 7.5. Install Project Dependencies

In the project root, run:

```bash
flutter pub get
```

This command downloads all dependencies listed in `pubspec.yaml`.

### 7.6. Check Available Devices

Before running the application, check whether Flutter sees an available emulator or device:

```bash
flutter devices
```

If the list is empty:
- start an Android emulator;
- or connect a physical Android device;
- enable USB debugging;
- verify availability via adb.

### 7.7. Run the Project in Development Mode

In the project root, run:

```bash
flutter run
```

After a successful build, the application will be installed and launched on the selected device.

### 7.8. Database Creation and Configuration

The SQLite database does not need to be created manually.

During the first launch:
1. the application opens the local database;
2. if the database file does not exist, it is created automatically;
3. all required tables are created;
4. initial seeding of reference data is performed.

The database is automatically populated with:
- meal plans;
- vitamins list;
- foods with macro values;
- vitamin-to-food links.

Seeding is executed inside a transaction and uses `ConflictAlgorithm.ignore`, so repeated runs do not create duplicates.

### 7.9. Basic Commands for Working with the Project

Update dependencies:
```bash
flutter pub get
```

Run the application:
```bash
flutter run
```

Check available devices:
```bash
flutter devices
```

Run static analysis:
```bash
flutter analyze
```

Run tests:
```bash
flutter test
```

Clean generated build artifacts:
```bash
flutter clean
```

After cleaning, it is usually necessary to run:
```bash
flutter pub get
```

### 7.10. Typical Developer Workflow

1. Pull the latest changes:
```bash
git pull
```

2. Download or update dependencies:
```bash
flutter pub get
```

3. Check the code:
```bash
flutter analyze
```

4. Run the application:
```bash
flutter run
```

5. After making changes, verify once again that the project builds and runs correctly.

### 7.11. Common Problems

#### Flutter doctor shows errors
- check PATH;
- install or reinstall Android SDK;
- accept Android licenses;
- restart the terminal.

#### No devices available
- start the emulator;
- check USB debugging;
- run `flutter devices`;
- run `adb devices`.

#### Build errors after dependency changes
Run:
```bash
flutter clean
flutter pub get
flutter run
```

---

## 8. Build Release Version

To create an Android release build, use:

### APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle
```

Generated artifacts are stored in the `build/` directory.

---

## 9. Notes / Known Limitations

- Daily vitamin norms are currently hardcoded and are planned to be moved to the database later.
- Session persistence (auto-login) is not implemented yet.
- The UI is intentionally minimal for MVP / academic requirements.
- The project does not include a backend server, so all operations are local.

---

## 10. Roadmap

- Save current user session (SharedPreferences)
- Diet plan screen: choose and store assigned plan for user
- Better daily vitamins: percentage of recommended daily intake based on validated norms
- Charts (pie chart for vitamin share)
- Optional online sync (future)

---

## 11. DevOps Documentation

Additional deployment and maintenance documentation is placed in the `docs/` directory:
- `docs/deployment.md` — production deployment guide;
- `docs/update.md` — update procedure guide;
- `docs/backup.md` — backup and recovery guide.

---

## 12. Audit Checklist

- Public repository
- `.gitignore` added
- `README.md` added
- `LICENSE` added
- No sensitive information included

---

## 13. Code Documentation Standards

All new public classes, methods, and functions in this project must be documented using Dart documentation comments with the `///` format.

Documentation rules for contributors:
- document every public API element;
- start each documentation block with a short summary sentence;
- describe the purpose of the class, method, or function clearly;
- explain important parameters, return values, and side effects when needed;
- use Dart doc references such as `[AuthService]`, `[UserDao]`, or `[calculateForList]` when referring to other code elements;
- keep documentation updated whenever the related code is changed.

Recommended example:

```dart
/// Calculates total macronutrients for the provided food portions.
///
/// Returns the aggregated nutrition result for the full list of portions.
```

Project documentation can be generated from source code comments, so maintaining accurate doc comments is required for all future development.

---

## 14. License

Academic / educational use.
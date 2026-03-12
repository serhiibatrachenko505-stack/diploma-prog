# Diploma Work Prog (Flutter) — Nutrition App (SQLite)

A Flutter mobile app prototype for nutrition tracking:
- Calorie / macro calculator (Kcal, Proteins, Fats, Carbohydrates)
- Vitamin calculator:
    - Single product mode
    - Daily mode (multiple products + norms by gender & weight category)
- Authentication (register / login)
- User cabinet (profile data + edit actions)
- Local SQLite database with seeded reference data (foods, vitamins, links)

This project is a diploma / academic prototype focused on offline-first work with a clean DAO/service structure.

---

## Features

### Authentication
- Register with username + email + password
- Login using username or email
- Passwords are stored as SHA-256 hash + random salt
- Change password flow (verify current password, generate new hash+salt)

### Calorie / Macro calculator (CC)
- Search foods by name
- Add multiple items (food + grams) to a list
- Calculate total Kcal / P / F / C

### Vitamin calculators

Single product
- Search and select one food
- Enter grams
- Calculate vitamins (mg) for that portion

Daily mode
- Add multiple foods + grams to a list
- Select gender and weight category
- Calculate:
    - total mg per vitamin
    - percent share of total vitamins (pie-share)
    - mg / daily norm mg (norms are currently hardcoded in code)

### Cabinet (Profile)
- Shows:
    - username
    - full name (if any)
    - email
    - diet plan (if assigned)
- Actions:
    - change username
    - change full name
    - change email
    - change password

---

## Tech Stack
- Flutter / Dart
- sqflite + path (SQLite)
- Local DB (offline-first)

---

## Project Structure (lib/)

lib/
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
main.dart

---

## Database Schema (SQLite)

Tables:
- meal_plans(id, description)
- users(id, username UNIQUE, email UNIQUE, full_name NULL, password_hash, password_salt, created_at, meal_plan_id FK)
- vitamins(id, name UNIQUE)
- food(id, name UNIQUE, kcal_per100g, proteins_per100g, fats_per100g, carbohydrates_per100g)
- vit_food(id, food_id FK, vitamin_id FK, amount_per_100g, UNIQUE(food_id, vitamin_id))

Foreign keys are enabled with PRAGMA foreign_keys = ON.

---

## Setup & Run

1) Install dependencies
   flutter pub get

2) Run the app
   flutter run

3) Database initialization & seeding
   On app start, the database is created (if missing) and seeded with:
- meal plans
- vitamins list
- foods with macro values
- vitamin-to-food links (vit_food)

Seeding runs in a transaction and uses ignore on unique constraints to be idempotent.

---

## Notes / Known Limitations
- Daily vitamin norms are currently hardcoded (planned to move to DB later).
- Session persistence (auto-login) is not implemented yet (future improvement).
- UI is intentionally minimal for MVP / academic requirements.

---

## Roadmap (Ideas)
- Save current user session (SharedPreferences)
- Diet plan screen: choose and store assigned plan for user
- Better daily vitamins: % of recommended daily intake based on validated norms
- Charts (pie chart for vitamin share)
- Optional online sync (future)

---

## Audit checklist
- Public repository
- .gitignore added
- README added
- LICENSE added
- No sensitive information included

## License
Academic / educational use.
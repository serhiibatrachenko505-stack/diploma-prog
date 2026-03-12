import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDb {
  AppDb._();
  
  static final AppDb instance = AppDb._();
  
  Database? _db;
  
  Future<Database> get db async {
    final existing = _db;
    
    if(existing != null){
      return existing;
    }
    
    _db = await _open();
    
    return _db!;
  }
  
  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return await openDatabase(
        path,
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE meal_plans(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              description TEXT NOT NULL
            );
          ''');
          await db.execute('''
          CREATE TABLE users(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL UNIQUE,
              email TEXT NOT NULL UNIQUE,
              full_name TEXT,
              password_hash TEXT NOT NULL,
              password_salt TEXT NOT NULL,
              created_at TEXT NOT NULL,
              meal_plan_id INTEGER,
              FOREIGN KEY(meal_plan_id)
                REFERENCES meal_plans(id)
                ON UPDATE CASCADE
                ON DELETE SET NULL
            );
          ''');
          await db.execute('''
            CREATE TABLE vitamins(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL UNIQUE
            );
          ''');
          await db.execute('''
            CREATE TABLE food(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL UNIQUE,
              kcal_per100g REAL NOT NULL,
              proteins_per100g REAL NOT NULL,
              fats_per100g REAL NOT NULL,
              carbohydrates_per100g REAL NOT NULL
            );
          ''');
          await db.execute('''
            CREATE TABLE vit_food(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              food_id INTEGER NOT NULL,
              vitamin_id INTEGER NOT NULL,
              amount_per_100g REAL NOT NULL,
              
              UNIQUE(food_id,vitamin_id),
              
              FOREIGN KEY (food_id) 
                REFERENCES food(id) 
                ON DELETE CASCADE,
                
              FOREIGN KEY (vitamin_id) 
                REFERENCES vitamins(id) 
                ON DELETE CASCADE
            );
          ''');
        },
    );
  }

  Future<void> close() async {
    final existing = _db;

    if(existing != null){
      await existing.close();
      _db = null;
    }
  }
}
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;

    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'your_database.db');

    // Créez la base de données s'il n'existe pas
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    // Créez la table d'utilisateurs
    await db.execute('''
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        nom TEXT,
        prenom TEXT,
        role TEXT
      )
    ''');
  }

  // Ajoutez des méthodes pour gérer les opérations sur la base de données, par exemple, ajouter un utilisateur, vérifier l'authentification, etc.

  // Exemple pour ajouter un utilisateur
  Future<int> addUser(User user) async {
    final dbClient = await db;
    return await dbClient!.insert('Users', user.toMap());
  }

  // Exemple pour vérifier l'authentification
  Future<bool> authenticateUser(String email, String password) async {
    final dbClient = await db;
    final result = await dbClient!.query('Users',
        where: 'email = ? AND password = ?', whereArgs: [email, password]);

    return result.isNotEmpty;
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/entry.dart';
import '../models/person.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'shopbook.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries(
        id TEXT PRIMARY KEY,
        serviceType TEXT NOT NULL,
        customerName TEXT,
        amount REAL NOT NULL,
        note TEXT,
        paymentType TEXT NOT NULL,
        personId TEXT NOT NULL,
        date TEXT NOT NULL,
        dayName TEXT NOT NULL,
        isDeleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE people(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        avatarColor TEXT NOT NULL,
        quickAddButtons TEXT
      )
    ''');
  }

  // Entry operations
  Future<void> insertEntry(Entry entry) async {
    final db = await database;
    await db.insert('entries', entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Entry>> getAllEntries() async {
    final db = await database;
    final maps = await db.query('entries', where: 'isDeleted = 0');
    return List.generate(maps.length, (i) => Entry.fromMap(maps[i]));
  }

  Future<List<Entry>> getEntriesByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final maps = await db.query(
      'entries',
      where: 'date >= ? AND date < ? AND isDeleted = 0',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Entry.fromMap(maps[i]));
  }

  Future<List<Entry>> getEntriesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'entries',
      where: 'date >= ? AND date < ? AND isDeleted = 0',
      whereArgs: [start.toIso8601String(), end.add(const Duration(days: 1)).toIso8601String()],
    );
    return List.generate(maps.length, (i) => Entry.fromMap(maps[i]));
  }

  Future<List<Entry>> getDueEntries() async {
    final db = await database;
    final maps = await db.query(
      'entries',
      where: 'paymentType = ? AND isDeleted = 0',
      whereArgs: ['Due'],
    );
    return List.generate(maps.length, (i) => Entry.fromMap(maps[i]));
  }

  Future<void> updateEntry(Entry entry) async {
    final db = await database;
    await db.update('entries', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<void> softDeleteEntry(String id) async {
    final db = await database;
    await db.update('entries', {'isDeleted': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> restoreEntry(String id) async {
    final db = await database;
    await db.update('entries', {'isDeleted': 0}, where: 'id = ?', whereArgs: [id]);
  }

  // Person operations
  Future<void> insertPerson(Person person) async {
    final db = await database;
    final personMap = person.toMap();
    personMap['quickAddButtons'] = jsonEncode(personMap['quickAddButtons']);
    await db.insert('people', personMap, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Person>> getAllPeople() async {
    final db = await database;
    final maps = await db.query('people');
    return List.generate(maps.length, (i) {
      final map = maps[i];
      if (map['quickAddButtons'] != null) {
        map['quickAddButtons'] = jsonDecode(map['quickAddButtons'] as String);
      }
      return Person.fromMap(map);
    });
  }

  Future<void> updatePerson(Person person) async {
    final db = await database;
    final personMap = person.toMap();
    personMap['quickAddButtons'] = jsonEncode(personMap['quickAddButtons']);
    await db.update('people', personMap, where: 'id = ?', whereArgs: [person.id]);
  }

  Future<void> deletePerson(String id) async {
    final db = await database;
    await db.delete('people', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('entries');
    await db.delete('people');
  }
}

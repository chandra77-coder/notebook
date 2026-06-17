import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/entry.dart';
import '../models/person.dart';
import '../utils/database_helper.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DataProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Entry> _entries = [];
  List<Person> _people = [];
  Entry? _deletedEntry;
  DateTime? _deletedTime;

  List<Entry> get entries => _entries;
  List<Person> get people => _people;

  Future<void> loadData() async {
    _entries = await _dbHelper.getAllEntries();
    _people = await _dbHelper.getAllPeople();
    notifyListeners();
  }

  Future<void> addEntry(Entry entry) async {
    await _dbHelper.insertEntry(entry);
    _entries.add(entry);
    notifyListeners();
  }

  Future<void> updateEntry(Entry entry) async {
    await _dbHelper.updateEntry(entry);
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String id) async {
    final entry = _entries.firstWhere((e) => e.id == id);
    _deletedEntry = entry;
    _deletedTime = DateTime.now();
    await _dbHelper.softDeleteEntry(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> undoDeleteEntry() async {
    if (_deletedEntry != null) {
      await _dbHelper.restoreEntry(_deletedEntry!.id);
      _entries.add(_deletedEntry!);
      _deletedEntry = null;
      _deletedTime = null;
      notifyListeners();
    }
  }

  Future<void> addPerson(Person person) async {
    await _dbHelper.insertPerson(person);
    _people.add(person);
    notifyListeners();
  }

  Future<void> updatePerson(Person person) async {
    await _dbHelper.updatePerson(person);
    final index = _people.indexWhere((p) => p.id == person.id);
    if (index != -1) {
      _people[index] = person;
      notifyListeners();
    }
  }

  Future<void> deletePerson(String id) async {
    await _dbHelper.deletePerson(id);
    _people.removeWhere((p) => p.id == id);
    _entries.removeWhere((e) => e.personId == id);
    notifyListeners();
  }

  List<Entry> getTodayEntries() {
    final today = DateTime.now();
    return _entries.where((e) {
      return e.date.year == today.year &&
          e.date.month == today.month &&
          e.date.day == today.day;
    }).toList();
  }

  List<Entry> getThisWeekEntries() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _entries.where((e) {
      return e.date.isAfter(weekStart) && e.date.isBefore(now.add(const Duration(days: 1)));
    }).toList();
  }

  List<Entry> getThisMonthEntries() {
    final now = DateTime.now();
    return _entries.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).toList();
  }

  double getTodayEarned() {
    return getTodayEntries()
        .where((e) => e.paymentType != 'Due')
        .fold(0, (sum, e) => sum + e.amount);
  }

  double getTodaySpent() {
    return 0; // Spent would be calculated from expense entries if needed
  }

  double getTodayProfit() {
    return getTodayEarned() - getTodaySpent();
  }

  double getTotalDue() {
    return _entries
        .where((e) => e.paymentType == 'Due')
        .fold(0, (sum, e) => sum + e.amount);
  }

  double getThisWeekEarned() {
    return getThisWeekEntries()
        .where((e) => e.paymentType != 'Due')
        .fold(0, (sum, e) => sum + e.amount);
  }

  double getThisWeekSpent() {
    return 0;
  }

  double getThisMonthEarned() {
    return getThisMonthEntries()
        .where((e) => e.paymentType != 'Due')
        .fold(0, (sum, e) => sum + e.amount);
  }

  double getThisMonthSpent() {
    return 0;
  }

  List<Entry> getDueEntries() {
    return _entries.where((e) => e.paymentType == 'Due').toList();
  }

  Person? getPersonById(String id) {
    try {
      return _people.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> exportDataAsJson() async {
    final data = {
      'entries': _entries.map((e) => e.toMap()).toList(),
      'people': _people.map((p) => p.toMap()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };

    final directory = await getExternalStorageDirectory();
    final file = File('${directory?.path}/shopbook_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> importDataFromJson(File file) async {
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    await _dbHelper.clearAllData();

    final entries = (data['entries'] as List).map((e) => Entry.fromMap(e as Map<String, dynamic>)).toList();
    for (final entry in entries) {
      await _dbHelper.insertEntry(entry);
    }

    final people = (data['people'] as List).map((p) => Person.fromMap(p as Map<String, dynamic>)).toList();
    for (final person in people) {
      await _dbHelper.insertPerson(person);
    }

    await loadData();
  }
}

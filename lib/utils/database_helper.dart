import 'package:flutter/material.dart'; 
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/appointment.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'appointments.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE appointments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            date TEXT,
            time TEXT,
            notifyByPhone INTEGER,
            notifyByEmail INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertAppointment(Appointment appointment) async {
    final db = await database;

    String formattedDate = appointment.date.toIso8601String();
    String formattedTime = '${appointment.time.hour}:${appointment.time.minute}';

    return await db.insert(
      'appointments',
      {
        'name': appointment.name,
        'email': appointment.email,
        'date': formattedDate,
        'time': formattedTime,
        'notifyByPhone': appointment.notifyByPhone ? 1 : 0,
        'notifyByEmail': appointment.notifyByEmail ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // getAppointments metodunu tanımlayın
  Future<List<Appointment>> getAppointments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('appointments');

    return List.generate(maps.length, (i) {
      return Appointment(
        id: maps[i]['id'],
        name: maps[i]['name'],
        email: maps[i]['email'],
        date: DateTime.parse(maps[i]['date']),
        time: TimeOfDay(
          hour: int.parse(maps[i]['time'].split(':')[0]),
          minute: int.parse(maps[i]['time'].split(':')[1]),
        ),
        notifyByPhone: maps[i]['notifyByPhone'] == 1,
        notifyByEmail: maps[i]['notifyByEmail'] == 1,
      );
    });
  }

  // deleteAppointment metodunu tanımlayın
  Future<int> deleteAppointment(int id) async {
    final db = await database;
    return await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;

    String formattedDate = appointment.date.toIso8601String();
    String formattedTime = '${appointment.time.hour}:${appointment.time.minute}';

    return await db.update(
      'appointments',
      {
        'name': appointment.name,
        'email': appointment.email,
        'date': formattedDate,
        'time': formattedTime,
        'notifyByPhone': appointment.notifyByPhone ? 1 : 0,
        'notifyByEmail': appointment.notifyByEmail ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }
}

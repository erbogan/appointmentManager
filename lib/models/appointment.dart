import 'package:flutter/material.dart';

class Appointment {
  int? id;
  String name;
  String? email; // Email alanı eklendi
  DateTime date;
  TimeOfDay time;
  bool notifyByPhone;
  bool notifyByEmail;

  Appointment({
    this.id,
    required this.name,
    this.email, // Email alanı eklendi
    required this.date,
    required this.time,
    this.notifyByPhone = false,
    this.notifyByEmail = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email, // Email alanı eklendi
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'notifyByPhone': notifyByPhone ? 1 : 0,
      'notifyByEmail': notifyByEmail ? 1 : 0,
    };
  }

  static Appointment fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      name: map['name'],
      email: map['email'], // Email alanı eklendi
      date: DateTime.parse(map['date']),
      time: TimeOfDay(
        hour: int.parse(map['time'].split(':')[0]),
        minute: int.parse(map['time'].split(':')[1]),
      ),
      notifyByPhone: map['notifyByPhone'] == 1,
      notifyByEmail: map['notifyByEmail'] == 1,
    );
  }
}

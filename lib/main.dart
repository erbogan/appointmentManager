import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  tz.initializeTimeZones();

  await NotificationService().initializeNotifications(); 

  runApp(AppointmentManagerApp());
}

class AppointmentManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appointment Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // intl paketini ekleyin
import '../models/appointment.dart';
import '../utils/database_helper.dart';
import 'add_edit_appointment_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final appointments = await _dbHelper.getAppointments();
    setState(() {
      _appointments = appointments;
    });
  }

  String _formatDateTime(DateTime date, TimeOfDay time) {
    final combinedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return DateFormat('dd.MM.yyyy HH:mm').format(combinedDateTime);
  }

  void _navigateToAddEditScreen([Appointment? appointment]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAppointmentScreen(appointment: appointment),
      ),
    );

    if (result == true) {
      _loadAppointments();
    }
  }

  Future<void> _confirmDelete(Appointment appointment) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Köşe yuvarlama
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Termin löschen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
        content: Text(
          'Möchten Sie diesen Termin wirklich löschen?',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Löschen'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _dbHelper.deleteAppointment(appointment.id!);
      _loadAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Termine'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: _appointments.isEmpty
          ? Center(
              child: Text(
                'Keine Termine',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                return Card(
                  color: Colors.blue,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      appointment.name,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      _formatDateTime(appointment.date, appointment.time),
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => _navigateToAddEditScreen(appointment),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Color.fromRGBO(245, 245, 220, 1.0),
                      ),
                      onPressed: () => _confirmDelete(appointment),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}

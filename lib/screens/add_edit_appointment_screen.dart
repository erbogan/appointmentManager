import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../utils/database_helper.dart';
import '../services/notification_service.dart';

class AddEditAppointmentScreen extends StatefulWidget {
  final Appointment? appointment;

  AddEditAppointmentScreen({this.appointment});

  @override
  _AddEditAppointmentScreenState createState() => _AddEditAppointmentScreenState();
}

class _AddEditAppointmentScreenState extends State<AddEditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  String _name = '';
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _notifyByPhone = false;

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      _name = widget.appointment!.name;
      _date = widget.appointment!.date;
      _time = widget.appointment!.time;
      _notifyByPhone = widget.appointment!.notifyByPhone;
    }
  }

  void _saveAppointment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newAppointment = Appointment(
        id: widget.appointment?.id,
        name: _name,
        date: _date,
        time: _time,
        notifyByPhone: _notifyByPhone,
      );

      if (widget.appointment == null) {
        await _dbHelper.insertAppointment(newAppointment);
      } else {
        await _dbHelper.updateAppointment(newAppointment);
      }

      _scheduleNotifications(newAppointment);

      Navigator.of(context).pop(true);
    }
  }

  void _scheduleNotifications(Appointment appointment) {
    final DateTime appointmentDateTime = DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
      appointment.time.hour,
      appointment.time.minute,
    );

    if (_notifyByPhone) {
      _notificationService.scheduleAppointmentNotifications(
        appointmentDateTime,
        'Randevunuz: ${appointment.name}',
        _notifyByPhone,
      );
    }
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _date = selectedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), // 24 saatlik zaman formatını zorla
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        _time = selectedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appointment == null ? 'Neuen Termin erstellen' : 'Termin bearbeiten'),
        backgroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'Termin Name',
                  labelStyle: TextStyle(color: Colors.blue),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte einen Namen eingeben';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Datum: ${DateFormat('dd.MM.yyyy').format(_date)}',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                trailing: Icon(Icons.calendar_today, color: Colors.blue),
                onTap: _selectDate,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Zeit: ${_time.format(context)}',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                trailing: Icon(Icons.access_time, color: Colors.blue),
                onTap: _selectTime,
              ),
              Divider(color: Colors.grey),
              SwitchListTile(
                title: Text('Telefon', style: TextStyle(fontSize: 14, color: _notifyByPhone ? Colors.blue : Colors.grey)),
                activeColor: Colors.blue,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey[300],
                value: _notifyByPhone,
                onChanged: (value) {
                  setState(() {
                    _notifyByPhone = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(widget.appointment == null ? 'Erstellen' : 'Aktualisieren'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

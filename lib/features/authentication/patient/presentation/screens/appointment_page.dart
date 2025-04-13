import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medisafe/features/home/patient/presentation/screens/appointmentsScreen.dart';
import 'package:medisafe/models/doctor_model.dart';

class AppointmentPage extends StatefulWidget {
  final Doctor doctor;

  const AppointmentPage({super.key, required this.doctor});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  int selectedDateIndex = 0;
  int selectedSlotIndex = -1;

  List<String> availableDates = [];
  Map<String, List<String>> availableSlots = {};

  // Initialize with current date
  DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _generateAvailableDates();
    _fetchAvailableSlots();
  }

  /// Generate the next 7 dates in `yyyy-MM-dd` format
  void _generateAvailableDates() {
    availableDates = [];
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      availableDates.add(formattedDate);
    }
  }

  void _fetchAvailableSlots() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctor.id)
          .get();
      print('Fetched document for doctor: ${widget.doctor.id}');

      if (doc.exists) {
        final data = doc.data();
        print('Doctor document data: $data');

        if (data != null && data['available_time'] != null) {
          print('Available time field: ${data['available_time']}');

          if (data['available_time'] is String) {
            print('Available time is a String: ${data['available_time']}');
            final timeRange = (data['available_time'] as String).split('-');
            if (timeRange.length == 2) {
              final start = timeRange[0].trim();
              final end = timeRange[1].trim();
              final slots = _generateTimeSlots(start, end);
              print('Generated time slots: $slots');

              setState(() {
                for (final date in availableDates) {
                  availableSlots[date] = slots;
                }
              });
            }
          } else if (data['available_time'] is Map<String, dynamic>) {
            print('Available time is a Map: ${data['available_time']}');
            final rawSlots = data['available_time'] as Map<String, dynamic>;
            setState(() {
              availableSlots = rawSlots.map((key, value) {
                final start = value['start'] as String;
                final end = value['end'] as String;
                final slots = _generateTimeSlots(start, end);
                print('Generated time slots for $key: $slots');
                return MapEntry(key, slots);
              });

              availableDates = availableSlots.keys.toList();
            });
          } else {
            print('Available time has an unexpected type.');
          }
        } else {
          print('No available_time field found in the document.');
        }
      } else {
        print('Doctor document does not exist');
      }
    } catch (e) {
      print('Error fetching slots: $e');
    }
  }

  List<String> _generateTimeSlots(String startTime, String endTime) {
    final List<String> slots = [];
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);

    if (start == null || end == null || start.isAfter(end)) return slots;

    var current = start;
    while (!current.isAfter(end)) {
      slots.add(_formatTime(current));
      current = current.add(const Duration(minutes: 30));
    }

    return slots;
  }

  DateTime? _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return DateTime(today.year, today.month, today.day, hour, minute);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _bookAppointment() async {
    if (selectedSlotIndex == -1 || availableDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to book an appointment')),
      );
      return;
    }

    final selectedDate = availableDates[selectedDateIndex];
    final selectedSlot = availableSlots[selectedDate]?[selectedSlotIndex];
    try {
      // Check for existing appointment
      final existing = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .where('doctorId', isEqualTo: widget.doctor.id)
          .where('date', isEqualTo: selectedDate)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'You already have an appointment with this doctor on this date'),
          ),
        );
        return;
      }

      // Proceed to book
      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user.uid,
        'doctorId': widget.doctor.id,
        'doctorName': widget.doctor.name,
        'date': selectedDate, // Use yyyy-MM-dd format
        'timeSlot': selectedSlot,
        'status': 'Pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: $e')),
      );
    }
  }

  Widget _buildSlotSelector() {
    final slots = availableSlots[availableDates[selectedDateIndex]] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Time Slot:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: List.generate(
            slots.length,
            (index) {
              return ChoiceChip(
                label: Text(slots[index]),
                selected: selectedSlotIndex == index,
                onSelected: (bool selected) {
                  setState(() {
                    selectedSlotIndex = selected ? index : -1;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Date:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: List.generate(availableDates.length, (index) {
                  return ChoiceChip(
                    label: Text(availableDates[index]), // Display `yyyy-MM-dd`
                    selected: selectedDateIndex == index,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedDateIndex = selected ? index : -1;
                        selectedSlotIndex = -1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              if (selectedDateIndex != -1) _buildSlotSelector(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _bookAppointment,
                child: const Text('Book Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

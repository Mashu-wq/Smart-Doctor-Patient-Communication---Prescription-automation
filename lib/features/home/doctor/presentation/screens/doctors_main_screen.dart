import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'doctors_home_screen.dart';
import 'rejected_appointments_screen.dart';
import 'visited_appointments_screen.dart';
import 'doctors_profile_screen.dart';

class DoctorMainScreen extends ConsumerStatefulWidget {
  const DoctorMainScreen({super.key});

  @override
  _DoctorMainScreenState createState() => _DoctorMainScreenState();
}

class _DoctorMainScreenState extends ConsumerState<DoctorMainScreen> {
  int _selectedIndex = 0;

  // List of all screens except ProfileScreen (it will be dynamically created)
  final List<Widget> _screens = [
    const HomeScreen(),
    //const RejectedAppointmentsScreen(),
    const VisitedAppointmentsScreen(),
  ];

  // Handle bottom navigation bar taps
  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    // Dynamically navigate to ProfileScreen when the "Profile" tab is selected
    if (index == 2) {
      final doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (doctorId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: No doctor is logged in.")),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            doctorId: doctorId,
          ),
        ),
      ).then((_) {
        // Optionally reset the index back to Home after ProfileScreen is closed
        setState(() {
          _selectedIndex = 0; // Set to the default (Home) tab
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex < 2 ? _screens[_selectedIndex] : Container(),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          //BottomNavigationBarItem(icon: Icon(Icons.block), label: 'Rejected'),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle), label: 'Visited'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

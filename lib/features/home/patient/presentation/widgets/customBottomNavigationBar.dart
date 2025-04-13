import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medisafe/core/primary_color.dart';
import 'package:medisafe/features/authentication/patient/presentation/screens/patient_login_screen.dart';
import 'package:medisafe/features/home/patient/presentation/screens/appointmentsScreen.dart';
import 'package:medisafe/features/home/patient/presentation/screens/patient_home_screen.dart';
import 'package:medisafe/features/home/patient/presentation/screens/available_doctors_screen.dart';
import 'package:medisafe/features/home/patient/presentation/screens/profileScreen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final user = FirebaseAuth.instance.currentUser;

  CustomBottomNavigationBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    // Navigate to the respective screen based on index
    if (index != currentIndex) {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PatientHomeScreen()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AvailableDoctorsScreen()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
          );
          break;
        case 3:
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PatientProfileScreen(patientId: user.uid),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PatientLoginScreen()),
            );
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.appColor,
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital),
          label: 'Doctors',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) => _onItemTapped(context, index),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:medisafe/features/home/doctor/presentation/screens/doctors_main_screen.dart';
// import 'package:medisafe/features/home/doctor/presentation/screens/doctors_profile_screen.dart';
// import 'package:medisafe/features/home/doctor/presentation/screens/pending_appointments_screen.dart';
// import 'package:medisafe/features/home/doctor/presentation/screens/visited_appointments_screen.dart';

// class DcotorCustomNavigationBar extends StatelessWidget {
//   final int currentIndex;
//   const DcotorCustomNavigationBar({super.key, required this.currentIndex});

//   void _onItemTapped(BuildContext context, int index) {
//     // Navigate to the respective screen based on index
//     if (index != currentIndex) {
//       switch (index) {
//         case 0:
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const DoctorMainScreen()),
//           );
//           break;
//         case 1:
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => const PendingAppointmentsScreen()),
//           );
//           break;
//         case 2:
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => const VisitedAppointmentsScreen()),
//           );
//           break;
//         case 3:
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const ProfileScreen()),
//           );
//           break;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       selectedItemColor: Colors.blue,
//       unselectedItemColor: Colors.grey,
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.pending), label: 'Pending Appointments'),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.check_circle), label: 'Visited Appointments'),
//         BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//       ],
//       onTap: (index) => _onItemTapped(context, index),
//     );
//   }
// }

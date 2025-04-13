import 'package:flutter/material.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';
import 'package:medisafe/features/authentication/doctor/presentation/screens/doctor_login_screen.dart';
import 'package:medisafe/features/authentication/patient/presentation/screens/patient_login_screen.dart';
// import 'package:medisafe/features/doctor/presentation/doctor_login_screen.dart';
// import 'package:medisafe/features/patient/presentation/patient_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/splash.png", // Your image here
              width: 270,
              height: 270,
            ),
            const SizedBox(height: 20),
            Pacifico(text: "Select What You Are?", size: 27.0),
            const SizedBox(height: 30),
            _buildRoleButton(
                context, "Doctor", DoctorLoginScreen(), Colors.black),
            const SizedBox(height: 15),
            _buildRoleButton(
                context, "Patient", PatientLoginScreen(), Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(
      BuildContext context, String title, Widget screen, Color color) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Pacifico(
        text: title,
        size: 20.0,
        color: AppColors.appColor,
      ),
    );
  }
}

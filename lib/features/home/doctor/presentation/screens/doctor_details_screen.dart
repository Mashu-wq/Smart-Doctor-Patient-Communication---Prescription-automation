import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';
import 'package:medisafe/features/authentication/patient/presentation/screens/appointment_page.dart';
import 'package:medisafe/features/home/doctor/presentation/screens/rating_submission_screen.dart';
import 'package:medisafe/features/home/patient/presentation/screens/call_screen/voice_call_screen.dart';
import 'package:medisafe/models/doctor_model.dart';
import 'reviews_page.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Doctor doctor;
  final String patiendId;

  const DoctorDetailsScreen({
    super.key,
    required this.doctor,
    required this.patiendId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColor,
      appBar: AppBar(
        title: Pacifico(text: "Doctor Profile", size: 25.0),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600; // Detects web layout

          return SingleChildScrollView(
            child: Center(
              child: Container(
                width: isWeb ? 500 : double.infinity, // Restrict width on web
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      backgroundImage: NetworkImage(doctor.profileImageUrl),
                      radius: 60,
                    ),
                    const SizedBox(height: 16),
                    Pacifico(text: 'Dr. ${doctor.name}', size: 20.0),

                    const SizedBox(height: 8),
                    OpenSans(text: doctor.specialization, size: 18.0),

                    const SizedBox(height: 16),
                    OpenSans(
                        text: '${doctor.clinicName}, ${doctor.qualifications}',
                        size: 16.0),
                    // Text(
                    //   '${doctor.clinicName}, ${doctor.qualifications}',
                    //   textAlign: TextAlign.center,
                    //   style:
                    //       const TextStyle(fontSize: 16, color: Colors.black54),
                    // ),
                    const SizedBox(height: 16),

                    // Call, Video & Message Buttons
                    //_buildActionButtons(context),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Biography
                    _buildBiographySection(),

                    const SizedBox(height: 16),

                    // Doctor Stats
                    _buildDoctorStats(context),

                    const SizedBox(height: 24),

                    // Book Appointment Button
                    _buildBookAppointmentButton(context),

                    const SizedBox(height: 30),

                    // Reviews Section
                    _buildReviewsSection(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget _buildActionButtons(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       _buildActionButton(
  //         icon: Icons.call,
  //         label: 'Voice Call',
  //         color: Colors.blue,
  //         onPressed: () {},
  //       ),
  //       _buildActionButton(
  //         icon: Icons.video_call,
  //         label: 'Video Call',
  //         color: Colors.purple,
  //         onPressed: () {},
  //       ),
  //     ],
  //   );
  // }

  Widget _buildBiographySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Biography',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          doctor.about.isEmpty ? 'No description available.' : doctor.about,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDynamicPatientCountStatistic(String doctorId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'Visited')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }
        if (snapshot.hasError) {
          return const Text('Error');
        }

        // Collect unique patient IDs from visited appointments
        final seenPatients = <String>{};
        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['userId'] != null) {
              seenPatients.add(data['userId'] as String);
            }
          }
        }

        return Column(
          children: [
            Text(
              '${seenPatients.length}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Patients',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDoctorStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDynamicPatientCountStatistic(doctor.id),
        _buildStatistic('Experience', '${doctor.experience} Years'),
        _buildDynamicReviewStatistic(context, doctor.id),
      ],
    );
  }

  Widget _buildBookAppointmentButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final amountToPay = 100.0; // Specify your appointment fee here

        // SSLCOMMERZ payment setup
        Sslcommerz sslcommerz = Sslcommerz(
          initializer: SSLCommerzInitialization(
            ipn_url: "https://your-ipn-url.com", // optional IPN url
            multi_card_name: "",
            currency: SSLCurrencyType.BDT,
            product_category: "Appointment",
            sdkType: SSLCSdkType.TESTBOX, // Change to LIVE in production
            store_id: "zeroo6890512f607a2", // replace with valid store id
            store_passwd:
                "zeroo6890512f607a2@ssl", // replace with valid store password
            total_amount: amountToPay,
            tran_id: "tran_${DateTime.now().millisecondsSinceEpoch}",
          ),
        );

        try {
          SSLCTransactionInfoModel result = await sslcommerz.payNow();

          final paymentStatus = result.status?.toLowerCase();
          if (paymentStatus == 'success' || paymentStatus == 'valid') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentPage(doctor: doctor),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Payment successful. Proceed to booking.')),
            );
          } else if (paymentStatus == 'failed') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Payment failed. Please try again.')),
            );
          } else if (paymentStatus == 'closed') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment cancelled.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment status: ${result.status}')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment error: $e')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'Book an Appointment',
        style: TextStyle(fontSize: 16, color: AppColors.primaryColor),
      ),
    );
  }

  /// Builds the Reviews section header with live review count
  Widget _buildReviewsSection(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('doctorId', isEqualTo: doctor.id)
          .snapshots(),
      builder: (context, snapshot) {
        int reviewCount = 0;
        if (snapshot.hasData) {
          reviewCount = snapshot.data!.docs.length;
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Reviews',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                if (reviewCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      reviewCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Your existing RatingForm widget below will show ratings and allow submission
            RatingForm(doctorId: doctor.id),
          ],
        );
      },
    );
  }
}

Widget _buildStatistic(String label, String value) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
    ],
  );
}

// Dynamically fetch and display the review count
Widget _buildDynamicReviewStatistic(BuildContext context, String doctorId) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('reviews')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text('Loading...');
      }
      if (snapshot.hasError) {
        return const Text('Error');
      }

      final reviewCount = snapshot.data?.docs.length ?? 0;

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewsPage(doctorId: doctorId),
            ),
          );
        },
        child: Column(
          children: [
            Text(
              "See",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Text(
              'Reviews',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildActionButton({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onPressed,
}) {
  return Column(
    children: [
      IconButton(
        icon: Icon(icon, size: 30, color: color),
        onPressed: onPressed,
      ),
      Text(label, style: TextStyle(color: color)),
    ],
  );
}

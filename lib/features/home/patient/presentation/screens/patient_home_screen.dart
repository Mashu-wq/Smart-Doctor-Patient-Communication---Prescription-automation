import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';
import 'package:medisafe/features/authentication/patient/presentation/controllers/notifications_controller.dart';
import 'package:medisafe/features/home/doctor/presentation/controllers/categories_controller.dart';
import 'package:medisafe/features/home/doctor/presentation/controllers/doctors_controller.dart';

import 'package:medisafe/features/home/doctor/presentation/screens/doctor_details_screen.dart';
import 'package:medisafe/features/home/patient/presentation/screens/CategoryDoctorsScreen.dart';
import 'package:medisafe/features/home/patient/presentation/screens/notification/notifications_screen.dart';
import 'package:medisafe/features/home/patient/presentation/screens/search_doctor_screen.dart';
import 'package:medisafe/features/home/patient/presentation/widgets/customBottomNavigationBar.dart';
import 'package:medisafe/models/category_model.dart';
import 'package:medisafe/models/doctor_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _shouldShowBadge(DateTime latestNotificationTime) {
  final now = DateTime.now();

  // read from SharedPreferences
  SharedPreferences.getInstance().then((prefs) {
    final lastSeenMillis = prefs.getInt('last_seen_notification_time') ?? 0;
    final lastSeenTime = DateTime.fromMillisecondsSinceEpoch(lastSeenMillis);

    // Check if latest notification is newer than last seen
    return latestNotificationTime.isAfter(lastSeenTime);
  });

  return true; // default true if no data found
}

class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsState = ref.watch(doctorsControllerProvider);
    final categoriesState = ref.watch(categoriesControllerProvider);
    final notificationStream = ref.watch(notificationProvider);

    ref.listen(notificationProvider, (previous, next) {
      final previousValue = previous?.value ?? 0;
      final nextValue = next.value ?? 0;

      if (nextValue > previousValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🔔 New Notification! Check your notifications"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.appColor,
      appBar: _buildAppBar(context, ref),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600; // Detects web layout
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 60 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBanner(isWeb),
                  const SizedBox(height: 20),
                  _buildCategoriesSection(context, categoriesState),
                  const SizedBox(height: 20),
                  _buildDoctorsSection(doctorsState),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    final notificationCountAsync = ref.watch(notificationProvider);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Pacifico(text: "Find Your Specialist", size: 20.0),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchDoctorScreen(),
              ),
            );
          },
        ),
        notificationCountAsync.when(
          data: (count) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none,
                      color: Colors.black, size: 28),
                  onPressed: () {
                    ref.invalidate(notificationProvider); // reset on tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
                if (count > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, stack) => const Icon(Icons.error, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildBanner(bool isWeb) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSingleBanner(
              title: 'Looking For Your Desire Specialist Doctor?',
              name: 'Cardiologist',
              specialization: 'General & Neurologist',
              clinic: 'Good Health Clinic',
              width: isWeb ? 350 : 300,
            ),
            _buildSingleBanner(
              title: 'Need a Neurologist?',
              name: 'Psychiatrist',
              specialization: 'General & Neurologist',
              clinic: 'Brain Health Clinic',
              width: isWeb ? 350 : 300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleBanner({
    required String title,
    required String name,
    required String specialization,
    required String clinic,
    required double width,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: width,
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.buttonColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OpenSans(
                text: title,
                size: 16.0,
                color: AppColors.appColor,
              ),
              const SizedBox(height: 8),
              Text(
                '$name\n$specialization\n$clinic',
                style: const TextStyle(
                  color: AppColors.appColor,
                  fontSize: 16,
                  //fontWeight: FontWeight.bold,
                  height: 1.2,
                  fontFamily: 'OpenSans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(
      BuildContext context, AsyncValue<List<Category>> categoriesState) {
    return categoriesState.when(
      data: (categories) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Poppins(
              text: "Categories",
              size: 20.0,
            ),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories
                  .map((category) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CategoryDoctorsScreen(category: category),
                            ),
                          );
                        },
                        child: _buildCategoryTile(category),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text('Error: $e'),
      ),
    );
  }

  Widget _buildCategoryTile(Category category) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.appColor,
            backgroundImage: AssetImage(category.iconPath),
            radius: 30,
          ),
          const SizedBox(height: 4),
          Text(category.name,
              style: const TextStyle(
                fontSize: 14,
                //fontWeight: FontWeight.bold,
                color: AppColors.buttonColor,
                fontFamily: 'OpenSans',
              )),
        ],
      ),
    );
  }

  Widget _buildDoctorsSection(AsyncValue<List<Doctor>> doctorsState) {
    return doctorsState.when(
      data: (doctors) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Poppins(
              text: "Available Doctors",
              size: 20.0,
              color: AppColors.buttonColor,
              //fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              return _buildDoctorCard(context, doctors[index]);
            },
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error: $e'),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDetailsScreen(
              doctor: doctor,
              patiendId: '',
            ),
          ),
        );
      },
      child: Card(
        color: AppColors.primaryColor,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(doctor.profileImageUrl),
            radius: 30,
          ),
          title: Text(doctor.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.buttonColor)),
          subtitle: Text(
            '${doctor.specialization} • ${doctor.experience} years experience',
            style: TextStyle(
              color: AppColors.buttonColor,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String id;
  final String name;
  final String email;
  final String specialization;
  final int experience;
  final int patients;
  final String clinicName;
  final String qualifications;
  final String availableTime;
  final String area;
  final String about;
  final String profileImageUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.specialization,
    required this.experience,
    required this.patients,
    required this.clinicName,
    required this.qualifications,
    required this.availableTime,
    required this.area,
    required this.about,
    required this.profileImageUrl,
  });

  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Doctor data is missing");
    }

    return Doctor(
      id: doc.id,
      name: data['doctor_name'] ?? 'Unknown Doctor',
      email: data['email'] ?? '',
      specialization: data['specialization'] ?? 'General',
      experience: data['experience'] ?? 0,
      patients: data['patients'] ?? 0,
      clinicName: data['clinic_name'] ?? 'Unknown Clinic',
      qualifications: data['qualifications'] ?? 'N/A',
      availableTime: data['available_time'] ?? 'N/A',
      area: data['area'] ?? 'N/A',
      about: data['about'] ?? 'N/A',
      profileImageUrl: data['profile_image_url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctor_name': name,
      'email': email,
      'specialization': specialization,
      'experience': experience,
      'patients': patients,
      'clinic_name': clinicName,
      'qualifications': qualifications,
      'available_time': availableTime,
      'area': area,
      'about': about,
      'profile_image_url': profileImageUrl,
    };
  }

  // Future<void> addDoctorToFirestore() async {
  //   try {
  //     final doctorRef =
  //         FirebaseFirestore.instance.collection('doctors').doc(id);

  //     // Set the main doctor document
  //     await doctorRef.set(toMap());

  //     // Create subcollection 'doctorId' under the doctor document
  //     await doctorRef.collection('doctorId').add({
  //       'available_slots': {
  //         '2024-11-01': ['09:00 AM', '10:00 AM'],
  //         '2024-11-02': ['02:00 PM', '03:00 PM'],
  //       },
  //     });

  //     print('Doctor and doctorId subcollection added successfully!');
  //   } catch (e) {
  //     print('Error adding doctor to Firestore: $e');
  //   }
  // }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisafe/models/doctor_model.dart';
import 'package:medisafe/models/search_filter_model.dart';

class DoctorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Doctor>> fetchDoctors() {
    try {
      return _firestore.collection('doctors').snapshots().map((querySnapshot) {
        return querySnapshot.docs
            .map((doc) => Doctor.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception("Failed to fetch doctors: $e");
    }
  }

  Future<List<Doctor>> searchDoctors(SearchFilter filter) async {
    Query query = _firestore.collection('doctors');

    if (filter.area != null && filter.area!.isNotEmpty) {
      query = query.where('area', isEqualTo: filter.area);
    }

    if (filter.category != null && filter.category!.isNotEmpty) {
      query = query.where('category', isEqualTo: filter.category);
    }

    if (filter.date != null) {
      query = query.where('available_dates', arrayContains: filter.date);
    }

    QuerySnapshot snapshot = await query.get();
    return snapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList();
  }

  Future<Doctor> fetchDoctorProfile(String id) async {
    final doc = await _firestore.collection('doctors').doc(id).get();
    return Doctor.fromFirestore(doc);
  }

  Future<void> updateDoctorProfile(String id, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(id)
          .update(data);
    } catch (e) {
      throw Exception("Failed to update doctor profile: $e");
    }
  }

  Stream<Doctor> streamDoctorProfile(String id) {
    return _firestore.collection('doctors').doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw Exception("Doctor profile not found");
      }
      return Doctor.fromFirestore(snapshot);
    });
  }

  // Add available slots to a doctor's subcollection
  Future<void> addAvailableSlots(String doctorId, List<String> slots) async {
    try {
      // Adding available slots as a subcollection under the specific doctor document
      final doctorRef = _firestore.collection('doctors').doc(doctorId);
      final availableSlotsRef = doctorRef.collection('available_slots');

      // Assuming 'slots' is a list of date-time slots (strings) to store in Firestore
      for (var slot in slots) {
        await availableSlotsRef.add({
          'slot': slot,
          'isBooked':
              false, // You can add any additional field to manage slot status
        });
      }
    } catch (e) {
      throw Exception("Failed to add available slots: $e");
    }
  }

  // Fetch available slots of a specific doctor
  Stream<List<Map<String, dynamic>>> fetchAvailableSlots(String doctorId) {
    try {
      // Fetching the available slots subcollection for the specific doctor
      final availableSlotsRef = _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('available_slots');

      return availableSlotsRef.snapshots().map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return doc.data();
        }).toList();
      });
    } catch (e) {
      throw Exception("Failed to fetch available slots: $e");
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisafe/features/home/doctor/data/repositories/rating_repository.dart';
import 'package:medisafe/features/home/doctor/domain/Entity/rating.dart';

class FirebaseRatingRepository implements RatingRepository {
  final FirebaseFirestore firestore;

  FirebaseRatingRepository(this.firestore);

  @override
  Future<void> submitRating(Rating rating) async {
    await firestore.collection('ratings').add({
      'doctorId': rating.doctorId,
      'patientId': rating.patientId,
      'rating': rating.rating,
      'comment': rating.comment,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Rating>> getRatings(String doctorId) {
    return firestore
        .collection('ratings')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Rating(
                id: doc.id,
                doctorId: data['doctorId'] ?? '',
                patientId: data['patientId'] ?? '',
                rating: (data['rating'] as num).toDouble(),
                comment: data['comment'] ?? '',
                timestamp: (data['timestamp'] as Timestamp).toDate(),
              );
            }).toList());
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

Future<void> addMissingRoomIds() async {
  final firestore = FirebaseFirestore.instance;
  final appointments = await firestore.collection('appointments').get();

  for (var doc in appointments.docs) {
    if (!doc.data().containsKey('roomId')) {
      final String roomId = const Uuid().v4(); // Generate a unique roomId
      await firestore.collection('appointments').doc(doc.id).update({
        'roomId': roomId,
      });
      print('Added roomId $roomId to document ${doc.id}');
    }
  }
  print('All missing roomIds have been updated.');
}

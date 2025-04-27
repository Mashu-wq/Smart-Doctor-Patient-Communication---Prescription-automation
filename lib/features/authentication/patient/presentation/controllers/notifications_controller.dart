import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final notificationProvider = StreamProvider<int>((ref) {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) {
    return const Stream<int>.empty();
  }

  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: currentUserId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

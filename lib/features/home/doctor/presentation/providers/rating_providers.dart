// Repository Provider
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisafe/features/home/doctor/data/Firebase_Repository/firebase_rating_repository.dart';
import 'package:medisafe/features/home/doctor/data/repositories/rating_repository.dart';
import 'package:medisafe/features/home/doctor/domain/Entity/rating.dart';
import 'package:medisafe/features/home/doctor/domain/usecases/submitRatingUsecase.dart';
import 'package:riverpod/riverpod.dart';

final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return FirebaseRatingRepository(FirebaseFirestore.instance);
});

// Use Case Providers
final submitRatingUseCaseProvider = Provider<SubmitRatingUseCase>((ref) {
  return SubmitRatingUseCase(ref.read(ratingRepositoryProvider));
});

final getRatingsUseCaseProvider = Provider<GetRatingsUseCase>((ref) {
  return GetRatingsUseCase(ref.read(ratingRepositoryProvider));
});

// Ratings Stream Provider
final ratingsStreamProvider =
    StreamProvider.family<List<Rating>, String>((ref, doctorId) {
  return ref.read(getRatingsUseCaseProvider).call(doctorId);
});

import 'package:medisafe/features/home/doctor/domain/Entity/rating.dart';

abstract class RatingRepository {
  Future<void> submitRating(Rating rating);
  Stream<List<Rating>> getRatings(String doctorId);
}

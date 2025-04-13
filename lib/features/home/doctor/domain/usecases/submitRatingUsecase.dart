import 'package:medisafe/features/home/doctor/data/repositories/rating_repository.dart';
import 'package:medisafe/features/home/doctor/domain/Entity/rating.dart';

class SubmitRatingUseCase {
  final RatingRepository repository;

  SubmitRatingUseCase(this.repository);

  Future<void> call(Rating rating) async {
    return await repository.submitRating(rating);
  }
}

class GetRatingsUseCase {
  final RatingRepository repository;

  GetRatingsUseCase(this.repository);

  Stream<List<Rating>> call(String doctorId) {
    return repository.getRatings(doctorId);
  }
}

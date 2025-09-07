import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart'; // Import intl for time formatting
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';
import 'package:medisafe/features/home/doctor/presentation/providers/rating_providers.dart';

class ReviewsPage extends ConsumerWidget {
  final String doctorId;

  const ReviewsPage({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsState = ref.watch(ratingsStreamProvider(doctorId));

    return Scaffold(
      appBar: AppBar(
        title: Pacifico(text: "Rating and Reviews", size: 25.0),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: ratingsState.when(
        data: (ratings) => _buildReviewsContent(context, ratings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildReviewsContent(BuildContext context, List ratings) {
    final overallRating = _calculateAverageRating(ratings);
    final starCounts = _calculateStarCounts(ratings);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Average Rating Section
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                overallRating.toStringAsFixed(1), // Display fractional rating
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              RatingBarIndicator(
                rating: overallRating,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 30.0,
                direction: Axis.horizontal,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${ratings.length} reviews',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Star Breakdown
          ..._buildStarBreakdown(starCounts),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // User Reviews Section
          const Text(
            'User Reviews',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...ratings.map((rating) => _buildReviewTile(rating)),
        ],
      ),
    );
  }

  Widget _buildReviewTile(rating) {
    // Safely handle both DateTime and Timestamp types
    final DateTime commentTime = rating.timestamp is Timestamp
        ? rating.timestamp.toDate() // Convert Firestore Timestamp to DateTime
        : rating.timestamp; // Use DateTime directly

    // Format the timestamp for date and time separately
    final formattedDate = DateFormat('dd/MM/yyyy').format(commentTime);
    final formattedTime = DateFormat('hh:mm a').format(commentTime);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('patients')
          .doc(rating.patientId)
          .get(),
      builder: (context, snapshot) {
        final patientData = snapshot.data?.data() as Map<String, dynamic>?;
        final name = patientData?['first_name'] ?? 'Unknown';
        final profileImageUrl = patientData?['profile_image_url'] ??
            'assets/images/default_avatar.png';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: profileImageUrl.startsWith('http')
                      ? NetworkImage(profileImageUrl)
                      : AssetImage(profileImageUrl) as ImageProvider,
                  radius: 25,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display Name and Date/Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formattedDate, // Display the date
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                formattedTime, // Display the time
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Display Star Rating
                      RatingBarIndicator(
                        rating: rating.rating, // Display fractional rating
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 18.0,
                      ),
                      const SizedBox(height: 4),
                      // Display Comment
                      Text(
                        rating.comment,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildStarBreakdown(Map<int, int> starCounts) {
    return List.generate(5, (index) {
      final starCount = starCounts[5 - index] ?? 0;
      final total = starCounts.values.fold(0, (sum, count) => sum + count);
      final percentage = total > 0 ? (starCount / total) : 0.0;

      return Row(
        children: [
          Text('${5 - index}'),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              color: Colors.amber,
              minHeight: 10,
            ),
          ),
          const SizedBox(width: 8),
          Text('$starCount'),
        ],
      );
    });
  }

  double _calculateAverageRating(List ratings) {
    if (ratings.isEmpty) return 0.0;
    final total = ratings.fold(0.0, (sum, r) => sum + r.rating);
    return total / ratings.length;
  }

  Map<int, int> _calculateStarCounts(List ratings) {
    final starCounts = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      starCounts[i] = ratings.where((r) => r.rating.round() == i).length;
    }
    return starCounts;
  }
}

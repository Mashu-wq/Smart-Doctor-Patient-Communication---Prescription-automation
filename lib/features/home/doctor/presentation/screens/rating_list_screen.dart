import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/home/doctor/presentation/providers/rating_providers.dart';

class RatingsList extends ConsumerWidget {
  final String doctorId;

  const RatingsList({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsAsync = ref.watch(ratingsStreamProvider(doctorId));

    return ratingsAsync.when(
      data: (ratings) {
        if (ratings.isEmpty) {
          return const Center(child: Text('No ratings yet.'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ratings.length,
          itemBuilder: (context, index) {
            final rating = ratings[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(rating.rating.toStringAsFixed(1)),
              ),
              title: Text(rating.comment),
              subtitle: Text('Patient ID: ${rating.patientId}'),
              trailing: Text(
                '${rating.timestamp}',
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) => Center(child: Text('Error: $e')),
    );
  }
}

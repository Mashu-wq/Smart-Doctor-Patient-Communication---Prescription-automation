import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/home/doctor/domain/Entity/rating.dart';
import 'package:medisafe/features/home/doctor/presentation/providers/rating_providers.dart';

class RatingForm extends ConsumerStatefulWidget {
  final String doctorId;

  const RatingForm({super.key, required this.doctorId});

  @override
  ConsumerState<RatingForm> createState() => _RatingFormState();
}

class _RatingFormState extends ConsumerState<RatingForm> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _submitRating() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (_rating == 0.0 || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and comment')),
      );
      return;
    }

    final rating = Rating(
      id: '',
      doctorId: widget.doctorId,
      patientId: userId,
      rating: _rating,
      comment: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );

    await ref.read(submitRatingUseCaseProvider).call(rating);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating submitted successfully')),
    );

    // Clear form
    setState(() {
      _rating = 0.0;
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rate and Comment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text('Rating:'),
            Expanded(
              child: Slider(
                value: _rating,
                min: 0.0,
                max: 5.0,
                divisions: 10,
                label: _rating.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
              ),
            ),
          ],
        ),
        TextField(
          controller: _commentController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Leave a comment',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _submitRating,
          child: const Text('Submit Rating'),
        ),
      ],
    );
  }
}

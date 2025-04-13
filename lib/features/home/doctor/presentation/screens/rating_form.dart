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
  int _selectedRating = 0; // Holds the selected star rating
  final TextEditingController _commentController = TextEditingController();

  Future<void> _submitRating() async {
    if (_selectedRating == 0 || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and comment')),
      );
      return;
    }

    final rating = Rating(
      id: '',
      doctorId: widget.doctorId,
      patientId: 'patientId', // Replace with the actual patient ID
      rating: _selectedRating.toDouble(),
      comment: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );

    await ref.read(submitRatingUseCaseProvider).call(rating);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating submitted successfully')),
    );

    // Clear the form
    setState(() {
      _selectedRating = 0;
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text(
        //   'Rate and Comment',
        //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        // ),
        const SizedBox(height: 10),

        // 5-Star Rating Section
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _selectedRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 35,
              ),
              onPressed: () {
                setState(() {
                  _selectedRating = index + 1; // Update the rating
                });
              },
            );
          }),
        ),

        const SizedBox(height: 10),

        // Comment Input Field
        TextField(
          controller: _commentController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Leave a comment',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 10),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitRating,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

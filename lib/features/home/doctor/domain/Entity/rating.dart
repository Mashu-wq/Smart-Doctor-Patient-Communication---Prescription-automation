class Rating {
  final String id;
  final String doctorId;
  final String patientId;
  final double rating;
  final String comment;
  final DateTime timestamp;

  Rating({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });
}

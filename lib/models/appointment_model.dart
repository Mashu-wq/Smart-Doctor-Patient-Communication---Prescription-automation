class Appointment {
  final String patientName;
  final String date;
  final String time;
  final String status;
  final String paymentStatus;
  final String details;

  Appointment({
    required this.patientName,
    required this.date,
    required this.time,
    required this.status,
    required this.paymentStatus,
    required this.details,
  });

  factory Appointment.fromFirestore(Map<String, dynamic> data) {
    return Appointment(
      patientName: data['patientName'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      status: data['status'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      details: data['details'] ?? '',
    );
  }
}

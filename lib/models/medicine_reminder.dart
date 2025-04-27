class MedicationReminder {
  final String medicine;
  final String dosage;
  final String advice;
  final List<String> times;

  MedicationReminder({
    required this.medicine,
    required this.dosage,
    required this.advice,
    required this.times,
  });

  factory MedicationReminder.fromMap(Map<String, dynamic> map) {
    return MedicationReminder(
      medicine: map['medicine'],
      dosage: map['dosage'],
      advice: map['advice'],
      times: List<String>.from(map['times']),
    );
  }
}

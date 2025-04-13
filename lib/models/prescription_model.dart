class Prescription {
  final String id;
  final String patientId;
  final String patientName;
  final int patientAge;
  final List<Medicine> medicines;
  final DateTime nextConsultancyDate;

  Prescription({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.medicines,
    required this.nextConsultancyDate,
  });

  factory Prescription.fromMap(Map<String, dynamic> data, String documentId) {
    return Prescription(
      id: documentId,
      patientId: data['patientId'],
      patientName: data['patientName'],
      patientAge: data['patientAge'],
      medicines: (data['medicines'] as List<dynamic>)
          .map((medicine) => Medicine.fromMap(medicine))
          .toList(),
      nextConsultancyDate: DateTime.parse(data['nextConsultancyDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'patientAge': patientAge,
      'medicines': medicines.map((medicine) => medicine.toMap()).toList(),
      'nextConsultancyDate': nextConsultancyDate.toIso8601String(),
    };
  }
}

class Medicine {
  final String name;
  final String time; // Example: "Morning, Evening"
  final String dose; // Example: "1 Tablet"

  Medicine({
    required this.name,
    required this.time,
    required this.dose,
  });

  factory Medicine.fromMap(Map<String, dynamic> data) {
    return Medicine(
      name: data['name'],
      time: data['time'],
      dose: data['dose'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'time': time,
      'dose': dose,
    };
  }
}

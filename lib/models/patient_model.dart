class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String contactNumber;
  final String address;
  final String profileImageUrl;
   final String? prescription; // Add prescription as nullable

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.contactNumber,
    required this.address,
    required this.profileImageUrl,
    this.prescription, // Mark as optional
  });

  factory Patient.fromFirestore(Map<String, dynamic> data, String id) {
    return Patient(
      id: id,
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      email: data['email'] ?? '',
      contactNumber: data['contact_number'] ?? '',
      address: data['address'] ?? '',
      profileImageUrl: data['profile_image_url'] ?? '',
      prescription: data['prescription'], // Map prescription field
    );
  }
}

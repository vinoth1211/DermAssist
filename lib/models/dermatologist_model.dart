class DermatologistModel {
  final String id;
  final String name;
  final String qualification;
  final String hospital;
  final String experience;
  final String address;
  final String phoneNumber;
  final String email;
  final String? imageUrl;
  final double rating;
  final List<String>? specializations;
  final List<Map<String, dynamic>>? availableSlots;
  final int consultationFee;

  DermatologistModel({
    required this.id,
    required this.name,
    required this.qualification,
    required this.hospital,
    required this.experience,
    required this.address,
    required this.phoneNumber,
    required this.email,
    this.imageUrl,
    required this.rating,
    this.specializations,
    this.availableSlots,
    required this.consultationFee,
  });

  // Create a DermatologistModel from Firestore data
  factory DermatologistModel.fromMap(Map<String, dynamic> data, String documentId) {
    return DermatologistModel(
      id: documentId,
      name: data['name'] ?? '',
      qualification: data['qualification'] ?? '',
      hospital: data['hospital'] ?? '',
      experience: data['experience'] ?? '',
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['imageUrl'],
      rating: (data['rating'] ?? 0).toDouble(),
      specializations: data['specializations'] != null ? List<String>.from(data['specializations']) : null,
      availableSlots: data['availableSlots'] != null ? List<Map<String, dynamic>>.from(data['availableSlots']) : null,
      consultationFee: data['consultationFee'] ?? 0,
    );
  }

  // Convert DermatologistModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'qualification': qualification,
      'hospital': hospital,
      'experience': experience,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'imageUrl': imageUrl,
      'rating': rating,
      'specializations': specializations,
      'availableSlots': availableSlots,
      'consultationFee': consultationFee,
    };
  }
}

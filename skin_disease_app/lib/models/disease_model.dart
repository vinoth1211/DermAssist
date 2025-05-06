class DiseaseModel {
  final String id;
  final String name;
  final String description;
  final List<String> symptoms;
  final List<String> treatments;
  final String? imageUrl;
  final double severity;
  final bool isContagious;
  final String? category;

  DiseaseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.symptoms,
    required this.treatments,
    this.imageUrl,
    required this.severity,
    required this.isContagious,
    this.category,
  });

  // Create a DiseaseModel from Firestore data
  factory DiseaseModel.fromMap(Map<String, dynamic> data, String documentId) {
    return DiseaseModel(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      symptoms: data['symptoms'] != null ? List<String>.from(data['symptoms']) : [],
      treatments: data['treatments'] != null ? List<String>.from(data['treatments']) : [],
      imageUrl: data['imageUrl'],
      severity: (data['severity'] ?? 0).toDouble(),
      isContagious: data['isContagious'] ?? false,
      category: data['category'],
    );
  }

  // Convert DiseaseModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'symptoms': symptoms,
      'treatments': treatments,
      'imageUrl': imageUrl,
      'severity': severity,
      'isContagious': isContagious,
      'category': category,
    };
  }
}

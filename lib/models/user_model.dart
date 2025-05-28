class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phoneNumber;
  final String? profileImageUrl;
  final List<String>? savedArticles;
  final List<String>? medicalHistory;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phoneNumber,
    this.profileImageUrl,
    this.savedArticles,
    this.medicalHistory,
  });

  // Create a UserModel from Firestore data
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      savedArticles: data['savedArticles'] != null ? List<String>.from(data['savedArticles']) : null,
      medicalHistory: data['medicalHistory'] != null ? List<String>.from(data['medicalHistory']) : null,
    );
  }

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'savedArticles': savedArticles,
      'medicalHistory': medicalHistory,
    };
  }

  // Create a copy of the current user with modified fields
  UserModel copyWith({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    List<String>? savedArticles,
    List<String>? medicalHistory,
  }) {
    return UserModel(
      uid: this.uid,
      email: this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      savedArticles: savedArticles ?? this.savedArticles,
      medicalHistory: medicalHistory ?? this.medicalHistory,
    );
  }
}

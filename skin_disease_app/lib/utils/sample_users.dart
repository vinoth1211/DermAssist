import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skin_disease_app/models/user_model.dart';

// Sample user data for testing
final List<Map<String, dynamic>> sampleUsers = [
  {
    'uid': 'user1',
    'email': 'john.doe@example.com',
    'name': 'John Doe',
    'phoneNumber': '+1234567890',
    'profileImageUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
  },
  {
    'uid': 'user2',
    'email': 'jane.smith@example.com',
    'name': 'Jane Smith',
    'phoneNumber': '+1987654321',
    'profileImageUrl': 'https://randomuser.me/api/portraits/women/1.jpg',
  },
  {
    'uid': 'user3',
    'email': 'alex.wong@example.com',
    'name': 'Alex Wong',
    'phoneNumber': '+1122334455',
    'profileImageUrl': 'https://randomuser.me/api/portraits/men/2.jpg',
  },
];

// Function to add sample users to Firestore
Future<void> addSampleUsers() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  for (var userData in sampleUsers) {
    final userModel = UserModel(
      uid: userData['uid'],
      email: userData['email'],
      name: userData['name'],
      phoneNumber: userData['phoneNumber'],
      profileImageUrl: userData['profileImageUrl'],
    );
    
    // Check if user already exists
    final docRef = firestore.collection('users').doc(userData['uid']);
    final docSnapshot = await docRef.get();
    
    if (!docSnapshot.exists) {
      await docRef.set(userModel.toMap());
      print('Added user: ${userData['name']}');
    } else {
      print('User ${userData['name']} already exists, skipping...');
    }
  }
  
  print('Sample users added successfully!');
}

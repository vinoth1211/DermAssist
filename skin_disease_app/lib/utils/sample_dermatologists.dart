import 'package:cloud_firestore/cloud_firestore.dart';

// Sample dermatologist data for testing
final List<Map<String, dynamic>> sampleDermatologists = [
  {
    'id': 'derm1',
    'name': 'Dr. Sarah Johnson',
    'qualification': 'MD, Dermatology',
    'hospital': 'City Medical Center',
    'experience': '10 years',
    'address': '123 Medical Plaza, New York, NY 10001',
    'phoneNumber': '+1(212)555-1234',
    'email': 'sarah.johnson@citymedical.com',
    'imageUrl': 'https://randomuser.me/api/portraits/women/22.jpg',
    'rating': 4.8,
    'specializations': ['Medical Dermatology', 'Skin Cancer', 'Acne Treatment'],
    'availableDays': ['Monday', 'Wednesday', 'Friday'],
    'availableTimeSlots': {
      'Monday': ['09:00 AM', '10:00 AM', '11:00 AM', '2:00 PM', '3:00 PM'],
      'Wednesday': ['09:00 AM', '10:00 AM', '11:00 AM', '2:00 PM', '3:00 PM'],
      'Friday': ['09:00 AM', '10:00 AM', '11:00 AM'],
    },
    'consultationFee': 150,
  },
  {
    'id': 'derm2',
    'name': 'Dr. Michael Chen',
    'qualification': 'MD, PhD, Dermatopathology',
    'hospital': 'University Hospital',
    'experience': '15 years',
    'address': '456 University Blvd, Boston, MA 02215',
    'phoneNumber': '+1(617)555-7890',
    'email': 'michael.chen@unihealth.org',
    'imageUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
    'rating': 4.9,
    'specializations': ['Pediatric Dermatology', 'Eczema', 'Psoriasis'],
    'availableDays': ['Tuesday', 'Thursday'],
    'availableTimeSlots': {
      'Tuesday': [
        '09:00 AM',
        '10:00 AM',
        '11:00 AM',
        '2:00 PM',
        '3:00 PM',
        '4:00 PM',
      ],
      'Thursday': ['09:00 AM', '10:00 AM', '11:00 AM', '2:00 PM', '3:00 PM'],
    },
    'consultationFee': 180,
  },
  {
    'id': 'derm3',
    'name': 'Dr. Jessica Martinez',
    'qualification': 'MD, Dermatology & Cosmetic Surgery',
    'hospital': 'Derma Wellness Center',
    'experience': '8 years',
    'address': '789 Beach Drive, Miami, FL 33139',
    'phoneNumber': '+1(305)555-4321',
    'email': 'jessica.martinez@dermawellness.com',
    'imageUrl': 'https://randomuser.me/api/portraits/women/45.jpg',
    'rating': 4.7,
    'specializations': [
      'Cosmetic Dermatology',
      'Laser Treatments',
      'Botox & Fillers',
    ],
    'availableDays': ['Monday', 'Wednesday', 'Friday'],
    'availableTimeSlots': {
      'Monday': ['2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'],
      'Wednesday': ['1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'],
      'Friday': ['1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM'],
    },
    'consultationFee': 200,
  },
  {
    'id': 'derm4',
    'name': 'Dr. Robert Williams',
    'qualification': 'MD, Dermatology, FAAD',
    'hospital': 'Central Dermatology Clinic',
    'experience': '20 years',
    'address': '101 Main Street, Chicago, IL 60601',
    'phoneNumber': '+1(312)555-6789',
    'email': 'robert.williams@centralderm.org',
    'imageUrl': 'https://randomuser.me/api/portraits/men/67.jpg',
    'rating': 4.9,
    'specializations': ['Skin Cancer', 'Mohs Surgery', 'Clinical Research'],
    'availableDays': ['Tuesday', 'Thursday'],
    'availableTimeSlots': {
      'Tuesday': ['08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM'],
      'Thursday': ['08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM'],
    },
    'consultationFee': 175,
  },
];

// Function to add sample dermatologists to Firestore
Future<void> addSampleDermatologists() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  for (var dermData in sampleDermatologists) {
    final docRef = firestore.collection('dermatologists').doc(dermData['id']);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set(dermData);
      print('Added dermatologist: ${dermData['name']}');
    } else {
      print('Dermatologist ${dermData['name']} already exists, skipping...');
    }
  }

  print('Sample dermatologists added successfully!');
}

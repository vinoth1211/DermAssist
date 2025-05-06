import 'package:cloud_firestore/cloud_firestore.dart';

// Sample appointment data for testing
final List<Map<String, dynamic>> sampleAppointments = [
  {
    'id': 'appt1',
    'userId': 'user1',
    'dermatologistId': 'derm1',
    'date': DateTime(2024, 5, 20, 10, 0), // May 20, 2024, 10:00 AM
    'status': 'scheduled',
    'reason': 'Annual skin check',
    'notes': 'Patient reported new mole on back',
  },
  {
    'id': 'appt2',
    'userId': 'user1',
    'dermatologistId': 'derm2',
    'date': DateTime(2024, 5, 25, 14, 30), // May 25, 2024, 2:30 PM
    'status': 'scheduled',
    'reason': 'Follow-up for eczema treatment',
    'notes': 'Check if medication is working',
  },
  {
    'id': 'appt3',
    'userId': 'user2',
    'dermatologistId': 'derm1',
    'date': DateTime(2024, 6, 5, 9, 15), // June 5, 2024, 9:15 AM
    'status': 'scheduled',
    'reason': 'Acne consultation',
    'notes': 'Discuss treatment options for persistent acne',
  },
  {
    'id': 'appt4',
    'userId': 'user3',
    'dermatologistId': 'derm3',
    'date': DateTime(2024, 6, 10, 11, 0), // June 10, 2024, 11:00 AM
    'status': 'scheduled',
    'reason': 'Psoriasis treatment',
    'notes': 'Review current treatment plan and adjust if necessary',
  },
  {
    'id': 'appt5',
    'userId': 'user2',
    'dermatologistId': 'derm2',
    'date': DateTime(2024, 5, 15, 16, 0), // May 15, 2024, 4:00 PM
    'status': 'completed',
    'reason': 'Skin rash examination',
    'notes': 'Prescribed antihistamines and topical cream',
  },
];

// Function to add sample appointments to Firestore
Future<void> addSampleAppointments() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  for (var appointmentData in sampleAppointments) {
    final String id = appointmentData['id'];
    final docRef = firestore.collection('appointments').doc(id);
    final docSnapshot = await docRef.get();
    
    if (!docSnapshot.exists) {
      // Convert DateTime to Timestamp for Firestore
      final Map<String, dynamic> firestoreData = {...appointmentData};
      firestoreData['date'] = Timestamp.fromDate(appointmentData['date']);
      
      await docRef.set(firestoreData);
      print('Added appointment: ${appointmentData['id']}');
    } else {
      print('Appointment "${appointmentData['id']}" already exists, skipping...');
    }
  }
  
  print('Sample appointments added successfully!');
}

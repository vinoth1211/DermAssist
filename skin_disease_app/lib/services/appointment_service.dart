import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skin_disease_app/models/dermatologist_model.dart';
import 'package:skin_disease_app/models/appointment_model.dart';

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final String imageUrl;
  final String about;
  final double rating;
  final String hospital;
  final String address;
  final List<String> availableDays;
  final Map<String, List<String>> availableTimeSlots;
  final int consultationFee;
  
  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.imageUrl,
    required this.about,
    required this.rating,
    required this.hospital,
    required this.address,
    required this.availableDays,
    required this.availableTimeSlots,
    required this.consultationFee,
  });
  
  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Doctor(
      id: doc.id,
      name: data['name'] ?? '',
      specialization: data['specialization'] ?? '',
      experience: data['experience'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      about: data['about'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      hospital: data['hospital'] ?? '',
      address: data['address'] ?? '',
      availableDays: List<String>.from(data['availableDays'] ?? []),
      availableTimeSlots: Map<String, List<String>>.from(
        (data['availableTimeSlots'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value))
        ),
      ),
      consultationFee: data['consultationFee'] ?? 0,
    );
  }
}

class Appointment {
  final String id;
  final String userId;
  final String doctorId;
  final String doctorName;
  final String userFullName;
  final DateTime appointmentDate;
  final String timeSlot;
  final String status; // scheduled, completed, cancelled
  final String consultationType; // in-person, virtual
  final double consultationFee;
  final String? notes;
  final String? prescription;
  final String? diagnosis;
  final DateTime createdAt;
  
  Appointment({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.doctorName,
    required this.userFullName,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    required this.consultationType,
    required this.consultationFee,
    this.notes,
    this.prescription,
    this.diagnosis,
    required this.createdAt,
  });
  
  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      userId: data['userId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      userFullName: data['userFullName'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      status: data['status'] ?? 'scheduled',
      consultationType: data['consultationType'] ?? 'virtual',
      consultationFee: (data['consultationFee'] ?? 0.0).toDouble(),
      notes: data['notes'],
      prescription: data['prescription'],
      diagnosis: data['diagnosis'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'userFullName': userFullName,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'timeSlot': timeSlot,
      'status': status,
      'consultationType': consultationType,
      'consultationFee': consultationFee,
      'notes': notes,
      'prescription': prescription,
      'diagnosis': diagnosis,
      'createdAt': createdAt.isAfter(DateTime(2020)) 
          ? Timestamp.fromDate(createdAt) 
          : FieldValue.serverTimestamp(),
    };
  }
}

class AppointmentService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _error;
  List<DermatologistModel> _doctors = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DermatologistModel> get doctors => _doctors;
  
  // Constructor
  AppointmentService() {
    getAllDermatologists();
  }
  
  // Get all dermatologists
  Future<List<DermatologistModel>> getAllDermatologists() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final snapshot = await _firestore.collection('dermatologists').get();
      _doctors = snapshot.docs.map((doc) => DermatologistModel.fromMap(doc.data(), doc.id)).toList();
      _isLoading = false;
      notifyListeners();
      return _doctors;
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching dermatologists: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Get dermatologist by ID
  Future<DermatologistModel?> getDoctorById(String doctorId) async {
    try {
      if (_doctors.isNotEmpty) {
        final cachedDoctor = _doctors.firstWhere(
          (doctor) => doctor.id == doctorId,
          orElse: () => DermatologistModel(
            id: '', name: '', qualification: '', hospital: '', 
            experience: '', address: '', phoneNumber: '', 
            email: '', rating: 0, consultationFee: 0
          ),
        );
        
        if (cachedDoctor.id.isNotEmpty) {
          return cachedDoctor;
        }
      }
      
      final doc = await _firestore.collection('dermatologists').doc(doctorId).get();
      
      if (doc.exists) {
        return DermatologistModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      _error = 'Error getting doctor details: $e';
      notifyListeners();
      return null;
    }
  }
  
  // Book an appointment
  Future<String?> bookAppointment({
    required String doctorId,
    required String userId,
    required DateTime dateTime,
    required String consultationType,
    String? notes,
    String? reason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final doctor = await getDoctorById(doctorId);
      if (doctor == null) {
        throw Exception('Doctor not found');
      }
      
      // Format time slot (e.g. "10:00 AM")
      final timeSlot = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour < 12 ? 'AM' : 'PM'}';
      
      // Check if the time slot is available
      final availableSlots = await getAvailableTimeSlots(doctorId, dateTime);
      if (!availableSlots.contains(timeSlot)) {
        throw Exception('This time slot is no longer available');
      }
      
      // Create appointment
      final appointmentData = {
        'userId': userId,
        'doctorId': doctorId,
        'dateTime': Timestamp.fromDate(dateTime),
        'status': 'pending',
        'notes': notes,
        'reason': reason,
        'consultationType': consultationType,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      final docRef = await _firestore.collection('appointments').add(appointmentData);
      
      _isLoading = false;
      notifyListeners();
      return docRef.id;
    } catch (e) {
      _isLoading = false;
      _error = 'Error booking appointment: $e';
      notifyListeners();
      return null;
    }
  }
  
  // Get all appointments for a user
  Future<List<AppointmentModel>> getUserAppointments(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .orderBy('dateTime', descending: true)
          .get();
      
      List<AppointmentModel> appointments = [];
      for (var doc in snapshot.docs) {
        appointments.add(AppointmentModel.fromMap(doc.data(), doc.id));
      }
      
      _isLoading = false;
      notifyListeners();
      return appointments;
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching appointments: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Get upcoming appointments
  Future<List<AppointmentModel>> getUpcomingAppointments(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('status', isEqualTo: 'pending')
          .orderBy('dateTime')
          .get();
      
      List<AppointmentModel> appointments = [];
      for (var doc in snapshot.docs) {
        appointments.add(AppointmentModel.fromMap(doc.data(), doc.id));
      }
      
      _isLoading = false;
      notifyListeners();
      return appointments;
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching upcoming appointments: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Cancel appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error cancelling appointment: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Reschedule appointment
  Future<bool> rescheduleAppointment(
    String appointmentId, 
    DateTime newDateTime
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'dateTime': Timestamp.fromDate(newDateTime),
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error rescheduling appointment: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Check availability for a specific date and doctor
  Future<List<String>> getAvailableTimeSlots(String doctorId, DateTime date) async {
    try {
      // Get the day of week
      final dayOfWeek = _getDayOfWeek(date.weekday);
      
      // Get doctor
      final doctorSnapshot = await _firestore.collection('dermatologists').doc(doctorId).get();
      if (!doctorSnapshot.exists) return [];
      
      final data = doctorSnapshot.data()!;
      final availableDays = List<String>.from(data['availableDays'] ?? []);
      
      if (!availableDays.contains(dayOfWeek)) {
        return []; // Doctor not available on this day
      }
      
      // Get all time slots for this day
      final Map<String, dynamic> allTimeSlots = Map<String, dynamic>.from(data['availableTimeSlots'] ?? {});
      final availableSlots = List<String>.from(allTimeSlots[dayOfWeek] ?? []);
      
      // Get already booked appointments for this doctor on this date
      final dateStart = DateTime(date.year, date.month, date.day);
      final dateEnd = dateStart.add(const Duration(days: 1));
      
      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(dateStart))
          .where('dateTime', isLessThan: Timestamp.fromDate(dateEnd))
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();
      
      // Extract booked time slots
      final bookedTimes = snapshot.docs.map((doc) {
        final DateTime dateTime = (doc['dateTime'] as Timestamp).toDate();
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour < 12 ? 'AM' : 'PM'}';
      }).toList();
      
      // Return available slots that are not booked
      return availableSlots.where((slot) => !bookedTimes.contains(slot)).toList();
    } catch (e) {
      _error = 'Error checking availability: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Helper: Convert weekday number to string
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
}

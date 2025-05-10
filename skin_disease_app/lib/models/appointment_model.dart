import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String userId;
  final String doctorId;
  final String? doctorName;
  final DateTime dateTime;
  final String timeSlot;
  final String consultationType; // 'virtual' or 'in-person'
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final String notes;
  final String? reason;
  final DateTime createdAt;

  // Getter for appointmentDate used in the appointments screen
  DateTime get appointmentDate => dateTime;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.doctorId,
    this.doctorName,
    required this.dateTime,
    required this.timeSlot,
    required this.consultationType,
    required this.status,
    this.notes = '',
    this.reason,
    required this.createdAt,
  });

  // Create an AppointmentModel from Firestore data
  factory AppointmentModel.fromMap(Map<String, dynamic> data, String documentId) {
    return AppointmentModel(
      id: documentId,
      userId: data['userId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      consultationType: data['consultationType'] ?? 'virtual',
      status: data['status'] ?? 'pending',
      notes: data['notes'] ?? '',
      reason: data['reason'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert AppointmentModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'dateTime': Timestamp.fromDate(dateTime),
      'timeSlot': timeSlot,
      'consultationType': consultationType,
      'status': status,
      'notes': notes,
      'reason': reason,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create a copy of the current appointment with modified fields
  AppointmentModel copyWith({
    String? status,
    String? notes,
    String? timeSlot,
    String? consultationType,
  }) {
    return AppointmentModel(
      id: this.id,
      userId: this.userId,
      doctorId: this.doctorId,
      doctorName: this.doctorName,
      dateTime: this.dateTime,
      timeSlot: timeSlot ?? this.timeSlot,
      consultationType: consultationType ?? this.consultationType,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      reason: this.reason,
      createdAt: this.createdAt,
    );
  }
}

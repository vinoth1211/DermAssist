import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String userId;
  final String doctorId;
  final DateTime dateTime;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final String? notes;
  final String? reason;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.dateTime,
    required this.status,
    this.notes,
    this.reason,
    required this.createdAt,
  });

  // Create an AppointmentModel from Firestore data
  factory AppointmentModel.fromMap(Map<String, dynamic> data, String documentId) {
    return AppointmentModel(
      id: documentId,
      userId: data['userId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      notes: data['notes'],
      reason: data['reason'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert AppointmentModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'doctorId': doctorId,
      'dateTime': Timestamp.fromDate(dateTime),
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
  }) {
    return AppointmentModel(
      id: this.id,
      userId: this.userId,
      doctorId: this.doctorId,
      dateTime: this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      reason: this.reason,
      createdAt: this.createdAt,
    );
  }
}

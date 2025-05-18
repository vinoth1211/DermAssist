import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:skin_disease_app/models/disease_model.dart';

// Import tflite_flutter only for mobile
// We'll use a different approach with conditional imports to avoid web compilation issues
// import 'package:tflite_flutter_helper/tflite_flutter_helper.dart' if (dart.library.html) 'package:flutter/material.dart';

class DiseaseDetectionResult {
  final String diseaseName;
  final double confidence;
  final DiseaseModel? diseaseDetails;
  final String? imageUrl;
  final DateTime timestamp;
  
  DiseaseDetectionResult({
    required this.diseaseName, 
    required this.confidence,
    this.diseaseDetails,
    this.imageUrl,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toMap() {
    return {
      'diseaseName': diseaseName,
      'confidence': confidence,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
      'diseaseId': diseaseDetails?.id,
    };
  }
  
  factory DiseaseDetectionResult.fromMap(Map<String, dynamic> data) {
    return DiseaseDetectionResult(
      diseaseName: data['diseaseName'] ?? '',
      confidence: (data['confidence'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

class DiseaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  String? _error;
  List<DiseaseModel> _diseases = [];
  bool _isWeb = kIsWeb;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DiseaseModel> get diseases => _diseases;
  bool get isWeb => _isWeb;
  
  // Constructor
  DiseaseService() {
    _init();
  }
  
  Future<void> _init() async {
    try {
      await fetchAllDiseases();
    } catch (e) {
      _error = 'Error initializing Disease Service: $e';
      notifyListeners();
    }
  }
  
  // Load TFLite model - this is a stub method for future implementation
  // The actual model loading would be implemented in platform-specific code
  Future<void> _loadModel() async {
    // This is just a placeholder - actual TensorFlow implementation
    // would be added once platform-specific code is set up
  }
  
  // Download model from Firebase Storage
  Future<void> _downloadModel(String modelPath) async {
    if (kIsWeb) return; // Skip on web
    
    try {
      final ref = _storage.ref().child('models/skin_disease_model.tflite');
      final file = File(modelPath);
      await ref.writeToFile(file);
    } catch (e) {
      _error = 'Error downloading model: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  // Fetch all diseases from Firestore
  Future<List<DiseaseModel>> fetchAllDiseases() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final snapshot = await _firestore.collection('diseases').get();
      _diseases = snapshot.docs.map((doc) => DiseaseModel.fromMap(doc.data(), doc.id)).toList();
      _isLoading = false;
      notifyListeners();
      return _diseases;
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching diseases: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Get disease by ID
  Future<DiseaseModel?> getDiseaseById(String id) async {
    try {
      final doc = await _firestore.collection('diseases').doc(id).get();
      
      if (doc.exists) {
        return DiseaseModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      _error = 'Error getting disease by ID: $e';
      notifyListeners();
      return null;
    }
  }
  
  // Get disease by name
  Future<DiseaseModel?> getDiseaseByName(String name) async {
    try {
      final snapshot = await _firestore
          .collection('diseases')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return DiseaseModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      _error = 'Error getting disease by name: $e';
      notifyListeners();
      return null;
    }
  }
  
  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 299,
        maxHeight: 299,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      _error = 'Error picking image: $e';
      notifyListeners();
      return null;
    }
  }
  
  // Take a photo with camera
  Future<File?> takePhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 299,
        maxHeight: 299,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      _error = 'Error taking photo: $e';
      notifyListeners();
      return null;
    }
  }
  
  // Process image and detect disease
  Future<DiseaseDetectionResult?> detectDisease(File imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // For demonstration purposes, we'll use a mock implementation
      // In a real app, this would be connected to a real ML model
      // or an API service for web platforms
      
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing time
      
      // Sample result (replace with actual model inference or API call)
      const detectedDiseaseName = "Psoriasis";
      const confidence = 0.85;
      
      // Get disease details
      final diseaseDetails = await getDiseaseByName(detectedDiseaseName);
      
      _isLoading = false;
      notifyListeners();
      
      return DiseaseDetectionResult(
        diseaseName: detectedDiseaseName,
        confidence: confidence,
        diseaseDetails: diseaseDetails,
      );
      
    } catch (e) {
      _isLoading = false;
      _error = 'Error detecting disease: $e';
      notifyListeners();
      return null;
    }
  }
  
  // Save detection result to user's medical history
  Future<String?> saveDetectionResult(
    String userId, 
    DiseaseDetectionResult result,
    File? imageFile,
  ) async {
    try {
      String? imageUrl;
      
      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile, userId);
      }
      
      // Create detection record with image URL if available
      final resultWithImage = DiseaseDetectionResult(
        diseaseName: result.diseaseName,
        confidence: result.confidence,
        diseaseDetails: result.diseaseDetails,
        imageUrl: imageUrl,
      );
      
      // Add to detection_history collection
      final docRef = await _firestore.collection('detection_history').add({
        'userId': userId,
        ...resultWithImage.toMap(),
      });
      
      return docRef.id;
    } catch (e) {
      _error = 'Error saving detection result: $e';
      notifyListeners();
      return null;
    }
  }
  
  // Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile, String userId) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('skin_images/$fileName');
      
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      _error = 'Error uploading image: $e';
      notifyListeners();
      return null;
    }
  }
  
  // Get user detection history
  Future<List<DiseaseDetectionResult>> getUserDetectionHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('detection_history')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      
      List<DiseaseDetectionResult> results = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final result = DiseaseDetectionResult.fromMap(data);
        
        // Load disease details if diseaseId exists
        if (data['diseaseId'] != null) {
          final diseaseDetails = await getDiseaseById(data['diseaseId']);
          
          if (diseaseDetails != null) {
            results.add(DiseaseDetectionResult(
              diseaseName: result.diseaseName,
              confidence: result.confidence,
              diseaseDetails: diseaseDetails,
              imageUrl: result.imageUrl,
              timestamp: result.timestamp,
            ));
            continue;
          }
        }
        
        results.add(result);
      }
      
      return results;
    } catch (e) {
      _error = 'Error getting detection history: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Get user's health records
  Future<List<HealthRecord>> getUserHealthRecords(String userId) async {
    if (_isLoading) return [];
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('health_records')
          .where('userId', isEqualTo: userId)
          .orderBy('recordDate', descending: true)
          .get();

      final records = snapshot.docs
          .map((doc) => HealthRecord.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      _isLoading = false;
      notifyListeners();
      return records;
    } catch (e) {
      print('Error getting health records: $e');
      _isLoading = false;
      _error = 'Error getting health records: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Add a new health record
  Future<bool> addHealthRecord(HealthRecord record) async {
    try {
      if (!_isLoading) {
        _isLoading = true;
        _error = null;
        // Use future microtask to avoid setState during build
        Future.microtask(() => notifyListeners());
      }
      
      // If it's a new record, create a new document
      if (record.id.startsWith('manual_')) {
        await _firestore.collection('health_records').add(record.toMap());
      } else {
        // Otherwise update existing document
        await _firestore.collection('health_records').doc(record.id).set(record.toMap());
      }
      
      _isLoading = false;
      // Use future microtask to avoid setState during build
      Future.microtask(() => notifyListeners());
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error adding health record: $e';
      // Use future microtask to avoid setState during build
      Future.microtask(() => notifyListeners());
      return false;
    }
  }
}

class HealthRecord {
  final String id;
  final String userId;
  final DateTime date;
  final String type; // Diagnosis, Checkup, Treatment, Scan
  final String condition;
  final String description;
  final String severity; // Mild, Moderate, Severe
  final String treatment;
  final String notes;
  final String? imageUrl;

  HealthRecord({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    required this.condition,
    required this.description,
    required this.severity,
    required this.treatment,
    required this.notes,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'type': type,
      'condition': condition,
      'description': description,
      'severity': severity,
      'treatment': treatment,
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      userId: map['userId'],
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.parse(map['date']),
      type: map['type'],
      condition: map['condition'],
      description: map['description'],
      severity: map['severity'],
      treatment: map['treatment'],
      notes: map['notes'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }
}

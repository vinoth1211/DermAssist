import 'package:flutter/material.dart';
import 'package:skin_disease_app/utils/sample_users.dart';
import 'package:skin_disease_app/utils/sample_dermatologists.dart';
import 'package:skin_disease_app/utils/sample_diseases.dart';
import 'package:skin_disease_app/utils/sample_articles.dart';
import 'package:skin_disease_app/utils/sample_appointments.dart';

/// A utility class to load sample data into Firebase for testing
class SampleDataLoader {
  /// Load all sample data into Firestore
  static Future<void> loadAllSampleData(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Loading Sample Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait while we prepare the sample data...'),
            ],
          ),
        ),
      );

      // Load sample data
      await addSampleUsers();
      await addSampleDermatologists();
      await addSampleDiseases();
      await addSampleArticles();
      await addSampleAppointments();

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample data loaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading sample data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Add a button to the app to load sample data
  static Widget buildSampleDataButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () => loadAllSampleData(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'Load Sample Data for Testing',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:skin_disease_app/services/auth_service.dart';
import 'package:skin_disease_app/services/disease_service.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  bool _isLoading = true;
  List<HealthRecord> _healthRecords = [];

  @override
  void initState() {
    super.initState();
    _loadMedicalHistory();
  }

  Future<void> _loadMedicalHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final diseaseService = Provider.of<DiseaseService>(context, listen: false);

      if (authService.user != null) {
        final records = await diseaseService.getUserHealthRecords(authService.user!.uid);
        if (mounted) {
          setState(() {
            _healthRecords = records;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _healthRecords = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading medical history: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load medical history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add manual entry',
            onPressed: () {
              // Navigate to add manual health record screen
              _showAddRecordDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMedicalHistory,
              child: _healthRecords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No medical history found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your skin condition detection history will appear here',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/disease_detection');
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Scan Your Skin'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                      itemCount: _healthRecords.length,
                      itemBuilder: (context, index) {
                        final record = _healthRecords[index];
                        return _buildHealthRecordCard(record, isSmallScreen, textScale);
                      },
                    ),
            ),
    );
  }

  Widget _buildHealthRecordCard(HealthRecord record, bool isSmallScreen, double textScale) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to health record detail screen
          _showRecordDetailsDialog(record);
        },
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Record type and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      record.type,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 * textScale : 14 * textScale,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: _getTypeColor(record.type),
                  ),
                  Text(
                    dateFormat.format(record.date),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 * textScale : 14 * textScale,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Condition and image if available
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (record.imageUrl != null && record.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        record.imageUrl!,
                        width: isSmallScreen ? 80 : 100,
                        height: isSmallScreen ? 80 : 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: isSmallScreen ? 80 : 100,
                            height: isSmallScreen ? 80 : 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  SizedBox(width: record.imageUrl != null && record.imageUrl!.isNotEmpty ? 12 : 0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.condition,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 * textScale : 18 * textScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record.description,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 * textScale : 16 * textScale,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Treatments and severity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medical_services_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Treatment: ${record.treatment}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 * textScale : 14 * textScale,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Severity: ${record.severity}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 * textScale : 14 * textScale,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'diagnosis':
        return Colors.blue;
      case 'checkup':
        return Colors.green;
      case 'treatment':
        return Colors.orange;
      case 'scan':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showRecordDetailsDialog(HealthRecord record) async {
    final dateFormat = DateFormat('MMMM d, yyyy');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record.condition),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (record.imageUrl != null && record.imageUrl!.isNotEmpty) ...[
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      record.imageUrl!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(
                      text: 'Date: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: dateFormat.format(record.date)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(
                      text: 'Type: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: record.type),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(
                      text: 'Severity: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: record.severity),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(record.description),
              const SizedBox(height: 8),
              
              const Text(
                'Treatment:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(record.treatment),
              
              if (record.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(record.notes),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to edit health record screen
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddRecordDialog() async {
    final formKey = GlobalKey<FormState>();
    final conditionController = TextEditingController();
    final descriptionController = TextEditingController();
    final treatmentController = TextEditingController();
    final notesController = TextEditingController();
    String severity = 'Mild';
    String type = 'Checkup';
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Health Record'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Type dropdown
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(
                    labelText: 'Record Type',
                  ),
                  items: ['Diagnosis', 'Checkup', 'Treatment', 'Scan']
                      .map((type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      type = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Date picker
                InkWell(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    
                    if (pickedDate != null) {
                      selectedDate = pickedDate;
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('MMMM d, yyyy').format(selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Condition
                TextFormField(
                  controller: conditionController,
                  decoration: const InputDecoration(
                    labelText: 'Condition',
                    hintText: 'e.g., Eczema, Acne, etc.',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the condition';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Description
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the symptoms',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Severity
                DropdownButtonFormField<String>(
                  value: severity,
                  decoration: const InputDecoration(
                    labelText: 'Severity',
                  ),
                  items: ['Mild', 'Moderate', 'Severe']
                      .map((severity) => DropdownMenuItem<String>(
                            value: severity,
                            child: Text(severity),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      severity = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Treatment
                TextFormField(
                  controller: treatmentController,
                  decoration: const InputDecoration(
                    labelText: 'Treatment',
                    hintText: 'Enter any treatments applied',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the treatment';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Notes
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Any additional notes',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // Save the health record
                final diseaseService = Provider.of<DiseaseService>(context, listen: false);
                final authService = Provider.of<AuthService>(context, listen: false);
                
                if (authService.user != null) {
                  final newRecord = HealthRecord(
                    id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
                    userId: authService.user!.uid,
                    date: selectedDate,
                    type: type,
                    condition: conditionController.text,
                    description: descriptionController.text,
                    severity: severity,
                    treatment: treatmentController.text,
                    notes: notesController.text,
                    imageUrl: null,
                  );
                  
                  await diseaseService.addHealthRecord(newRecord);
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                    _loadMedicalHistory();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Health record added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// HealthRecord class is imported from disease_service.dart

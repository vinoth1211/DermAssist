import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_disease_app/services/auth_service.dart';
import 'package:skin_disease_app/services/disease_service.dart';
import 'package:skin_disease_app/widgets/custom_button.dart';
import 'package:lottie/lottie.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  File? _selectedImage;
  DiseaseDetectionResult? _detectionResult;
  bool _isProcessing = false;
  
  Future<void> _pickImage(bool fromCamera) async {
    final diseaseService = Provider.of<DiseaseService>(context, listen: false);
    final File? pickedImage = fromCamera 
        ? await diseaseService.takePhoto()
        : await diseaseService.pickImageFromGallery();
    
    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
        _detectionResult = null;
      });
    }
  }
  
  Future<void> _detectDisease() async {
    if (_selectedImage == null) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    final diseaseService = Provider.of<DiseaseService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      final result = await diseaseService.detectDisease(_selectedImage!);
      
      if (result != null) {
        // Save detection result with the image
        await diseaseService.saveDetectionResult(
          authService.user!.uid,
          result,
          _selectedImage!,
        );
        
        setState(() {
          _detectionResult = result;
          _isProcessing = false;
        });
      } else {
        setState(() {
          _isProcessing = false;
        });
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(diseaseService.error ?? 'Failed to detect disease'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
  
  void _resetDetection() {
    setState(() {
      _selectedImage = null;
      _detectionResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Disease Detection'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and instructions
              if (_selectedImage == null && _detectionResult == null) ...[
                // Instructions
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Lottie.network(
                          'https://assets2.lottiefiles.com/packages/lf20_4qldwfx4.json',
                          height: 150,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Upload a clear image of the affected skin area',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Our AI will analyze the image and provide information about possible skin conditions. This is not a substitute for professional medical advice.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Tips
                Text(
                  'Tips for better results:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _buildTipItem(
                  context,
                  'Good lighting: Take photos in bright, natural light.',
                  Icons.light_mode,
                ),
                _buildTipItem(
                  context,
                  'Clear focus: Ensure the affected area is clearly visible and in focus.',
                  Icons.center_focus_strong,
                ),
                _buildTipItem(
                  context,
                  'Multiple angles: Consider taking multiple photos from different angles.',
                  Icons.rotate_90_degrees_ccw,
                ),
                _buildTipItem(
                  context,
                  'Include scale: Place a coin or ruler next to larger affected areas for scale.',
                  Icons.straighten,
                ),
                const SizedBox(height: 24),
                
                // Image selection buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: () => _pickImage(false),
                        text: 'Select from Gallery',
                        icon: Icons.photo_library,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        onPressed: () => _pickImage(true),
                        text: 'Take a Photo',
                        icon: Icons.camera_alt,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Image preview and analysis
              if (_selectedImage != null) ...[
                // Image preview
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Action buttons
                        if (_detectionResult == null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  onPressed: _resetDetection,
                                  text: 'Change Image',
                                  isOutlined: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomButton(
                                  onPressed: _isProcessing ? null : _detectDisease,
                                  text: 'Analyze Image',
                                  isLoading: _isProcessing,
                                ),
                              ),
                            ],
                          ),
                          
                          // Processing indicator
                          if (_isProcessing) ...[
                            const SizedBox(height: 24),
                            Lottie.network(
                              'https://assets1.lottiefiles.com/packages/lf20_xjncwgxo.json',
                              height: 100,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Analyzing your image...',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              
              // Results display
              if (_detectionResult != null) ...[
                const SizedBox(height: 24),
                
                // Result card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Result header
                        Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Analysis Complete',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        // Disease name
                        Text(
                          'Detected Condition:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _detectionResult!.diseaseName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Confidence level
                        Text(
                          'Confidence Level:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _detectionResult!.confidence,
                          backgroundColor: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_detectionResult!.confidence * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Disease information if available
                        if (_detectionResult!.diseaseDetails != null) ...[
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          // Description
                          Text(
                            'About ${_detectionResult!.diseaseName}:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(_detectionResult!.diseaseDetails!.description),
                          const SizedBox(height: 16),
                          
                          // Symptoms
                          Text(
                            'Common Symptoms:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: _detectionResult!.diseaseDetails!.symptoms
                                .map((symptom) => _buildInfoItem(context, symptom))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          
                          // Treatments
                          Text(
                            'Treatments:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: _detectionResult!.diseaseDetails!.treatments
                                .map((treatment) => _buildInfoItem(context, treatment))
                                .toList(),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // Disclaimer
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber,
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This is not a medical diagnosis. Please consult a dermatologist for professional advice.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                onPressed: _resetDetection,
                                text: 'Scan Again',
                                isOutlined: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomButton(
                                onPressed: () {
                                  // Navigate to doctor booking
                                  Navigator.of(context).pushNamed('/dermatologists');
                                },
                                text: 'Find Doctor',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTipItem(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}

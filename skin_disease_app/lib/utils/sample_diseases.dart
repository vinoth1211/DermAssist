import 'package:cloud_firestore/cloud_firestore.dart';

// Sample disease data for testing
final List<Map<String, dynamic>> sampleDiseases = [
  {
    'id': 'disease1',
    'name': 'Psoriasis',
    'description': 'Psoriasis is a chronic skin condition that causes cells to build up rapidly on the surface of the skin, forming itchy, dry, red patches and thick, silvery scales.',
    'causes': [
      'Immune system dysfunction where skin cells grow too quickly',
      'Genetic factors - common in families',
      'Environmental triggers like stress, infections, and cold weather'
    ],
    'symptoms': [
      'Red patches of skin covered with thick, silvery scales',
      'Small scaling spots (commonly seen in children)',
      'Dry, cracked skin that may bleed',
      'Itching, burning or soreness',
      'Thickened, pitted or ridged nails',
      'Swollen and stiff joints'
    ],
    'treatments': [
      'Topical treatments: Corticosteroids, Vitamin D analogues, retinoids',
      'Light therapy: UVB phototherapy or PUVA',
      'Oral or injected medications for severe cases',
      'Lifestyle changes: Stress management, moisturizing regularly'
    ],
    'preventions': [
      'Keep skin well-moisturized',
      'Avoid triggers like stress and alcohol',
      'Maintain a healthy diet',
      'Take daily baths with mild soaps'
    ],
    'severity': 'Moderate to Severe',
    'imageUrl': 'https://www.mayoclinic.org/-/media/kcms/gbs/patient-consumer/images/2013/11/15/17/44/ds00193_-ds00908_-ds00821_-ds00434_-ds00450_-ds01306_-ds01036_-img20130606122731_jpg.jpg',
    'commonLocations': ['Elbows', 'Knees', 'Scalp', 'Lower back'],
  },
  {
    'id': 'disease2',
    'name': 'Eczema',
    'description': 'Eczema, also known as atopic dermatitis, is a condition that makes your skin red and itchy. It\'s common in children but can occur at any age.',
    'causes': [
      'Combination of genetic and environmental factors',
      'Immune system dysfunction',
      'Skin barrier defects allowing moisture out and germs in'
    ],
    'symptoms': [
      'Dry, sensitive skin',
      'Intense itching',
      'Red, inflamed skin',
      'Recurring rash',
      'Scaly areas',
      'Rough, leathery patches',
      'Oozing or crusting',
      'Areas of swelling'
    ],
    'treatments': [
      'Moisturizers to prevent dryness',
      'Topical corticosteroids to reduce inflammation',
      'Oral antihistamines for itching',
      'Antibiotics if infection is present',
      'Phototherapy',
      'Immunosuppressants for severe cases'
    ],
    'preventions': [
      'Moisturize your skin at least twice a day',
      'Identify and avoid triggers that worsen eczema',
      'Take shorter baths or showers with warm, not hot water',
      'Use gentle soaps and pat dry instead of rubbing',
      'Wear soft clothes and avoid rough, scratchy fabrics'
    ],
    'severity': 'Mild to Severe',
    'imageUrl': 'https://nationaleczema.org/wp-content/uploads/2021/04/eczema-on-dark-skin.jpeg',
    'commonLocations': ['Inside elbows', 'Behind knees', 'Hands', 'Face', 'Neck'],
  },
  {
    'id': 'disease3',
    'name': 'Acne',
    'description': 'Acne is a skin condition that occurs when your hair follicles become plugged with oil and dead skin cells, leading to whiteheads, blackheads or pimples.',
    'causes': [
      'Excess oil (sebum) production',
      'Hair follicles clogged by oil and dead skin cells',
      'Bacteria',
      'Hormonal changes',
      'Certain medications',
      'Diet high in refined sugars or carbohydrates'
    ],
    'symptoms': [
      'Whiteheads (closed plugged pores)',
      'Blackheads (open plugged pores)',
      'Small red, tender bumps (papules)',
      'Pimples (pustules with pus at their tips)',
      'Large, solid, painful lumps under the skin (nodules)',
      'Painful, pus-filled lumps under the skin (cystic lesions)'
    ],
    'treatments': [
      'Topical treatments containing benzoyl peroxide, salicylic acid, or retinoids',
      'Oral antibiotics to reduce bacteria and fight inflammation',
      'Oral contraceptives for hormonal acne in women',
      'Isotretinoin for severe cases',
      'Laser and light therapies',
      'Chemical peels'
    ],
    'preventions': [
      'Wash affected areas twice daily with mild cleanser',
      'Avoid harsh scrubbing',
      'Avoid touching or picking at acne spots',
      'Shower after exercising',
      'Avoid high-glycemic foods',
      'Use oil-free, water-based products'
    ],
    'severity': 'Mild to Severe',
    'imageUrl': 'https://www.healthline.com/health/beauty-skin-care/types-of-acne',
    'commonLocations': ['Face', 'Forehead', 'Chest', 'Upper back', 'Shoulders'],
  },
  {
    'id': 'disease4',
    'name': 'Rosacea',
    'description': 'Rosacea is a common skin condition that causes redness and visible blood vessels in your face. It may also produce small, red, pus-filled bumps.',
    'causes': [
      'Blood vessel abnormalities',
      'Genetics',
      'Environmental factors',
      'Microscopic skin mites (Demodex)',
      'Helicobacter pylori bacteria'
    ],
    'symptoms': [
      'Facial redness, particularly in the center of the face',
      'Swollen red bumps resembling acne',
      'Visible blood vessels on the face',
      'Eye problems (ocular rosacea)',
      'Enlarged nose (rhinophyma)'
    ],
    'treatments': [
      'Topical medications to reduce redness',
      'Oral antibiotics for more severe symptoms',
      'Isotretinoin for severe cases not responding to other treatments',
      'Laser therapy to reduce visible blood vessels',
      'Gentle skin care regimen'
    ],
    'preventions': [
      'Identify and avoid triggers (sun exposure, spicy foods, alcohol, etc.)',
      'Protect your face from the sun',
      'Avoid hot drinks and alcohol',
      'Manage stress effectively',
      'Use gentle skin care products'
    ],
    'severity': 'Mild to Moderate',
    'imageUrl': 'https://www.mayoclinic.org/-/media/kcms/gbs/patient-consumer/images/2013/11/15/17/35/ds00308_-ds00859_-ds01008_-ds00877_i_jpg.jpg',
    'commonLocations': ['Cheeks', 'Nose', 'Chin', 'Forehead', 'Eyes'],
  },
];

// Function to add sample diseases to Firestore
Future<void> addSampleDiseases() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  for (var diseaseData in sampleDiseases) {
    final String id = diseaseData['id'];
    final docRef = firestore.collection('diseases').doc(id);
    final docSnapshot = await docRef.get();
    
    if (!docSnapshot.exists) {
      await docRef.set(diseaseData);
      print('Added disease: ${diseaseData['name']}');
    } else {
      print('Disease ${diseaseData['name']} already exists, skipping...');
    }
  }
  
  print('Sample diseases added successfully!');
}

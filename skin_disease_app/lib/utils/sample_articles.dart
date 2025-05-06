import 'package:cloud_firestore/cloud_firestore.dart';

// Sample article data for testing
final List<Map<String, dynamic>> sampleArticles = [
  {
    'id': 'article1',
    'title': 'Understanding Skin Cancer: Types, Symptoms, and Prevention',
    'content': '''
Skin cancer is one of the most common types of cancer affecting millions of people worldwide. Early detection is crucial for successful treatment. This article covers the different types of skin cancer, what signs to look for, and how to reduce your risk.

There are three main types of skin cancer: basal cell carcinoma, squamous cell carcinoma, and melanoma. Basal cell and squamous cell carcinomas are the most common and highly treatable. Melanoma is less common but more dangerous.

Signs and symptoms to watch for include:
- A new growth or sore that doesn't heal
- A spot or sore that changes in appearance
- A mole that changes in size, shape, or color
- Any unusual skin changes

Prevention starts with sun protection. Always wear sunscreen with at least SPF 30, seek shade especially during peak sun hours (10 am - 4 pm), wear protective clothing, and avoid tanning beds. Regular skin self-exams and professional skin checks are also important preventive measures.

Remember, if you notice any suspicious changes in your skin, consult a dermatologist as soon as possible.
''',
    'author': 'Dr. Emily Reynolds',
    'category': 'Skin Cancer',
    'tags': ['skin cancer', 'prevention', 'sunscreen', 'melanoma'],
    'publishDate': DateTime(2024, 1, 15),
    'readTime': 5,
    'imageUrl': 'https://images.unsplash.com/photo-1579165466741-7f35e4755135',
  },
  {
    'id': 'article2',
    'title': 'The Science of Moisturizers: How They Work and What to Look For',
    'content': '''
Moisturizers are a cornerstone of any skincare routine, but do you know how they actually work? This article explains the science behind moisturizers and offers guidance on choosing the right one for your skin type.

Moisturizers work in three primary ways:
1. Occlusives: These create a physical barrier on the skin to prevent water loss. Examples include petrolatum, silicones, and natural oils.
2. Humectants: These attract water from the air or deeper layers of the skin to the surface. Examples include glycerin, hyaluronic acid, and urea.
3. Emollients: These fill in the gaps between skin cells, making the skin feel smoother. Examples include ceramides, fatty acids, and squalane.

When choosing a moisturizer, consider your skin type:
- Dry skin: Look for richer formulas with occlusives and emollients
- Oily skin: Choose lightweight, non-comedogenic formulas with more humectants
- Sensitive skin: Seek fragrance-free, hypoallergenic options with soothing ingredients
- Combination skin: Consider using different products for different areas of your face

The best time to apply moisturizer is on slightly damp skin, right after cleansing. This helps lock in hydration and maximizes the effectiveness of your product.

Remember that your skin's needs may change with the seasons, age, or environmental factors, so be prepared to adjust your moisturizer accordingly.
''',
    'author': 'Dr. Maya Patel',
    'category': 'Skincare',
    'tags': ['moisturizer', 'hydration', 'skincare routine', 'dry skin'],
    'publishDate': DateTime(2024, 2, 20),
    'readTime': 6,
    'imageUrl': 'https://images.unsplash.com/photo-1556228578-14a120971a86',
  },
  {
    'id': 'article3',
    'title': 'Managing Eczema in Children: A Guide for Parents',
    'content': '''
Eczema (atopic dermatitis) affects up to 20% of children and can be challenging for both the child and parents. This guide offers practical advice for managing your child's eczema and minimizing flare-ups.

Bathing and moisturizing form the foundation of eczema care:
- Use lukewarm (not hot) water for baths
- Limit baths to 5-10 minutes
- Use gentle, fragrance-free cleansers only where needed
- Apply prescribed medications right after bathing
- Follow immediately with a thick moisturizer
- Moisturize at least twice daily

Identifying and avoiding triggers is crucial:
- Common triggers include certain fabrics (wool, polyester), harsh soaps, dust mites, pet dander, and some foods
- Dress your child in soft, breathable fabrics like cotton
- Use fragrance-free laundry detergent and avoid fabric softeners
- Keep fingernails short to minimize damage from scratching

Managing the itch:
- Apply cold compresses to itchy areas
- Consider wet wrap therapy for severe flares (as directed by your doctor)
- Use anti-itch medications as prescribed
- Keep the home cool and humid

When to see a doctor:
- If the eczema is not responding to treatment
- If there are signs of infection (increased redness, warmth, pus, or fever)
- If the eczema is interfering with sleep or daily activities

With consistent care and management, most children with eczema can experience significant improvement in their symptoms.
''',
    'author': 'Dr. Sarah Johnson',
    'category': 'Pediatric Dermatology',
    'tags': ['eczema', 'children', 'atopic dermatitis', 'skin care'],
    'publishDate': DateTime(2024, 3, 10),
    'readTime': 7,
    'imageUrl': 'https://images.unsplash.com/photo-1594824476967-48c8b964273f',
  },
  {
    'id': 'article4',
    'title': 'Acne Treatment: Beyond the Basics',
    'content': '''
Acne is one of the most common skin conditions, affecting people of all ages. While there are many over-the-counter treatments available, persistent or severe acne may require a more sophisticated approach. This article explores advanced acne treatments and when to consider them.

When basic treatments aren't working:
If you've been consistent with over-the-counter products containing benzoyl peroxide or salicylic acid for at least 12 weeks without improvement, it's time to consider the next level of treatment.

Prescription topical treatments:
- Stronger retinoids like tretinoin or adapalene
- Topical antibiotics such as clindamycin
- Combinations like clindamycin-benzoyl peroxide or adapalene-benzoyl peroxide
- Azelaic acid for its anti-inflammatory properties

Oral medications:
- Antibiotics like doxycycline or minocycline for inflammatory acne
- Hormonal treatments like birth control pills or spironolactone for women with hormonal acne
- Isotretinoin (formerly known as Accutane) for severe, resistant acne

Procedures:
- Chemical peels with glycolic or salicylic acid
- Extraction of large comedones by a dermatologist
- Steroid injections for painful cystic lesions
- Light and laser therapies
- Microneedling

Addressing acne scars:
Once active acne is under control, treatments for scarring include:
- Laser resurfacing
- Dermabrasion
- Microneedling
- Fillers for depressed scars
- Chemical peels

The psychological impact of acne should not be underestimated. If acne is affecting your self-esteem or mental health, don't hesitate to seek help from both a dermatologist and mental health professional.

Remember that successful acne treatment takes time and often requires a combination approach. Work with a dermatologist to develop a treatment plan tailored to your specific needs.
''',
    'author': 'Dr. Michael Chen',
    'category': 'Acne',
    'tags': ['acne', 'treatment', 'retinoids', 'skincare'],
    'publishDate': DateTime(2024, 4, 5),
    'readTime': 8,
    'imageUrl': 'https://images.unsplash.com/photo-1568305537067-a5c791d83aaa',
  },
];

// Function to add sample articles to Firestore
Future<void> addSampleArticles() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  for (var articleData in sampleArticles) {
    final String id = articleData['id'];
    final docRef = firestore.collection('articles').doc(id);
    final docSnapshot = await docRef.get();
    
    if (!docSnapshot.exists) {
      // Convert DateTime to Timestamp for Firestore
      final Map<String, dynamic> firestoreData = {...articleData};
      firestoreData['publishDate'] = Timestamp.fromDate(articleData['publishDate']);
      
      await docRef.set(firestoreData);
      print('Added article: ${articleData['title']}');
    } else {
      print('Article "${articleData['title']}" already exists, skipping...');
    }
  }
  
  print('Sample articles added successfully!');
}

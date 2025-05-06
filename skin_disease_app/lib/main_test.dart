import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DermAssist Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const TestHomePage(),
    );
  }
}

class TestHomePage extends StatefulWidget {
  const TestHomePage({super.key});

  @override
  State<TestHomePage> createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeTabContent(),
    const DiseaseDetectionTab(),
    const DermatologistTab(),
    const ArticlesTab(),
    const ProfileTab(),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  void onItemTapped(int index) {
    _onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DermAssist'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Detect',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Articles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.health_and_safety,
                  size: 80,
                  color: Colors.teal,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome to DermAssist!',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your skin health companion',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Quick actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildQuickActionCard(
                context,
                Icons.camera_alt,
                'Detect Skin Condition',
                () {
                  // Find the parent StatefulWidget and update index
                  final _TestHomePageState? homeState = 
                      context.findAncestorStateOfType<_TestHomePageState>();
                  homeState?.onItemTapped(1); // Navigate to Detect tab
                },
              ),
              _buildQuickActionCard(
                context,
                Icons.chat,
                'Chat with DermBot',
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chatbot is under development'),
                    ),
                  );
                },
              ),
              _buildQuickActionCard(
                context,
                Icons.medical_services,
                'Find Dermatologist',
                () {
                  // Find the parent StatefulWidget and update index
                  final _TestHomePageState? homeState = 
                      context.findAncestorStateOfType<_TestHomePageState>();
                  homeState?.onItemTapped(2); // Navigate to Doctors tab
                },
              ),
              _buildQuickActionCard(
                context,
                Icons.article,
                'Read Articles',
                () {
                  // Find the parent StatefulWidget and update index
                  final _TestHomePageState? homeState = 
                      context.findAncestorStateOfType<_TestHomePageState>();
                  homeState?.onItemTapped(3); // Navigate to Articles tab
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent activity
          Text(
            'Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Mode Active',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is a web demonstration version of DermAssist with limited functionality. '
                    'The full version of the app includes skin disease detection using ML, '
                    'appointment booking, and more.',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Platform: ${kIsWeb ? "Web Browser" : "Mobile/Desktop"}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionCard(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiseaseDetectionTab extends StatelessWidget {
  const DiseaseDetectionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.teal,
            ),
            const SizedBox(height: 24),
            Text(
              'Skin Disease Detection',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'The skin disease detection feature is not available in the web demo version.\n\n'
              'In the full version, you can upload images of skin conditions for ML-based analysis.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feature not available in web demo'),
                  ),
                );
              },
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Upload Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DermatologistTab extends StatelessWidget {
  const DermatologistTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for doctors
    final doctors = [
      {
        'name': 'Dr. Sarah Johnson',
        'specialty': 'General Dermatology',
        'rating': 4.8,
        'image': 'https://xsgames.co/randomusers/assets/avatars/female/46.jpg',
      },
      {
        'name': 'Dr. James Wilson',
        'specialty': 'Pediatric Dermatology',
        'rating': 4.7,
        'image': 'https://xsgames.co/randomusers/assets/avatars/male/37.jpg',
      },
      {
        'name': 'Dr. Emily Rodriguez',
        'specialty': 'Cosmetic Dermatology',
        'rating': 4.9,
        'image': 'https://xsgames.co/randomusers/assets/avatars/female/23.jpg',
      },
      {
        'name': 'Dr. Michael Chen',
        'specialty': 'Surgical Dermatology',
        'rating': 4.6,
        'image': 'https://xsgames.co/randomusers/assets/avatars/male/65.jpg',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find a Dermatologist',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name or specialty',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Available Dermatologists',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            doctor['image'] as String,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.person, size: 40),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor['name'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(doctor['specialty'] as String),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${doctor['rating']} / 5.0',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Booking with ${doctor['name']} is not available in demo'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Book'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ArticlesTab extends StatelessWidget {
  const ArticlesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for articles
    final articles = [
      {
        'title': 'Understanding Acne: Causes and Treatments',
        'category': 'Skin Conditions',
        'image': 'https://images.unsplash.com/photo-1631217868264-e6b507c6f8d3',
        'date': 'May 2, 2025',
      },
      {
        'title': 'The Science of Sunscreen: Why SPF Matters',
        'category': 'Skin Protection',
        'image': 'https://images.unsplash.com/photo-1594948202368-7918204efe4a',
        'date': 'April 28, 2025',
      },
      {
        'title': 'Managing Eczema Flare-Ups: A Complete Guide',
        'category': 'Skin Conditions',
        'image': 'https://images.unsplash.com/photo-1584515227805-9ca9efc5c7b2',
        'date': 'April 23, 2025',
      },
      {
        'title': 'Skincare Routines for Different Skin Types',
        'category': 'Skin Care',
        'image': 'https://images.unsplash.com/photo-1571875257727-256c39da42af',
        'date': 'April 15, 2025',
      },
    ];

    final categories = ['All', 'Skin Conditions', 'Skin Care', 'Skin Protection'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skin Health Articles',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(categories[index]),
                    selected: index == 0,
                    onSelected: (selected) {
                      // Filter logic would go here
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        '${article['image']}?w=600&auto=format&fit=crop',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 160,
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.image_not_supported, size: 40)),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    article['category'] as String,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                const Spacer(),
                                Text(
                                  article['date'] as String,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              article['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Article "${article['title']}" is not available in demo'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Read More'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey,
            child: Icon(
              Icons.person,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Demo User',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            'demo.user@example.com',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Profile Menu
          const ProfileMenuItem(
            icon: Icons.person,
            title: 'Personal Information',
          ),
          const ProfileMenuItem(
            icon: Icons.history,
            title: 'Detection History',
          ),
          const ProfileMenuItem(
            icon: Icons.calendar_today,
            title: 'My Appointments',
          ),
          const ProfileMenuItem(
            icon: Icons.bookmark,
            title: 'Saved Articles',
          ),
          const ProfileMenuItem(
            icon: Icons.notifications,
            title: 'Notifications',
          ),
          const ProfileMenuItem(
            icon: Icons.settings,
            title: 'App Settings',
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logout is not available in demo'),
                ),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Demo Version',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title is not available in demo'),
            ),
          );
        },
      ),
    );
  }
}

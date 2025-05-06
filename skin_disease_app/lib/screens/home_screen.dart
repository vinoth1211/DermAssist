import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_disease_app/screens/article_screen.dart';
import 'package:skin_disease_app/screens/chatbot_screen.dart';
import 'package:skin_disease_app/screens/dermatologist_screen.dart';
import 'package:skin_disease_app/screens/disease_detection_screen.dart';
import 'package:skin_disease_app/screens/profile_screen.dart';
import 'package:skin_disease_app/services/auth_service.dart';
import 'package:skin_disease_app/services/article_service.dart';
import 'package:skin_disease_app/services/appointment_service.dart';
import 'package:skin_disease_app/widgets/feature_card.dart';
import 'package:skin_disease_app/widgets/article_card.dart';
import 'package:skin_disease_app/widgets/doctor_card.dart';
import 'package:skin_disease_app/utils/sample_data_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final articleService = Provider.of<ArticleService>(context, listen: false);
    final appointmentService = Provider.of<AppointmentService>(context, listen: false);
    
    // Load featured articles and doctors in parallel
    await Future.wait([
      articleService.getFeaturedArticles(),
      appointmentService.getAllDermatologists(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final articleService = Provider.of<ArticleService>(context);
    final appointmentService = Provider.of<AppointmentService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('DermAssist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    authService.user?.displayName ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    authService.user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.healing),
              title: const Text('My Health Records'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to health records
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('My Appointments'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to appointments
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Saved Articles'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to saved articles
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  await authService.signOut();
                  if (!mounted) return;
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
            // Dev Tools section
            if (true) ... [ // Change to false for production
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Developer Tools',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.data_array, color: Colors.amber),
                title: const Text('Load Sample Data'),
                subtitle: const Text('Populate database with test data'),
                onTap: () {
                  Navigator.pop(context);
                  SampleDataLoader.loadAllSampleData(context);
                },
              ),
            ],
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Greeting and quick stats
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${authService.user?.displayName?.split(' ').first ?? 'User'}!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'How is your skin today?',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Feature cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  FeatureCard(
                    title: 'Detect Disease',
                    description: 'Scan and analyze your skin condition',
                    icon: Icons.camera_alt,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DiseaseDetectionScreen(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    title: 'Find Specialist',
                    description: 'Book an appointment with a dermatologist',
                    icon: Icons.people,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DermatologistScreen(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    title: 'Skin Health Bot',
                    description: 'Get answers to your skin health questions',
                    icon: Icons.chat,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatbotScreen(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    title: 'Skin Care Tips',
                    description: 'Discover tips for healthy skin',
                    icon: Icons.lightbulb,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ArticleScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Featured Articles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Articles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ArticleScreen(),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              articleService.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : articleService.featuredArticles.isEmpty
                      ? const Center(
                          child: Text('No featured articles available'),
                        )
                      : SizedBox(
                          height: 240,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: articleService.featuredArticles.length,
                            itemBuilder: (context, index) {
                              final article = articleService.featuredArticles[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: ArticleCard(
                                  article: article,
                                  onTap: () {
                                    // Navigate to article details
                                  },
                                ),
                              );
                            },
                          ),
                        ),
              
              const SizedBox(height: 24),
              
              // Top Dermatologists
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Dermatologists',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DermatologistScreen(),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              appointmentService.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : appointmentService.doctors.isEmpty
                      ? const Center(
                          child: Text('No dermatologists available'),
                        )
                      : SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: appointmentService.doctors.length > 5
                                ? 5
                                : appointmentService.doctors.length,
                            itemBuilder: (context, index) {
                              final doctor = appointmentService.doctors[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: DoctorCard(
                                  doctor: doctor,
                                  onTap: () {
                                    // Navigate to doctor details
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

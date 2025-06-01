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
    final appointmentService = Provider.of<AppointmentService>(
      context,
      listen: false,
    );

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

    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DermAssist'),
        actions: [
          // Removed unused notification icon
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    authService.user?.displayName ?? 'User',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    authService.user?.email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
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
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.healing),
              title: const Text('My Health Records'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/medical_history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('My Appointments'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/appointments');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Saved Articles'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/saved_articles');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
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
            // Developer tools section removed
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12.0 : 20.0,
            vertical: isSmallScreen ? 16.0 : 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Hello, ${authService.user?.displayName ?? 'User'}!',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 * textScale : 24 * textScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8.0 : 12.0),
              Text(
                'How are you feeling today?',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 * textScale : 16 * textScale,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: isSmallScreen ? 20.0 : 30.0),

              // Quick access features
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isSmallScreen ? 2 : 3,
                childAspectRatio: isSmallScreen ? 1.15 : 1.3,
                crossAxisSpacing: isSmallScreen ? 10.0 : 16.0,
                mainAxisSpacing: isSmallScreen ? 10.0 : 16.0,
                children: [
                  FeatureCard(
                    icon: Icons.healing,
                    title: 'Symptom Check',
                    color: Colors.blue,
                    onTap: () {
                      // Navigate to symptom checker
                    },
                  ),
                  FeatureCard(
                    icon: Icons.calendar_today,
                    title: 'Book Appointment',
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
                    icon: Icons.camera_alt,
                    title: 'Skin Analysis',
                    color: Colors.purple,
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
                    icon: Icons.chat,
                    title: 'AI Assistant',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatBotScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: isSmallScreen ? 24.0 : 32.0),

              // Featured Articles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Articles',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 * textScale : 18 * textScale,
                      fontWeight: FontWeight.bold,
                    ),
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
              SizedBox(height: isSmallScreen ? 8.0 : 12.0),

              articleService.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : articleService.featuredArticles.isEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: isSmallScreen ? 40 : 50,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                          Text(
                            'No featured articles available',
                            style: TextStyle(
                              fontSize:
                                  isSmallScreen
                                      ? 14 * textScale
                                      : 16 * textScale,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : SizedBox(
                    height: isSmallScreen ? 200 : 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: articleService.featuredArticles.length,
                      itemBuilder: (context, index) {
                        final article = articleService.featuredArticles[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: isSmallScreen ? 10.0 : 12.0,
                          ),
                          child: SizedBox(
                            width: isSmallScreen ? screenWidth * 0.7 : 280,
                            child: ArticleCard(
                              article: article,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/article_detail',
                                  arguments: {'articleId': article.id},
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

              SizedBox(height: isSmallScreen ? 20.0 : 24.0),

              // Top Dermatologists
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Dermatologists',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 * textScale : 18 * textScale,
                      fontWeight: FontWeight.bold,
                    ),
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
              SizedBox(height: isSmallScreen ? 8.0 : 12.0),

              appointmentService.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : appointmentService.doctors.isEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_outlined,
                            size: isSmallScreen ? 40 : 50,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                          Text(
                            'No dermatologists available',
                            style: TextStyle(
                              fontSize:
                                  isSmallScreen
                                      ? 14 * textScale
                                      : 16 * textScale,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : SizedBox(
                    height: isSmallScreen ? 170 : 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          appointmentService.doctors.length > 5
                              ? 5
                              : appointmentService.doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = appointmentService.doctors[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: isSmallScreen ? 10.0 : 12.0,
                          ),
                          child: SizedBox(
                            width: isSmallScreen ? 140 : 160,
                            child: DoctorCard(
                              doctor: doctor,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/doctor_detail',
                                  arguments: {'doctorId': doctor.id},
                                );
                              },
                            ),
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

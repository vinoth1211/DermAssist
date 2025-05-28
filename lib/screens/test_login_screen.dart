import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_disease_app/services/auth_service.dart';
import 'package:skin_disease_app/utils/sample_data_loader.dart';
import 'package:skin_disease_app/widgets/custom_button.dart';

class TestLoginScreen extends StatefulWidget {
  const TestLoginScreen({super.key});

  @override
  State<TestLoginScreen> createState() => _TestLoginScreenState();
}

class _TestLoginScreenState extends State<TestLoginScreen> {
  final List<Map<String, String>> _sampleUsers = [
    {
      'id': 'user1',
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'id': 'user2',
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'avatar': 'https://randomuser.me/api/portraits/women/1.jpg',
    },
    {
      'id': 'user3',
      'name': 'Alex Wong',
      'email': 'alex.wong@example.com',
      'avatar': 'https://randomuser.me/api/portraits/men/2.jpg',
    },
  ];

  bool _isDataLoaded = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Login'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Developer Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'This screen allows you to log in with sample accounts for testing '
                  'without requiring Firebase Authentication. First load sample data, '
                  'then select a user to log in.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          if (!_isDataLoaded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomButton(
                text: 'Load Sample Data First',
                onPressed: () async {
                  await SampleDataLoader.loadAllSampleData(context);
                  setState(() {
                    _isDataLoaded = true;
                  });
                },
                icon: Icons.cloud_download,
              ),
            ),
          if (_isDataLoaded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select a Sample User',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (_isDataLoaded)
            Expanded(
              child: ListView.builder(
                itemCount: _sampleUsers.length,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, index) {
                  final user = _sampleUsers[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(user['avatar']!),
                      ),
                      title: Text(
                        user['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(user['email']!),
                      trailing: authService.isLoading
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.login),
                      onTap: () async {
                        final success = await authService.testModeLogin(user['id']!);
                        
                        if (success && mounted) {
                          // Navigate to home screen
                          Navigator.of(context).pushReplacementNamed('/home');
                        } else if (mounted) {
                          // Show error
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authService.error ?? 'Failed to login'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          if (!_isDataLoaded)
            const Expanded(
              child: Center(
                child: Text('Load sample data to see test users'),
              ),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Back to Regular Login',
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    isOutlined: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Last Updated: May 10, 2025'),
            SizedBox(height: 24),
            PolicySection(
              title: 'Introduction',
              content:
                  'DermAssist ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application DermAssist (the "Application").',
            ),
            PolicySection(
              title: 'Information We Collect',
              content:
                  'We may collect information about you in various ways, including:\n\n'
                  '• Personal Data: Name, email address, phone number, and profile pictures you provide when creating an account.\n'
                  '• Health Information: Skin conditions, medical history, and images you upload for diagnosis.\n'
                  '• Usage Data: Information about how you use the Application, including appointment history and article reading preferences.\n'
                  '• Device Information: Device ID, IP address, operating system, and browser type.',
            ),
            PolicySection(
              title: 'How We Use Your Information',
              content:
                  'We use the information we collect for various purposes, including:\n\n'
                  '• To provide and maintain our Application\n'
                  '• To notify you about changes to our Application\n'
                  '• To allow you to participate in interactive features\n'
                  '• To provide customer support\n'
                  '• To gather analysis to improve our Application\n'
                  '• To monitor usage of the Application\n'
                  '• To detect, prevent, and address technical issues\n'
                  '• To provide personalized health recommendations',
            ),
            PolicySection(
              title: 'Disclosure of Your Information',
              content:
                  'We may share your information with:\n\n'
                  '• Healthcare Providers: To facilitate appointments and consultations.\n'
                  '• Service Providers: Who assist us in operating the Application.\n'
                  '• Business Partners: To offer certain products, services, or promotions.\n'
                  '• Legal Requirements: To comply with any court order, law, or legal process.',
            ),
            PolicySection(
              title: 'Security of Your Information',
              content:
                  'We use administrative, technical, and physical security measures to protect your personal information. While we strive to use commercially acceptable means to protect your personal information, we cannot guarantee its absolute security.',
            ),
            PolicySection(
              title: 'Your Rights',
              content:
                  'You have the right to:\n\n'
                  '• Access your personal information\n'
                  '• Correct inaccurate information\n'
                  '• Delete your information\n'
                  '• Object to processing of your information\n'
                  '• Data portability\n'
                  '• Withdraw consent',
            ),
            PolicySection(
              title: 'Children\'s Privacy',
              content:
                  'Our Application is not directed to children under 13. We do not knowingly collect information from children under 13. If you are a parent and believe your child has provided us with personal information, please contact us.',
            ),
            PolicySection(
              title: 'Changes to This Privacy Policy',
              content:
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.',
            ),
            PolicySection(
              title: 'Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                  'DermAssist App\n'
                  'support@dermassist.com\n'
                  '123 Health Avenue, Medical District\n'
                  'Phone: +1 (555) 123-4567',
            ),
          ],
        ),
      ),
    );
  }
}

class PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const PolicySection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

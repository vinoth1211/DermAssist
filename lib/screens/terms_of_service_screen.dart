import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Last Updated: May 10, 2025'),
            SizedBox(height: 24),
            TermsSection(
              title: 'Acceptance of Terms',
              content:
                  'By accessing or using the DermAssist mobile application (the "Application"), you agree to be bound by these Terms of Service. If you disagree with any part of these terms, you do not have permission to access the Application.',
            ),
            TermsSection(
              title: 'Description of Service',
              content:
                  'DermAssist provides a platform for users to access skin health information, connect with dermatologists, and receive preliminary skin condition assessments. The Application is not intended to replace professional medical advice, diagnosis, or treatment.',
            ),
            TermsSection(
              title: 'User Accounts',
              content:
                  'When you create an account with us, you must provide accurate, complete, and current information. You are responsible for safeguarding the password and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account.',
            ),
            TermsSection(
              title: 'Medical Disclaimer',
              content:
                  'THE APPLICATION PROVIDES GENERAL INFORMATION AND IS NOT INTENDED TO BE A SUBSTITUTE FOR PROFESSIONAL MEDICAL ADVICE, DIAGNOSIS, OR TREATMENT. ALWAYS SEEK THE ADVICE OF YOUR PHYSICIAN OR OTHER QUALIFIED HEALTH PROVIDER WITH ANY QUESTIONS YOU MAY HAVE REGARDING A MEDICAL CONDITION.',
            ),
            TermsSection(
              title: 'User Content',
              content:
                  'By uploading images or providing information through the Application, you grant DermAssist a non-exclusive, transferable, sub-licensable, royalty-free, worldwide license to use, modify, publicly display, and distribute such content solely for the purpose of providing and improving the services.',
            ),
            TermsSection(
              title: 'Prohibited Uses',
              content:
                  'You agree not to use the Application:\n\n'
                  '• In any way that violates any applicable law or regulation\n'
                  '• To transmit any material that is defamatory, obscene, or otherwise objectionable\n'
                  '• To impersonate or attempt to impersonate another person or entity\n'
                  '• To engage in any conduct that restricts or inhibits anyone\'s use of the Application\n'
                  '• To attempt to gain unauthorized access to any portion of the Application',
            ),
            TermsSection(
              title: 'Intellectual Property',
              content:
                  'The Application and its content, features, and functionality are owned by DermAssist and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.',
            ),
            TermsSection(
              title: 'Termination',
              content:
                  'We may terminate or suspend your account immediately, without prior notice or liability, for any reason, including breach of these Terms of Service. Upon termination, your right to use the Application will immediately cease.',
            ),
            TermsSection(
              title: 'Limitation of Liability',
              content:
                  'IN NO EVENT SHALL DERMASSIST BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL OR PUNITIVE DAMAGES, INCLUDING WITHOUT LIMITATION, LOSS OF PROFITS, DATA, USE, GOODWILL, OR OTHER INTANGIBLE LOSSES.',
            ),
            TermsSection(
              title: 'Changes to Terms',
              content:
                  'We reserve the right to modify or replace these Terms of Service at any time. It is your responsibility to review these Terms of Service periodically for changes.',
            ),
            TermsSection(
              title: 'Contact',
              content:
                  'If you have any questions about these Terms of Service, please contact us at:\n\n'
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

class TermsSection extends StatelessWidget {
  final String title;
  final String content;

  const TermsSection({
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

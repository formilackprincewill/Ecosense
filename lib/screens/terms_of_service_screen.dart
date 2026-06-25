// lib/screens/terms_of_service_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TermsSectionData {
  final String id;
  final String title;
  final List<Widget> children;

  TermsSectionData({
    required this.id,
    required this.title,
    required this.children,
  });
}

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  String _currentSectionId = 'acceptance';
  late final List<TermsSectionData> _sections;

  @override
  void initState() {
    super.initState();
    _initializeTermsContent();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String sectionId) {
    setState(() {
      _currentSectionId = sectionId;
    });

    final targetKey = _sectionKeys[sectionId];
    if (targetKey != null && targetKey.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'MMMM dd, yyyy',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Terms of Service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101910),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF101910)),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Go back',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            height: 60.0,
            color: Colors.transparent,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                final section = _sections[index];
                final isSelected = _currentSectionId == section.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(section.title),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF5C8E57)
                          : const Color(0xFFEAF1E9),
                    ),
                    backgroundColor: const Color(0xFFF9FBF9),
                    selectedColor: const Color(0xFFEAF1E9),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) _scrollToSection(section.id);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Subtitle Block
            Text(
              'EcoSense Platform User Agreement',
              style: TextStyle(
                color: Colors.green.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: $formattedDate',
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(height: 32),

            // Terms Iteration Node Loop
            ..._sections.map((section) {
              return Container(
                key: _sectionKeys[section.id],
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...section.children,
                  ],
                ),
              );
            }),

            // Footer Contact Block
            Card(
              color: const Color(0xFFEAF1E9),
              margin: const EdgeInsets.only(top: 16, bottom: 32),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Us',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900, //Colors.green[700],
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'If you have any questions about these Terms of Service, please contact our legal administration team:',
                      style: TextStyle(color: Color(0xFF101910)),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: Color(0xFF101910),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Email: privacy@ecosense.org',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF101910),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(
                          Icons.language_outlined,
                          size: 20,
                          color: Color(0xFF101910),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Website: www.ecosense.org',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF101910),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initializeTermsContent() {
    final List<TermsSectionData> rawContent = [
      TermsSectionData(
        id: 'acceptance',
        title: 'Acceptance of Terms',
        children: [
          const Text(
            'These Terms of Service ("Terms") govern your access to and use of the EcoSense website, mobile application, and related services (collectively, the "Service").',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const SizedBox(height: 8),
          const Text(
            'By accessing or using the Service, you agree to be bound by these Terms. If you disagree with any part of these Terms, you may not access the Service.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const SizedBox(height: 8),
          const Text(
            'These Terms apply to all visitors, users, and others who access or use the Service. By using the Service, you represent that you are at least 13 years of age.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
        ],
      ),
      TermsSectionData(
        id: 'use-license',
        title: 'Use License',
        children: [
          const Text(
            'Subject to these Terms, EcoSense grants you a limited, non-exclusive, non-transferable, revocable license to use the Service for your personal, non-commercial use.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('License Restrictions'),
          const Text(
            'You agree not to:',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _BulletPoint(
            'Modify, adapt, or create derivative works based on the Service',
          ),
          const _BulletPoint(
            'Reverse engineer, decompile, or attempt to extract the source code',
          ),
          const _BulletPoint(
            'Use the Service for commercial purposes without our express written consent',
          ),
          const _BulletPoint(
            'Remove or alter any copyright notices or other proprietary markings',
          ),
          const _BulletPoint(
            'Use any data mining, robots, or similar data gathering and extraction tools',
          ),
          const _SubHeading('Environmental Data License'),
          const Text(
            'By submitting environmental data through the Service, you grant EcoSense a worldwide, non-exclusive, royalty-free license to use, process, and display your data for environmental monitoring and research purposes.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
        ],
      ),
      TermsSectionData(
        id: 'user-accounts',
        title: 'User Accounts',
        children: [
          const Text(
            'When you create an account with us, you must provide accurate and complete information. You are responsible for maintaining the security of your account and password.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Account Requirements'),
          const _BulletPoint(
            'You must be at least 13 years old to create an account',
          ),
          const _BulletPoint('You must provide a valid email address'),
          const _BulletPoint(
            'You must maintain the accuracy of your account information',
          ),
          const _BulletPoint(
            'You are solely responsible for all activities under your account',
          ),
          const _SubHeading('Account Security'),
          const Text(
            'You agree to notify us immediately of any unauthorized use of your account or any other breach of security. EcoSense will not be liable for any loss or damage arising from your failure to comply with these requirements.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Account Termination'),
          const Text(
            'We reserve the right to terminate or suspend your account immediately, without prior notice, for any reason, including violation of these Terms.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
        ],
      ),
      TermsSectionData(
        id: 'content',
        title: 'Content Ownership',
        children: [
          const _SubHeading('Our Content'),
          const Text(
            'All content, features, and functionality of the Service are owned by EcoSense and are protected by international copyright, trademark, patent, trade secret, and other intellectual property or proprietary rights laws.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('User-Generated Content'),
          const Text(
            'When you post content to the Service, you grant EcoSense a worldwide, non-exclusive, royalty-free license to use, reproduce, modify, adapt, publish, translate, create derivative works from, distribute, and display such content in any media.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Environmental Data'),
          const Text(
            'Data collected through the Service, including environmental measurements, may be used to create aggregated datasets for research and community environmental monitoring. Individual data points may be displayed publicly on environmental maps.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Accuracy of Information'),
          const Text(
            'While we strive to provide accurate environmental data and information, we do not guarantee the completeness, accuracy, or reliability of any content on the Service.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
        ],
      ),
      TermsSectionData(
        id: 'data-collection',
        title: 'Data Collection & Use',
        children: [
          const Text(
            'By using the Service, you consent to the collection, use, and sharing of your data as described in our Privacy Policy.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Environmental Data Collection'),
          const Text(
            'The Service may collect environmental data from your device\'s sensors, including but not limited to air quality, noise levels, and light measurements. This data is used to create environmental maps and datasets.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Location Data'),
          const Text(
            'With your consent, the Service may collect precise location data from your device. You can disable location services at any time through your device settings.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Data Sharing'),
          const Text(
            'Environmental data collected may be shared publicly to support community environmental monitoring efforts. Personal information is not shared without your consent.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Data Retention'),
          const Text(
            'We retain your personal information for as long as necessary to provide our services and comply with our legal obligations.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
        ],
      ),
      TermsSectionData(
        id: 'prohibited-uses',
        title: 'Prohibited Uses',
        children: [
          const Text(
            'You may not use the Service for any purpose that is unlawful or prohibited by these Terms. Prohibited uses include, but are not limited to:',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _BulletPoint(
            'Using the Service in violation of any applicable law or regulation',
          ),
          const _BulletPoint(
            'Submitting false or misleading environmental data',
          ),
          const _BulletPoint('Harassing, abusing, or harming other users'),
          const _BulletPoint(
            'Uploading or transmitting viruses or other harmful code',
          ),
          const _BulletPoint(
            'Attempting to gain unauthorized access to the Service',
          ),
          const _BulletPoint(
            'Using the Service to collect personal information about others',
          ),
          const _BulletPoint('Interfering with the operation of the Service'),
          const _BulletPoint(
            'Using the Service for commercial purposes without permission',
          ),
          const _SubHeading('Crowdsourced Data Integrity'),
          const Text(
            'You agree to provide accurate and honest environmental measurements. Submitting false or manipulated data may result in account suspension or termination.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
        ],
      ),
      TermsSectionData(
        id: 'disclaimers',
        title: 'Disclaimers',
        children: [
          const Text(
            'The Service is provided "as is" and "as available" without warranties of any kind, either express or implied.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Service Availability'),
          const Text(
            'We do not guarantee that the Service will be available at all times or that access will be uninterrupted. We may suspend or terminate the Service at any time.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Environmental Data Accuracy'),
          const Text(
            'While we strive to provide accurate environmental data, individual measurements may not reflect actual environmental conditions due to various factors including sensor limitations and environmental variables.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('No Professional Advice'),
          const Text(
            'The information provided by the Service is for educational and informational purposes only and should not be considered professional environmental or health advice.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Third-Party Content'),
          const Text(
            'The Service may contain links to third-party websites or content. We do not control and are not responsible for any third-party content.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
        ],
      ),
      TermsSectionData(
        id: 'limitation',
        title: 'Limitation of Liability',
        children: [
          const Text(
            'In no event shall EcoSense, its directors, employees, partners, agents, suppliers, or affiliates be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Direct Damages'),
          const Text(
            'In no event shall EcoSense\'s total liability to you for all claims under these Terms exceed the amount you paid us to use the Service.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('User Conduct'),
          const Text(
            'We are not responsible for any loss or damage resulting from your failure to comply with these Terms or your interactions with other users.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Environmental Decisions'),
          const Text(
            'You acknowledge that environmental decisions should not be based solely on the data provided by the Service. Always consult qualified professionals for environmental concerns.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
        ],
      ),
      TermsSectionData(
        id: 'governing-law',
        title: 'Governing Law',
        children: [
          const Text(
            'These Terms shall be governed and construed in accordance with the laws of the applicable jurisdiction, without regard to its conflict of law provisions.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Dispute Resolution'),
          const Text(
            'If you have any dispute with us regarding the Service or these Terms, we will attempt to resolve it through good faith negotiations. If negotiations fail, disputes shall be resolved through binding arbitration.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Severability'),
          const Text(
            'If any provision of these Terms is held to be invalid or unenforceable, such provision shall be struck, and the remaining provisions shall remain in full force and effect.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Force Majeure'),
          const Text(
            'EcoSense shall not be liable for any failure to perform its obligations due to causes beyond its reasonable control, including natural disasters, government actions, or technical failures.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
        ],
      ),
      TermsSectionData(
        id: 'changes',
        title: 'Changes to Terms',
        children: [
          const Text(
            'We reserve the right to modify or replace these Terms at any time. Changes will be effective immediately upon posting to the Service.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Notification of Changes'),
          const Text(
            'We will notify you of any material changes to these Terms by posting the new Terms on this page and updating the "Last updated" date.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Continued Use'),
          const Text(
            'Your continued use of the Service after any changes to these Terms constitutes acceptance of those changes. If you do not agree to the updated Terms, you must stop using the Service.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Previous Versions'),
          const Text(
            'Previous versions of these Terms are archived and available upon request. However, your use of the Service is governed by the current version.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
        ],
      ),
    ];

    for (var section in rawContent) {
      _sectionKeys[section.id] = GlobalKey();
    }
    _sections = rawContent;
  }
}

class _SubHeading extends StatelessWidget {
  final String text;
  const _SubHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 6.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF101910)),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              color: Color(0xFF101910),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(height: 1.3, color: Color(0xFF101910)),
            ),
          ),
        ],
      ),
    );
  }
}

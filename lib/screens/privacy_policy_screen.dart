// lib/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PolicySectionData {
  final String id;
  final String title;
  final List<Widget> children;

  PolicySectionData({
    required this.id,
    required this.title,
    required this.children,
  });
}

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final ScrollController _scrollController = ScrollController();

  // Track global keys for target sections to compute jump coordinates
  final Map<String, GlobalKey> _sectionKeys = {};
  String _currentSectionId = 'information-we-collect';

  late final List<PolicySectionData> _sections;

  @override
  void initState() {
    super.initState();
    _initializePolicyContent();
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
          'Privacy Policy',
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
            // Header Info Block
            Text(
              'EcoSense Platform Trust Framework',
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

            // Dynamic Policy Iteration Node Loop
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
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'If you have any questions about this Privacy Policy, please reach out via our environmental administration nodes:',
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

  // Pure data mappings converted from Angular selectors to atomic Flutter content components
  void _initializePolicyContent() {
    final List<PolicySectionData> rawContent = [
      PolicySectionData(
        id: 'information-we-collect',
        title: 'Information We Collect',
        children: [
          const Text(
            'We collect several types of information for various purposes to provide and improve our services to the platform ecosystem:',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Personal Data'),
          const Text(
            'While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you. This includes:',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _BulletPoint('Registered Account Email address'),
          const _BulletPoint('Citizen profile Username'),
          const _BulletPoint(
            'Device Location data (when explicitly granted authorization)',
          ),
          const _BulletPoint('User Avatar Profile picture'),
          const _SubHeading('Environmental Data'),
          const Text(
            'When you trigger the operational telemetry monitors inside the EcoSense client node, we stream real-world structural data metrics directly via onboard hardware modules:',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _BulletPoint(
            'Microphone Decibel Loggers (Noise level readings)',
          ),
          const _BulletPoint(
            'Ambient Atmospheric Barometers & Light Pollution Indexes',
          ),
          const _BulletPoint(
            'Precision GPS Geolocation metrics (Structural Coordinates)',
          ),
          const _SubHeading('Usage Data'),
          const Text(
            'Platform metadata generated automatically during network interface sessions:',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _BulletPoint(
            'Anonymized Device IP addresses & unique machine tags',
          ),
          const _BulletPoint(
            'Session timestamps and specific viewport interaction durations',
          ),
        ],
      ),
      PolicySectionData(
        id: 'how-we-use',
        title: 'How We Use Data',
        children: [
          const Text(
            'Collected data channels are processed to maintain system reliability metrics:',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _BulletPoint(
            'To execute background database pipeline ingestion routines',
          ),
          const _BulletPoint(
            'To compile algorithmic models mapping spatial environmental hazards',
          ),
          const _BulletPoint(
            'To provide predictive indicators and multi-sensor trends to your region',
          ),
          const _SubHeading('Environmental Data Processing Rules'),
          const Text(
            'All crowdsourced telemetry packets are bundled into aggregated, fully anonymized public map dashboard clusters to safely support global ecological research efforts without exposing consumer footprint identifiers.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
        ],
      ),
      PolicySectionData(
        id: 'data-sharing',
        title: 'Sharing & Disclosure',
        children: [
          const Text(
            'EcoSense explicitly prevents the sale, commercialization, or rental distribution of raw identity tables to commercial advertising parties.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _SubHeading('Authorized Pipelines'),
          const _BulletPoint(
            'Encrypted structural caching hosts (Cloud infrastructure service providers)',
          ),
          const _BulletPoint(
            'Compliance actions mandatory under statutory judicial mandates',
          ),
        ],
      ),
      PolicySectionData(
        id: 'data-security',
        title: 'Data Security',
        children: [
          const Text(
            'We maintain strict technical frameworks to safeguard platform boundaries:',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _BulletPoint(
            'AES-256 Cryptographic encryption modules enforcing protection in transit and at rest',
          ),
          const _BulletPoint(
            'Server-side token verification structures separating client profiles completely',
          ),
          const SizedBox(height: 8),
          const Text(
            'Note: While our architecture uses high security configurations, zero end-to-end network loops over the web offer absolute bulletproof isolation guarantees.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
        ],
      ),
      PolicySectionData(
        id: 'your-rights',
        title: 'Your Rights',
        children: [
          const Text(
            'As a decentralized data collection contributor, your operational profiles retain complete ownership rights over your metrics:',
            style: TextStyle(color: Color(0xFF101910)),
          ),
          const _BulletPoint(
            'Access: Request full copies of your historical database rows',
          ),
          const _BulletPoint(
            'Correction: Amend data discrepancies within your identity models',
          ),
          const _BulletPoint(
            'Erasure: Request complete deletion of your profile history from the active nodes',
          ),
          const SizedBox(height: 8),
          const Text(
            'To invoke active data maintenance rights, transmit requests directly to privacy@ecosense.org.',
            style: TextStyle(color: Color(0xFF101910)),
          ),
        ],
      ),
    ];

    // Assign keys to each block for programmatic auto-scroll anchors
    for (var section in rawContent) {
      _sectionKeys[section.id] = GlobalKey();
    }
    _sections = rawContent;
  }
}

// Inline Visual Sub-Layout Support Components
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

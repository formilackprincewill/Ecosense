import 'package:ecosense/screens/auth/register.dart';
import 'package:flutter/material.dart';
// Consider adding a package for smooth page transitions if needed
// e.g., page_transition: ^2.0.9

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Define the onboarding content
  final List<Map<String, dynamic>> _onboardingPages = [
    {
      "title": "Welcome to EcoSense",
      "description":
          "Join a community dedicated to monitoring and improving our environment. Share your observations and contribute to a healthier planet.",
      "image": "https://picsum.photos/seed/eco1/600/400", // Placeholder image
    },
    {
      "title": "How It Works",
      "description":
          "Use your phone's sensors to collect data on air quality, noise levels, and light intensity. View your findings on an interactive map and share insights with others.",
      "image": "https://picsum.photos/seed/eco2/600/400", // Placeholder image
    },
    {
      "title": "Make an Impact",
      "description":
          "Earn badges for your contributions, climb the leaderboard, and see how your local area compares globally. Your data drives positive environmental change.",
      "image": "https://picsum.photos/seed/eco3/600/400", // Placeholder image
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - Navigate to Sign In/Up
      // For now, we'll just print. You'll replace this with actual navigation.

      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => SignUpPage()));
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // As per design spec
      body: ListView(
        children: [
          const SizedBox(height: 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF101910),
                  shape: const CircleBorder(),
                  onPressed: _previousPage,
                  mini: true,
                  child: const Icon(Icons.arrow_back_ios_new),
                )
              else
                FloatingActionButton(
                  hoverColor: Colors.white,
                  hoverElevation: 0,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  onPressed: () {},
                  mini: true,
                ),
              // No FAB on first page
              if (_currentPage < _onboardingPages.length - 1)
                TextButton(
                  onPressed: () {
                    // Navigate to Auth screen directly
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Color(0xFF101910), // Primary Green
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          // Optional: Skip button (common on onboarding)

          // Top Half: Image
          SizedBox(
            height: 400,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _onboardingPages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  // Full-bleed illustration
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(_onboardingPages[index]['image']),
                      fit: BoxFit.cover, // Cover the area
                    ),
                  ),
                  // Optional: Add a subtle overlay for better text readability
                  // child: Container(
                  //   color: Colors.black.withOpacity(0.1),
                  // ),
                );
              },
            ),
          ),
          // Bottom Half: Content
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  _onboardingPages[_currentPage]['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22, // 22pt as per spec
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101910), // Assuming dark text
                  ),
                ),
                const SizedBox(height: 16.0),
                // Description
                Text(
                  _onboardingPages[_currentPage]['description'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16, // 16pt as per spec
                    color: Color(0xFF101910), // Assuming dark text
                    height: 1.5, // Improve readability
                  ),
                ),
                const SizedBox(height: 32.0),
                // Pagination Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_onboardingPages.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6.0),
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? const Color(
                                0xFF2E7D32,
                              ) // Primary Green for active
                            : const Color(
                                0xFFD4E4D3,
                              ), // Light green for inactive
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32.0),
                // CTA Button
                SizedBox(
                  width: double.infinity, // Full width button
                  height: 48, // Standard button height
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF2E7D32,
                      ), // Primary Green
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8.0,
                        ), // Rounded corners
                      ),
                      elevation: 0, // Flat design
                    ),
                    child: Text(
                      _currentPage == _onboardingPages.length - 1
                          ? 'Get Started' // Final CTA
                          : 'Next', // Intermediate CTA
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ],
      ),
      // Optional: Back button on pages 2 and 3
    );
  }
}

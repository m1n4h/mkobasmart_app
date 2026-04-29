// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/animated_card.dart';
import '../localization/app_localizations.dart';
import 'authentication/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      imagePath: 'assets/images/image1.jpg',
      titleKey: 'onboarding_title_1',
      descriptionKey: 'onboarding_desc_1',
      color: Colors.green,
    ),
    OnboardingData(
      imagePath: 'assets/images/image3.jpeg',
      titleKey: 'onboarding_title_2',
      descriptionKey: 'onboarding_desc_2',
      color: Colors.blue,
    ),
    OnboardingData(
      imagePath: 'assets/images/image2.webp',
      titleKey: 'onboarding_title_3',
      descriptionKey: 'onboarding_desc_3',
      color: Colors.orange,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                    : [Colors.white, Colors.grey[50]!],
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                   // Inside PageView.builder -> itemBuilder
return AnimatedCard(
  delay: 100 * index,
  child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Image Container
        Container(
          height: 255, // Give the image a fixed height
          width: double.infinity,
          decoration: BoxDecoration(
            color: _pages[index].color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              _pages[index].imagePath,
              fit: BoxFit.contain, // Ensures the image isn't distorted
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          _pages[index].titleKey.tr(context),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          _pages[index].descriptionKey.tr(context),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ),
);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        if (_currentPage < _pages.length - 1)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _completeOnboarding,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text('skip'.tr(context)),
                            ),
                          ),
                        if (_currentPage < _pages.length - 1)
                          const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage < _pages.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                _completeOnboarding();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _currentPage < _pages.length - 1
                                  ? 'next'.tr(context)
                                  : 'continue'.tr(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String imagePath; // Changed from IconData icon
  final String titleKey;
  final String descriptionKey;
  final Color color;

  OnboardingData({
    required this.imagePath,
    required this.titleKey,
    required this.descriptionKey,
    required this.color,
  });
}
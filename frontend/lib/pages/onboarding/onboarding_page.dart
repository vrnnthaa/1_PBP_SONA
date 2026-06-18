import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sona/pages/auth/login_page.dart';
import 'package:sona/pages/home/home_page.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/pages/onboarding/onboarding_item.dart';
import 'package:sona/widgets/onboarding/onboarding_button.dart';
import 'package:sona/widgets/onboarding/onboarding_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();

  int currentPage = 0;

  final pages = [
    OnboardingItem(
      content: Image.asset(
        "assets/onboarding/intro_1.png",
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        ),
      title: "A calm place for every night",
      description: "Discover cozy lodges and quiet stays, made for rest and comfort."
    ),
    
    OnboardingItem(
      content: Image.asset(
        "assets/onboarding/intro_2.png",
        fit: BoxFit.contain,
        width: double.infinity,
        ),
      title: "Book with ease",
      description: "Browse available stays and book your next getaway effortlessly."
    ),

    OnboardingItem(
      content: Lottie.asset(
        'assets/Lottie/Onboarding_Splash.json',
        repeat: false,
      ),
      title: "SONA's got you covered",
      description: "Browse available stays and book your next getaway effortlessly."
    ),
  ];

  void nextPage() {
    if (currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [

                    // Background image / lottie
                    Positioned.fill(
                      child: pages[index].content,
                    ),

                    // Gradient supaya teks lebih kebaca
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.primary.withValues(alpha: 0.2),
                              AppTheme.primary.withValues(alpha: 0.6),
                              AppTheme.primary,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 80,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pages[index].title,
                            style: AppTheme.titleStyle_white,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            pages[index].description,
                            style: AppTheme.subtitleStyle_white,
                          ),

                          const SizedBox(height: 32),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OnboardingButton(
                                onPressed: nextPage,
                                isLastPage:
                                    currentPage == pages.length - 1,
                              ),

                              OnboardingIndicator(
                                currentPage: currentPage,
                                totalPages: pages.length,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
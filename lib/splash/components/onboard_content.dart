import 'package:flutter/material.dart';
import 'package:dottunes/splash/components/landed_content.dart';
import 'package:dottunes/splash/components/sing_up_form.dart';

import '../../main.dart';

class OnboardContent extends StatefulWidget {
  const OnboardContent({super.key});

  @override
  State<OnboardContent> createState() => _OnboardContentState();
}

class _OnboardContentState extends State<OnboardContent> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController()
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double progress =
    _pageController.hasClients ? (_pageController.page ?? 0) : 0;

    return SizedBox(
      height: 400 + progress * 100,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: const [
                    LandingContent(),
                    SignUpForm(),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            height: 56,
            bottom: 48 + progress * 180,
            right: 16,
            child: GestureDetector(
              onTap: () {
                if (_pageController.page == 0) {
                  // Navigate to next page (SignUpForm)
                  _pageController.animateToPage(1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.ease);
                } else if (_pageController.page == 1) {
                  // Navigate to dottunes screen and replace OnboardContent
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const dottunes()),
                        (Route<dynamic> route) => false, // This will remove all previous routes
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    stops: const [0.4, 0.8],
                    colors: [
                      Theme.of(context).primaryColor, // Using primary color from the theme
                      Theme.of(context).colorScheme.secondary, // Using secondary color from the theme
                    ],
                  ),
                ),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Nothing', // Add your font family here
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 92 + progress * 32,
                        child: Stack(
                          fit: StackFit.passthrough,
                          children: [
                            FadeTransition(
                              opacity: AlwaysStoppedAnimation(1 - progress),
                              child: const Text("Get Started"),
                            ),
                            FadeTransition(
                              opacity: AlwaysStoppedAnimation(progress),
                              child: const Text(
                                "Dive In",
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 24,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

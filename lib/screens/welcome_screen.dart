// lib/screens/patient/welcome_screen.dart
import 'package:drophope/screens/google_auth_screen.dart';
import 'package:drophope/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import flutter_screenutil
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int currentPage = 0;
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 680.h), // Scale bottom padding
                child: Image.asset(
                  'assets/images/appbar.png',
                  height: 220.h, // Scale image height
                  fit: BoxFit.contain,
                  width: 200.w, // Scale image width
                ),
              ),
            ),
            PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              children: [
                _buildPage(
                  image: 'assets/images/Welcome.png',
                  title: "Welcome to DropHope 👋\n",
                  subtitle: "\nGive new life to the things you no longer use",
                ),
                _buildPage(
                  image: 'assets/images/welcome1.png',
                  title: "Share What You Have\n Tests With Ease",
                  subtitle:
                      "\nClothes, books, electronics — someone out there needs them",
                ),
                _buildPage(
                  image: 'assets/images/welcome2.png',
                  title: "Make a Difference Today",
                  subtitle:
                      "\nA simple act of giving can brighten someone’s day",
                ),
              ],
            ),
            Positioned(
              bottom: 179.h, // Scale bottom position
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: pageController,
                  count: 3,
                  effect: WormEffect(
                    dotHeight: 8.h, // Scale dot height
                    dotWidth: 8.w, // Scale dot width
                    activeDotColor: Colors.blue,
                    dotColor: Colors.grey,
                  ),
                ),
              ),
            ),
            // Buttons
            Positioned(
              bottom: 50.h, // Scale bottom position
              left: 20.w, // Scale left position
              right: 20.w, // Scale right position
              child:
                  currentPage < 2
                      ? Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 150.w, // Scale width
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: 35.h,
                            ), // Scale bottom padding
                            child: ElevatedButton(
                              onPressed: () {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  67,
                                  118,
                                  199,
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 10.h,
                                ), // Scale vertical padding
                              ),
                              child: Text(
                                "Suivant",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp, // Scale font size
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      : Column(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 11.h,
                              ), // Scale top padding
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigate to Signup Screen
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const SignupScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    67,
                                    118,
                                    199,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10.h, // Scale vertical padding
                                    horizontal:
                                        40.w, // Scale horizontal padding
                                  ),
                                ),
                                child: Text(
                                  "Commencez maintenant",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 21.sp, // Scale font size
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15.h), // Scale height
                          Align(
                            alignment: Alignment.center,
                            child: FittedBox(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const GoogleAuthScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    45,
                                    55,
                                    72,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8.h, // Scale vertical padding
                                    horizontal:
                                        25.w, // Scale horizontal padding
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 30.h, // Scale height
                                      child: Image.asset(
                                        'assets/images/google.png',
                                        height: 20.h, // Scale image height
                                      ),
                                    ),
                                    SizedBox(width: 10.w), // Scale width
                                    Text(
                                      "Inscrivez-vous avec Google",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.sp, // Scale font size
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required String image,
  }) {
    return Padding(
      padding: EdgeInsets.all(30.w), // Scale padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 280.h, // Scale image height
            fit: BoxFit.contain,
          ),
          SizedBox(height: 20.h), // Scale height
          Text(
            title,
            style: TextStyle(
              fontSize: 26.sp, // Scale font size
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16.sp, // Scale font size
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50.h), // Scale height
        ],
      ),
    );
  }
}

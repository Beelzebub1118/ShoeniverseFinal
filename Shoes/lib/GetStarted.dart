import 'package:flutter/material.dart';
import 'LogReg.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _arrowAnimationController = AnimationController(
      duration: const Duration(seconds: 1), // Duration of the animation
      vsync: this,
    )..repeat(reverse: true); // Loop animation with reverse

    // Define the tween for the animation (moving up and down)
    _arrowAnimation = Tween<double>(begin: 0, end: 20).animate(CurvedAnimation(
      parent: _arrowAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // Create a PageController and set the initial page to 0 (the first page)
    PageController pageController = PageController(initialPage: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFA94D0B), // Background color
      body: PageView(
        controller: pageController, // Set the controller for the PageView
        scrollDirection: Axis.vertical, // Scroll vertically
        children: [
          // First Page: "Get Started"
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF111111), // Dark gray
                  Color(0xFFA94D0B), // Brownish orange
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Bottom "NIKE" Text (behind the image)
                  Positioned(
                    top: screenHeight * 0.30, // Position it relative to height
                    child: Text(
                      'NIKE',
                      style: TextStyle(
                        fontFamily: 'Russo',
                        fontSize: screenWidth * 0.4, // Increased size for responsiveness
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 1
                          ..color = Colors.white.withOpacity(0.65), // Lighter outline for visibility
                      ),
                    ),
                  ),
                  // Centered Shoe Image
                  Positioned(
                    top: screenHeight * 0.075, // Centered position for shoe image
                    child: Image.asset(
                      'images/GetStartShoes.png',
                      width: screenWidth * 1.0, // Increased size for responsiveness
                    ),
                  ),
                  // Top "NIKE" Text
                  Positioned(
                    top: screenHeight * 0.15, // Adjusted position for top "NIKE" text
                    child: Text(
                      'NIKE',
                      style: TextStyle(
                        fontFamily: 'Russo',
                        fontSize: screenWidth * 0.4, // Increased size for responsiveness
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 1
                          ..color = Colors.white.withOpacity(0.65), // Outline color
                      ),
                    ),
                  ),
                  // Additional Text "LIVE YOUR"
                  Positioned(
                    top: screenHeight * 0.55, // Position it below the second "NIKE" text
                    child: Text(
                      'LIVE YOUR',
                      style: TextStyle(
                        fontFamily: 'Squada',
                        fontSize: screenWidth * 0.23, // Size for the additional text
                        color: Colors.white, // Regular text color
                      ),
                    ),
                  ),
                  // "PERFECT" Text at the bottom
                  Positioned(
                    bottom: screenHeight * 0.210, // Position it near the bottom of the screen
                    child: Text(
                      'PERFECT',
                      style: TextStyle(
                        fontFamily: 'Squada',
                        fontSize: screenWidth * 0.25, // Size for the additional text
                        color: Colors.white, // Regular text color
                      ),
                    ),
                  ),
                  // Animated "VectorWhite" Image
                  Positioned(
                    bottom: screenHeight * 0.09, // Adjust position above the bottom
                    child: AnimatedBuilder(
                      animation: _arrowAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_arrowAnimation.value), // Move image up and down
                          child: child,
                        );
                      },
                      child: Image.asset(
                        'images/VectorWhite.png',
                        width: screenWidth * 0.20, // Adjusted width for image
                      ),
                    ),
                  ),
                  // Animated "VectorGray" Image
                  Positioned(
                    bottom: screenHeight * 0.07, // Adjust position above the bottom
                    child: AnimatedBuilder(
                      animation: _arrowAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_arrowAnimation.value * 0.7), // Slightly offset animation
                          child: child,
                        );
                      },
                      child: Image.asset(
                        'images/VectorGray.png',
                        width: screenWidth * 0.18, // Slightly smaller width for image
                      ),
                    ),
                  ),
                  // "GET STARTED" Text
                  Positioned(
                    bottom: screenHeight * 0.05, // Position it above the arrows
                    child: Text(
                      'GET STARTED',
                      style: TextStyle(
                        fontFamily: 'Abel',
                        fontSize: screenWidth * 0.05, // Size for the text
                        color: Colors.white.withOpacity(0.50), // Regular text color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Second Page: LogReg Page
          const LogReg(), // Use your LogReg widget here
        ],
      ),
    );
  }
}

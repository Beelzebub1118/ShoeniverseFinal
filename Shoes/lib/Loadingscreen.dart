import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async'; // Required for Timer
import 'GetStarted.dart'; // Import the GetStarted page

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Set wobbling duration
      vsync: this,
    )..repeat(); // Repeat the animation indefinitely

    // Navigate to GetStarted.dart after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'images/loadingscreen.png', // Background image
            fit: BoxFit.cover,
          ),

          // Center content
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // The wobbling ring
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final wobbleAngle = sin(_controller.value * 2 * pi) * 1;

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateX(wobbleAngle), // Apply wobbling to the ring
                      child: CustomPaint(
                        size: const Size(250, 250),
                        painter: RingPainter(), // Painter for the ring
                      ),
                    );
                  },
                ),

                // Static logo (does not move)
                Image.asset(
                  'images/loadingscreenlogo.png',
                  height: 180,
                  width: 180,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the black ring
class RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black // Color of the ring
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0; // Thickness of the ring

    // Draw the tilted ellipse (ring)
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2); // Move to center
    canvas.rotate(-0.3); // Tilt for the 3D effect
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, 0),
        width: size.width * 1.2, // Horizontal size of the ring
        height: size.height * 0.4, // Vertical size of the ring
      ),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint unless properties change
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Dashboard.dart'; // Import the Dashboard widget
import 'Register.dart'; // Import Register.dart to navigate to it

class LogReg extends StatefulWidget {
  const LogReg({super.key});

  @override
  _LogRegState createState() => _LogRegState();
}

class _LogRegState extends State<LogReg> {
  bool _isPasswordVisible = false; // To toggle password visibility
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginUser() async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Navigate to Dashboard on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = "No user found for this email.";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password.";
      } else {
        message = "Login failed. Please try again.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFA94D0B),
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF111111),
                Color(0xFFA94D0B),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: screenHeight * 0.25,
                left: screenWidth * 0.1,
                child: Image.asset(
                  'images/Group 115 1.png',
                  height: screenHeight * 0.12,
                  width: screenWidth * 0.8,
                  fit: BoxFit.cover,
                ),
              ),
              // LOG IN Text Positioning
              Positioned(
                top: screenHeight * 0.49,
                left: screenWidth * 0.1,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Add your login logic here
                      },
                      child: const Text(
                        "LOG IN",
                        style: TextStyle(
                          fontFamily: 'Abel',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 2,
                      width: 50,
                      color: Colors.white,
                      margin: const EdgeInsets.only(top: 0),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: screenHeight * 0.49,
                left: screenWidth * 0.28,
                child: const Text(
                  "|",
                  style: TextStyle(
                    fontFamily: 'Abel',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // REGISTER Text Positioning with Navigation
              Positioned(
                top: screenHeight * 0.49,
                left: screenWidth * 0.33,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const RegisterScreen(),
                        transitionsBuilder: (_, animation, __, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          final tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: const Text(
                    "REGISTER",
                    style: TextStyle(
                      fontFamily: 'Abel',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.56,
                left: screenWidth * 0.1,
                right: screenWidth * 0.1,
                child: TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: .5, top: 8),
                      child: Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                    hintText: 'sampleemail@gmail.com',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.transparent,
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    contentPadding:
                    const EdgeInsets.only(top: 20, bottom: 2, left: 40),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.63,
                left: screenWidth * 0.1,
                right: screenWidth * 0.1,
                child: TextField(
                  controller: passwordController,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 0.5),
                      child: Icon(Icons.lock, color: Colors.white, size: 40),
                    ),
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.transparent,
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    contentPadding:
                    const EdgeInsets.only(top: 20, bottom: 2, left: 40),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.73,
                left: screenWidth * 0.1,
                right: screenWidth * 0.1,
                child: GestureDetector(
                  onTap: loginUser, // Trigger login logic
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.asset(
                          'images/Recblack.png',
                          fit: BoxFit.cover,
                          height: 60,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: screenWidth * 0.03,
                        child: Image.asset(
                          'images/Recwhite.png',
                          fit: BoxFit.cover,
                          height: 60,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: screenWidth * 0.0,
                        child: Image.asset(
                          'images/Recbrown.png',
                          fit: BoxFit.cover,
                          height: 60,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 20,
                        right: 0,
                        child: Container(
                          height: 60,
                          alignment: Alignment.center,
                          child: Text(
                            "LOG IN",
                            style: TextStyle(
                              fontFamily: 'Arial',
                              color: Colors.white,
                              fontSize: screenHeight * 0.025,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

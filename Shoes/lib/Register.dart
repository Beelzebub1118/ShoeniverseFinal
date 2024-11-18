import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LogReg.dart'; // Assuming this is your Get Started screen

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isChecked = false; // Track checkbox state
  bool _isPasswordVisible = false; // Track password visibility
  bool _isConfirmPasswordVisible = false; // Track confirm password visibility
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      // Step 1: Register user with Firebase Authentication
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Step 2: Save additional user details to Firestore
      final String uid = userCredential.user!.uid; // Unique user ID from Firebase Authentication
      await _firestore.collection('users').doc(uid).set({
        'fullName': fullNameController.text.trim(),
        'contactNumber': contactNumberController.text.trim(),
        'address': addressController.text.trim(),
        'email': usernameController.text.trim(),
      }).then((_) {
        print("Data written to Firestore successfully");
      }).catchError((e) {
        print("Error writing data: $e");
      });

      // Step 3: Show success message and navigate back to LogReg
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LogReg()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred.";
      if (e.code == 'email-already-in-use') message = "Email already in use.";
      if (e.code == 'invalid-email') message = "Invalid email address.";
      if (e.code == 'weak-password') message = "Password should be at least 6 characters.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred. Try again.")),
      );
      print("Firestore Error: $e"); // Log Firestore error for debugging
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
          child: Column(
            children: [
              // Profile image
              Container(
                margin: EdgeInsets.only(top: screenHeight * 0.1),
                alignment: Alignment.center,
                child: Image.asset(
                  'images/Profile.png', // Replace with your image
                  height: screenHeight * 0.2,
                  width: screenWidth * 0.5,
                  fit: BoxFit.contain,
                ),
              ),
              // Input fields and checkbox
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildLabel("ENTER FULL NAME"),
                    _buildTextField(controller: fullNameController),
                    const SizedBox(height: 5),
                    _buildLabel("CONTACT NUMBER"),
                    _buildTextField(controller: contactNumberController),
                    const SizedBox(height: 5),
                    _buildLabel("ADDRESS"),
                    _buildTextField(controller: addressController),
                    const SizedBox(height: 5),
                    _buildLabel("USERNAME (EMAIL)"),
                    _buildTextField(controller: usernameController),
                    const SizedBox(height: 5),
                    _buildLabel("PASSWORD"),
                    _buildTextField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
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
                    const SizedBox(height: 5),
                    _buildLabel("CONFIRM PASSWORD"),
                    _buildTextField(
                      controller: confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (bool? newValue) {
                            setState(() {
                              isChecked = newValue!;
                            });
                          },
                          activeColor: Colors.green,
                          checkColor: Colors.black,
                          fillColor: MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        const SizedBox(width: 10),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'Abel',
                              color: Colors.white,
                              fontSize: screenWidth * 0.040,
                            ),
                            children: <TextSpan>[
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'terms and policies',
                                style: const TextStyle(decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()..onTap = () {
                                  // Add logic for terms and conditions
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // Check if all fields are filled and agree to the terms and conditions
                        if (fullNameController.text.isEmpty ||
                            contactNumberController.text.isEmpty ||
                            addressController.text.isEmpty ||
                            usernameController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty) {
                          // Show a centered dialog with the message
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: const Text("Please fill out all the fields."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (!isChecked) {
                          // Show a dialog if terms and conditions are not agreed
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: const Text("Please agree to terms and policies."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (passwordController.text != confirmPasswordController.text) {
                          // Show a dialog if passwords do not match
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: const Text("Passwords do not match."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          // All conditions are met, proceed with registration
                          registerUser();
                        }
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.asset(
                              'images/Recblack.png', // Black background for the button
                              fit: BoxFit.cover,
                              height: 60,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: screenWidth * 0.03,
                            child: Image.asset(
                              'images/Recwhite.png', // White part of the button
                              fit: BoxFit.cover,
                              height: 60,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: screenWidth * 0.0,
                            child: Image.asset(
                              'images/Recbrown.png', // Brown part of the button
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
                                "REGISTER",
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  color: Colors.white,
                                  fontSize: screenHeight * 0.025, // Adjust size to fit
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontFamily: 'Abel', color: Colors.white, fontSize: 16),
    );
  }

  Widget _buildTextField({
    bool obscureText = false,
    required TextEditingController controller,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

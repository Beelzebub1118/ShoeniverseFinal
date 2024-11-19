import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Account_settings.dart'; // Import Account_settings.dart
import 'LogReg.dart'; // Import LogReg for navigating back to login screen
import 'SellerDashboard.dart'; // Import SellerDashboard.dart
import 'Cart.dart';
import 'ORDERS.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String fullName = '';
  String contactNumber = '';
  String address = '';
  String email = '';

  // Fetch user data from Firestore
  Future<void> _getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        setState(() {
          fullName = userData['fullName'] ?? 'No name available';
          contactNumber = userData['contactNumber'] ?? 'No contact number available';
          address = userData['address'] ?? 'No address available';
          email = userData['email'] ?? 'No email available';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData(); // Fetch the user data when the profile screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            // Profile Image
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile_image.png'), // Replace with actual image path
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName.isEmpty ? 'Loading...' : fullName, // Display the name from Firestore
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 2),
            const SizedBox(height: 20),
            // Options List
            ProfileOption(
              icon: Icons.list_alt,
              label: "ORDERS",
              onTap: () {
                // Navigate to ShoppingBagScreen when "BAG" is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Orders(), // Remove 'const' here
                  ),
                );
              },
            ),
            ProfileOption(
              icon: Icons.shopping_bag_outlined,
              label: "BAG",
              onTap: () {
                // Navigate to ShoppingBagScreen when "BAG" is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cart(), // Remove 'const' here
                  ),
                );
              },
            ),
            ProfileOption(
              icon: Icons.inventory_2_outlined,
              label: "PRODUCT",
              onTap: () {
                // Navigate to Seller Dashboard page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SellerDashboard(), // Navigate to Seller Dashboard
                  ),
                );
              },
            ),
            ProfileOption(
              icon: Icons.settings,
              label: "ACCOUNT SETTINGS",
              onTap: () {
                // Navigate to Account Settings page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountSettingsPage(),
                  ),
                );
              },
            ),
            const Spacer(),
            // Logout Button
            ElevatedButton(
              onPressed: () {
                _showLogOutDialog(context); // Show logout confirmation dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                ),
              ),
              child: const Text(
                "LOG OUT",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Function to show the log out confirmation dialog
  void _showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut(); // Sign out the user
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LogReg()), // Navigate back to LogReg (login screen)
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileOption({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
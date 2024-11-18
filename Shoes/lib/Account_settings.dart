import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AccountEdit.dart'; // Import AccountEdit page

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({Key? key}) : super(key: key);

  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for the editable fields
  TextEditingController fullNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Fetch user data from Firestore
  Future<void> _getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        setState(() {
          fullNameController.text = userData['fullName'] ?? 'No name available';
          contactNumberController.text = userData['contactNumber'] ?? 'No contact number available';
          addressController.text = userData['address'] ?? 'No address available';
          usernameController.text = userData['email'] ?? 'No email available';
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
        title: const Text(
          'ACCOUNT SETTINGS',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile_image.png'), // Replace with actual image path
              ),
            ),
            const SizedBox(height: 16),
            // Orange Rectangle Edit Button
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  // Navigate to AccountEdit page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountEdit(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(width: 270),
                      Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Form Fields with Labels
            CustomTextField(label: 'NAME:', initialValue: fullNameController.text),
            CustomTextField(label: 'CONTACT NUMBER:', initialValue: contactNumberController.text),
            CustomTextField(label: 'ADDRESS:', initialValue: addressController.text),
            CustomTextField(label: 'USERNAME:', initialValue: usernameController.text),
            CustomTextField(label: 'PASSWORD:', initialValue: '************', isObscured: true),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String initialValue;
  final bool isObscured;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.initialValue,
    this.isObscured = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: TextEditingController(text: initialValue),
            obscureText: isObscured,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(
              color: Colors.black,
            ),
            readOnly: true, // Makes the field non-editable for now
          ),
        ],
      ),
    );
  }
}

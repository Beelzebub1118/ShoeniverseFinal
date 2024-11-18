import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountEdit extends StatefulWidget {
  const AccountEdit({Key? key}) : super(key: key);

  @override
  _AccountEditState createState() => _AccountEditState();
}

class _AccountEditState extends State<AccountEdit> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for the editable fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isEditable = false;

  // Fetch user data from Firestore
  Future<void> _getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        setState(() {
          fullNameController.text = userData['fullName'] ?? '';
          contactNumberController.text = userData['contactNumber'] ?? '';
          addressController.text = userData['address'] ?? '';
          usernameController.text = user.email ?? '';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Function to save edited data
  Future<void> _saveChanges() async {
    User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user is logged in.")),
      );
      return;
    }

    String fullName = fullNameController.text.trim();
    String contactNumber = contactNumberController.text.trim();
    String address = addressController.text.trim();
    String username = usernameController.text.trim();
    String currentPassword = currentPasswordController.text.trim();
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.")),
      );
      return;
    }

    try {
      // Reauthenticate the user if password is being updated
      if (currentPassword.isNotEmpty) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Update user details in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'fullName': fullName,
        'contactNumber': contactNumber,
        'address': address,
        'email': username,
      });

      // Update email in Firebase Authentication
      if (username.isNotEmpty && username != user.email) {
        await user.updateEmail(username);
      }

      // Update password in Firebase Authentication
      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account details updated successfully!")),
      );

      setState(() {
        isEditable = false;
      });

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
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
            Stack(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: const AssetImage('assets/profile_image.png'),
                  ),
                ),
                Positioned(
                  top: 100,
                  right: MediaQuery.of(context).size.width / 2 - 55,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.add,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isEditable = true;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.edit, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'EDIT',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(label: 'NAME:', controller: fullNameController, isEditable: isEditable),
            CustomTextField(label: 'CONTACT NUMBER:', controller: contactNumberController, isEditable: isEditable),
            CustomTextField(label: 'ADDRESS:', controller: addressController, isEditable: isEditable),
            CustomTextField(label: 'USERNAME:', controller: usernameController, isEditable: isEditable),
            CustomTextField(label: 'CURRENT PASSWORD:', controller: currentPasswordController, isEditable: isEditable, isObscured: true),
            CustomTextField(label: 'NEW PASSWORD:', controller: newPasswordController, isEditable: isEditable, isObscured: true),
            CustomTextField(label: 'CONFIRM PASSWORD:', controller: confirmPasswordController, isEditable: isEditable, isObscured: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: isEditable ? _saveChanges : null,
                child: const Text(
                  'SAVE CHANGES',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditable;
  final bool isObscured;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.isEditable = false,
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
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            obscureText: isObscured,
            readOnly: !isEditable,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

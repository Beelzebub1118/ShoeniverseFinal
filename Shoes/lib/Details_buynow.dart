import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Thankyou.dart'; // Import ThankYou screen

class DetailsBuyNow extends StatefulWidget {
  final String imagePath;
  final String title;
  final String price;
  final int? selectedSize;
  final int quantity;

  const DetailsBuyNow({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.price,
    required this.selectedSize,
    required this.quantity,
  }) : super(key: key);

  @override
  _DetailsBuyNowState createState() => _DetailsBuyNowState();
}

class _DetailsBuyNowState extends State<DetailsBuyNow> {
  int quantity = 1;
  final int deliveryFee = 55;

  // Formatter to add commas to thousands
  final NumberFormat currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  // Calculate subtotal based on quantity and price
  double get subtotal => quantity * double.parse(widget.price.replaceAll('₱', '').replaceAll(',', ''));

  // Calculate total with delivery fee
  double get total => subtotal + deliveryFee;

  // Generate a random delivery range between 3-5 days and show a date
  String get estimatedDeliveryDetails {
    final random = Random();
    final minDays = random.nextInt(3) + 3; // Random start between 3 and 5 days
    final maxDays = minDays + 1; // End day for range (e.g., 3 - 4 days)

    // Estimate a specific date range
    final estimatedDate = DateTime.now().add(Duration(days: minDays));
    final estimatedDateString = DateFormat('MMMM dd, yyyy').format(estimatedDate);

    return "$minDays - $maxDays days (by $estimatedDateString)";
  }

  @override
  void initState() {
    super.initState();
    quantity = widget.quantity;
  }

  // Add order to Firestore
  Future<void> _addOrderToFirestore() async {
    // Add order to Firestore under the current user's Orders subcollection
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to place an order')),
      );
      return;
    }

// Fetching the user's real data, replace placeholders
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    final orderData = {
      'userId': user.uid,
      'imagePath': widget.imagePath,
      'title': widget.title,
      'size': widget.selectedSize ?? 'Not selected',
      'quantity': quantity,
      'price': widget.price,
      'subtotal': currencyFormat.format(subtotal),
      'deliveryFee': currencyFormat.format(deliveryFee),
      'total': currencyFormat.format(total),
      'timestamp': FieldValue.serverTimestamp(), // For ordering by date in Orders.dart
      'name': userData['fullName'] ?? 'No name', // Assuming full name is in the user data
      'contactNumber': userData['contactNumber'] ?? 'No contact',
      'address': userData['address'] ?? 'No address',
      'paymentMethod': 'Cash on Delivery', // Modify as needed
    };

    try {
      // Add the order to Firestore under the current user's Orders subcollection
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('Orders').add(orderData);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ThankYou()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Image.asset(
                widget.imagePath,
                height: 200,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            // Product Title and Price
            Text(
              widget.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "PRICE:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              currencyFormat.format(double.parse(widget.price.replaceAll('₱', '').replaceAll(',', ''))),
              style: const TextStyle(fontSize: 16, color: Colors.green), // Price color set to green
            ),
            const SizedBox(height: 10),
            // Size and Quantity Selector
            Text(
              "Size: ${widget.selectedSize ?? 'Not selected'}",
              style: const TextStyle(fontSize: 16),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },
                ),
                Text(
                  quantity.toString(),
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Subtotal, Estimated Delivery, Total
            const Text(
              "SUBTOTAL:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              currencyFormat.format(subtotal),
              style: const TextStyle(fontSize: 16, color: Colors.green), // Subtotal color set to green
            ),
            const SizedBox(height: 10),
            const Text(
              "ESTIMATED DELIVERY:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "$estimatedDeliveryDetails (${currencyFormat.format(deliveryFee)})",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "TOTAL:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              currencyFormat.format(total),
              style: const TextStyle(fontSize: 16, color: Colors.green), // Total color set to green
            ),
            const Spacer(),
            // Cancel and Buy Now Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Action for "Cancel"
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Adjusted radius
                      ),
                    ),
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _addOrderToFirestore(); // Add order to Firestore when BUY NOW is pressed
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Adjusted radius
                      ),
                    ),
                    child: const Text(
                      "BUY NOW",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

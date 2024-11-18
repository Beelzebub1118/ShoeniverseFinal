import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'package:firebase_auth/firebase_auth.dart';
import 'Details_buynow.dart'; // Firebase Auth package

class Details extends StatefulWidget {
  final String imagePath;
  final String title;
  final String price;

  const Details({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.price,
  }) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int? selectedSize; // Selected shoe size
  int quantity = 1; // Quantity of item to add

  // Firebase instance for Firestore and Auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to display a custom prompt dialog
  void _showPromptDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners for the dialog
        ),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange, size: 28),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to add item to the user's Firestore Orders collection
  Future<void> _addToCart() async {
    if (selectedSize == null) {
      _showPromptDialog(
        "Select Size",
        "Please select a size before adding to the orders.",
      );
      return;
    }

    // Get the current user
    final user = _auth.currentUser;
    if (user == null) {
      _showPromptDialog(
        "Login Required",
        "Please log in to add items to the orders.",
      );
      return;
    }

    final userId = user.uid;

    // Generate a unique order ID
    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

    // Reference to the Orders collection
    final orderRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('ToBeOrdered')
        .doc(orderId);

    try {
      await orderRef.set({
        'userId': userId,
        'imagePath': widget.imagePath,
        'title': widget.title,
        'price': double.parse(widget.price.replaceAll(RegExp(r'[^\d.]'), '')), // Ensure price is numeric
        'quantity': quantity,
        'size': selectedSize!,
        'timestamp': FieldValue.serverTimestamp(),
        'total': quantity * double.parse(widget.price.replaceAll(RegExp(r'[^\d.]'), '')), // Calculate total price
        'address': '', // Placeholder for address
        'contactNumber': '', // Placeholder for contact number
        'deliveryFee': 0, // Placeholder for delivery fee
        'paymentMethod': 'COD', // Example payment method
      });

      _showPromptDialog("Success", "Order has been placed.");
    } catch (e) {
      print("Error adding to Firestore: $e");
      _showPromptDialog("Error", "Failed to place order: $e");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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

            // Product Title and Description
            Text(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Comfortable, durable, and timeless. The '90s construction pairs with classic colors for style that tracks whether you're on court or on the go.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),

            // Size Selection Section
            const Text("SELECT SIZE:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [30, 31, 32, 33, 34].map((size) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSize = size;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: selectedSize == size ? Colors.orange : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Text(
                      size.toString(),
                      style: TextStyle(
                        color: selectedSize == size ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Quantity Selector
            const Text("QUANTITY:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                Text(quantity.toString(), style: const TextStyle(fontSize: 18)),
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

            // Price
            const Text("PRICE:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              widget.price,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const Spacer(),

            // Add to Bag and Checkout Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text("ADD TO BAG", style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedSize == null) {
                        _showPromptDialog(
                          "Select Size",
                          "Please select a size before proceeding to checkout.",
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsBuyNow(
                              imagePath: widget.imagePath,
                              title: widget.title,
                              price: widget.price,
                              selectedSize: selectedSize!,
                              quantity: quantity,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text("CHECKOUT", style: TextStyle(color: Colors.white)),
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

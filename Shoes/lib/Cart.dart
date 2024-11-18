import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Dashboard.dart'; // Import Dashboard screen
import 'Searchbar.dart'; // Import Searchbar screen
import 'Profile.dart'; // Import Profile screen
import 'order_summary.dart'; // Import the Order Summary screen

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<bool> selectedItems = []; // Tracks selected checkboxes
  List<Map<String, dynamic>> cartItems = []; // Holds fetched cart items

  // Function to fetch the cart items from Firestore
  Stream<List<Map<String, dynamic>>> _fetchCartItems() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('ToBeOrdered')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'docId': doc.id,
          'imagePath': data['imagePath'],
          'title': data['title'],
          'size': data['size'],
          'price': data['price'],
          'quantity': data['quantity'],
        };
      }).toList();
    });
  }

  // Function to calculate the total price of selected items
  double calculateTotal() {
    double total = 0;
    for (int i = 0; i < cartItems.length; i++) {
      if (selectedItems[i]) {
        total += (cartItems[i]['price'] as num).toDouble() * (cartItems[i]['quantity'] as int).toDouble();
      }
    }
    return total;
  }

  // Function to delete an item from Firestore and the local list
  Future<void> _deleteItem(int index) async {
    final docId = cartItems[index]['docId'];
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('ToBeOrdered')
          .doc(docId)
          .delete();
      setState(() {
        cartItems.removeAt(index);
        selectedItems.removeAt(index);
      });
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  // Navigation logic for smooth transitions
  void _onItemTapped(BuildContext context, int index) {
    if (index == 2) return; // Cart is already selected

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = const Dashboard();
        break;
      case 1:
        targetPage = const Searchbar();
        break;
      case 3:
        targetPage = Profile();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeInOutCubic;
          final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'BAG',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>( // Fetch cart items
                  stream: _fetchCartItems(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Your bag is empty!',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      );
                    }

                    cartItems = snapshot.data!;
                    if (selectedItems.length != cartItems.length) {
                      selectedItems = List.generate(cartItems.length, (index) => false);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: selectedItems[index],
                                onChanged: (value) {
                                  setState(() {
                                    selectedItems[index] = value!;
                                  });
                                },
                                activeColor: Colors.orange,
                              ),
                              const SizedBox(width: 8.0),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: item['imagePath'] != null && item['imagePath'].isNotEmpty
                                    ? Image.asset(
                                  item['imagePath'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                                    : Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: const Center(child: Text('No Image')),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] ?? 'No Title',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'SIZE: ${item['size'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 14.0, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'PRICE: ₱${item['price'] ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteItem(index);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 100, // Positioned above the navigation bar
            left: 25,
            right: 25,
            child: selectedItems.contains(true) // Check if any item is selected
                ? Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15), // Add rounded corners
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL: ₱${calculateTotal().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedCartItems = cartItems
                          .asMap()
                          .entries
                          .where((entry) => selectedItems[entry.key])
                          .map((entry) => entry.value)
                          .toList();

                      if (selectedCartItems.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select at least one item to proceed.')));
                        return;
                      }

                      // Pass selected items to OrderSummary and process the order
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderSummary(selectedItems: selectedCartItems),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6), // Add rounded corners to the button
                      ),
                    ),
                    child: const Text(
                      'CHECKOUT',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
                : const SizedBox.shrink(), // Hide the container when no item is selected
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CurvedNavigationBar(
              height: 65.0,
              backgroundColor: Colors.transparent,
              buttonBackgroundColor: Colors.deepOrange,
              items: const <Widget>[
                Icon(Icons.home_outlined, size: 35, color: Colors.grey),
                Icon(Icons.search_outlined, size: 35, color: Colors.grey),
                Icon(Icons.shopping_cart_outlined, size: 35, color: Colors.white),
                Icon(Icons.person_outline, size: 35, color: Colors.grey),
              ],
              index: 2,
              onTap: (index) => _onItemTapped(context, index),
            ),
          ),
        ],
      ),
    );
  }
}

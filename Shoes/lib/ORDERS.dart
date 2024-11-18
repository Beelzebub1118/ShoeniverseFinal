import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Orders extends StatelessWidget {
  const Orders({Key? key}) : super(key: key);

  // Fetch orders for the current user from Firestore
  Stream<List<Map<String, dynamic>>> _fetchOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('Orders')
        .snapshots()  // real-time updates
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'imagePath': data['imagePath'] ?? '',
          'title': data['title'] ?? 'No Title',
          'size': data['size'] ?? 'N/A',
          'price': data['price'] ?? 0.0,
          'name': data['name'] ?? 'N/A',
          'contact': data['contactNumber'] ?? 'N/A',
          'address': data['address'] ?? 'N/A',
          'paymentMethod': data['paymentMethod'] ?? 'N/A',
          'orderDate': data['orderDate'] ?? '',
          'docId': doc.id, // Add docId for potential future use
        };
      }).toList();
    });
  }

  // Helper function to handle the orderDate format
  String _getFormattedDate(dynamic orderDate) {
    if (orderDate is Timestamp) {
      // If orderDate is a Timestamp, convert it to DateTime and format it
      return orderDate.toDate().toString();
    } else if (orderDate is String) {
      // If orderDate is already a String, just return it
      return orderDate;
    } else {
      return 'N/A';  // Default case if orderDate is neither a String nor Timestamp
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ORDERS',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(  // Real-time data
        stream: _fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No orders found!',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Product Image (ensure the image path is valid and accessible)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: order["imagePath"] != null && order["imagePath"].isNotEmpty
                              ? (order["imagePath"].startsWith('http')
                              ? Image.network(
                            order["imagePath"]!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade200,
                                  child: const Center(child: Text('Image Not Found')),
                                ),
                          )
                              : Image.asset(
                            order["imagePath"]!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade200,
                                  child: const Center(child: Text('Image Not Found')),
                                ),
                          ))
                              : Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey.shade200,
                            child: const Center(child: Text('No Image')),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order["title"] ?? 'No Title',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                "SIZE: ${order["size"] ?? 'N/A'}",
                                style: const TextStyle(fontSize: 14.0),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                "PRICE: ₱${order["price"] ?? '₱0'}",
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 1.0, color: Colors.black),
                    const SizedBox(height: 8.0),
                    // Customer Details (should be pulled from Firestore for the current user)
                    Text(
                      "NAME: ${order["name"] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    Text(
                      "CONTACT NUMBER: ${order["contact"] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    Text(
                      "ADDRESS: ${order["address"] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    Text(
                      "PAYMENT METHOD: ${order["paymentMethod"] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    Text(
                      "ORDER DATE: ${_getFormattedDate(order["orderDate"])}",  // Format orderDate based on type
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

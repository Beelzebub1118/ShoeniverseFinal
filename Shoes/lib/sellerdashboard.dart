import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoeniverse/OrdersFromUsers.dart';
import 'Product.dart'; // Import Product.dart
import 'Edilete.dart'; // Import EditeletePage

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({Key? key}) : super(key: key);

  @override
  _SellerDashboardState createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  int selectedIndex = 0;
  String selectedCategory = 'LIFESTYLE'; // Default category in uppercase

  @override
  Widget build(BuildContext context) {
    // Get the current user's ID
    String userId = FirebaseAuth.instance.currentUser!.uid;

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
          'SELLER DASHBOARD',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('products')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildDashboardCard('-', 'PRODUCT'); // Placeholder while loading
                    }

                    final productCount = snapshot.data?.docs.length ?? 0;
                    return _buildDashboardCard('$productCount', 'PRODUCT');
                  },
                ),
                _buildDashboardCard('1', 'PENDING ORDER'), // Replace with a real-time count for pending orders if applicable
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PRODUCT',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to EditeletePage to see all products
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditeletePage()),
                    );
                  },
                  child: const Text(
                    'SEE ALL',
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              value: (['LIFESTYLE', 'DANCE', 'RUNNING', 'BASKETBALL', 'FOOTBALL']
                  .contains(selectedCategory))
                  ? selectedCategory
                  : null, // Ensure value matches one of the dropdown items
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              items: ['LIFESTYLE', 'DANCE', 'RUNNING', 'BASKETBALL', 'FOOTBALL']
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('products')
                    .where('category', isEqualTo: selectedCategory)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No products available.'));
                  }

                  final products = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final imageUrl = product['imageUrl'] ?? ''; // Default to empty string if imageUrl is missing

                      return _buildProductCard(
                        product['name'] ?? 'No Name', // Default to 'No Name' if name is missing
                        imageUrl.isNotEmpty && Uri.parse(imageUrl).isAbsolute
                            ? Image.network(imageUrl, fit: BoxFit.cover) // Network image if valid URL
                            : Image.asset('images/defaultShoe.png', fit: BoxFit.cover), // Default image if missing or invalid URL
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });

          if (index == 0) {
            // Stay on Seller Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SellerDashboard()),
            );
          } else if (index == 1) {
            // Navigate to Product.dart
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProductPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrdersFromUsers()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(String count, String label) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(String name, Widget imageWidget) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: imageWidget,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft, // Align title to the left
              child: Text(
                name,
                textAlign: TextAlign.left, // Explicitly set text alignment to left
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

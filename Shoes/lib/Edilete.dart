import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EditProduct.dart'; // Import the EditProductPage

class EditeletePage extends StatefulWidget {
  const EditeletePage({Key? key}) : super(key: key);

  @override
  _EditeletePageState createState() => _EditeletePageState();
}

class _EditeletePageState extends State<EditeletePage> {
  List<DocumentSnapshot> products = [];
  bool isLoading = true;
  String? selectedProductId; // Tracks which product is selected

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Fetch products when the page is loaded
  }

  // Fetch products from Firestore
  Future<void> _fetchProducts() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('products').get();
      setState(() {
        products = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  // Delete the selected product with confirmation
  Future<void> _deleteProduct() async {
    if (selectedProductId == null) return;

    final bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // User canceled
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // User confirmed
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(selectedProductId)
            .delete();
        setState(() {
          products.removeWhere((product) => product.id == selectedProductId);
          selectedProductId = null; // Clear the selection
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully!')),
        );
      } catch (e) {
        print('Error deleting product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete product!')),
        );
      }
    }
  }

  // Navigate to EditProductPage
  void _navigateToEditProduct() {
    if (selectedProductId == null) return; // Prevent navigation if no item selected
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProductPage(),
      ),
    );
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
          'LIFESTYLE',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final name = product['name'];
                final imageUrl = product['imageUrl'];
                final productId = product.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedProductId = productId; // Select the product
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    transform: selectedProductId == productId
                        ? Matrix4.identity() *
                        Matrix4.diagonal3Values(1.05, 1.05, 1.0)
                        : Matrix4.identity(),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: selectedProductId == productId
                          ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ]
                          : [
                        const BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 190,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10)),
                            color: Colors.grey[200],
                          ),
                          child: Center(
                            child: imageUrl.isNotEmpty
                                ? const Icon(Icons.broken_image,
                                size: 50, color: Colors.grey)
                                : const Icon(Icons.broken_image,
                                size: 50, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedProductId != null
                        ? _deleteProduct
                        : null, // Disable if no item is selected
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedProductId != null
                          ? Colors.red
                          : Colors.grey, // Change color when disabled
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('DELETE'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedProductId != null
                        ? _navigateToEditProduct
                        : null, // Disable if no item is selected
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedProductId != null
                          ? Colors.black
                          : Colors.grey, // Change color when disabled
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('EDIT'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

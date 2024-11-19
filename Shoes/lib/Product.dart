import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String? selectedCategory;
  String? selectedSize;
  bool isCashOnDelivery = false;
  bool isGcash = false;

  // Controllers for the fields
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // Categories list
  final List<String> categories = [
    'LIFESTYLE',
    'DANCE',
    'RUNNING',
    'BASKETBALL',
    'FOOTBALL',
  ];

  bool isSubmitting = false; // Prevents multiple submissions

  // Function to handle form submission
  Future<void> _submitProduct(String userId) async {
    String name = nameController.text;
    String category = selectedCategory ?? 'LIFESTYLE';
    String size = selectedSize ?? 'US 10';
    String price = priceController.text;
    String stock = stockController.text;
    String description = descriptionController.text;
    String imageUrl = 'images/defaultShoe.png'; // Default image URL

    // Add shipping options
    List<String> shippingOptions = [];
    if (isCashOnDelivery) shippingOptions.add("Cash on Delivery");
    if (isGcash) shippingOptions.add("G-Cash");

    try {
      // Saving data to Firestore under the user's products collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('products')
          .add({
        'name': name,
        'category': category,
        'size': size,
        'price': price,
        'stockQuantity': stock,
        'description': description,
        'imageUrl': imageUrl,
        'shippingOptions': shippingOptions,
      });

      // Show success and clear the form
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );

      // Clear fields
      nameController.clear();
      priceController.clear();
      stockController.clear();
      descriptionController.clear();
      setState(() {
        selectedCategory = null;
        selectedSize = null;
        isCashOnDelivery = false;
        isGcash = false;
      });
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Function to validate form inputs
  bool _validateInputs() {
    if (nameController.text.isEmpty ||
        selectedCategory == null ||
        selectedSize == null ||
        priceController.text.isEmpty ||
        stockController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        (!isCashOnDelivery && !isGcash)) {
      return false;
    }
    return true;
  }

  // Show error dialog for incomplete fields
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Incomplete Details'),
          content:
          const Text('Please complete all required fields before submitting.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show confirmation dialog
  Future<void> _showConfirmationDialog(Function onConfirm) async {
    bool hasConfirmed = false; // Scoped to this dialog only

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Submission'),
          content: const Text(
              'Are you sure you want to submit the product details?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!hasConfirmed) {
                  hasConfirmed = true;
                  Navigator.of(context).pop(true); // Confirm
                  onConfirm(); // Execute the callback
                }
              },
              child: const Text('CONFIRM'),
            ),
          ],
        );
      },
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
          'PRODUCT',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'PRODUCT DETAILS'),
            CustomTextField(hintText: 'Product Name', controller: nameController),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                hintText: 'Category',
                border: OutlineInputBorder(),
              ),
              value: selectedCategory,
              items: categories
                  .map((String category) => DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'IMAGE'),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'SIZING'),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                hintText: 'Size',
                border: OutlineInputBorder(),
              ),
              value: selectedSize,
              items: <String>['US', 'UK']
                  .map((String size) => DropdownMenuItem<String>(
                value: size,
                child: Text(size),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedSize = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'PRICING & INVENTORY'),
            CustomTextField(hintText: 'Price:', controller: priceController),
            CustomTextField(
                hintText: 'Stock Quantity:', controller: stockController),
            const SizedBox(height: 20),
            const SectionTitle(title: 'DESCRIPTION'),
            CustomTextField(
              hintText: 'Enter product description',
              maxLines: 3,
              controller: descriptionController,
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'SHIPPING DETAILS'),
            CheckboxListTile(
              title: const Text("CASH ON DELIVERY"),
              value: isCashOnDelivery,
              onChanged: (value) {
                setState(() {
                  isCashOnDelivery = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text("G-CASH"),
              value: isGcash,
              onChanged: (value) {
                setState(() {
                  isGcash = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () async {
                  if (_validateInputs()) {
                    if (!isSubmitting) {
                      setState(() => isSubmitting = true);
                      String userId = FirebaseAuth.instance.currentUser!.uid;
                      await _showConfirmationDialog(() async {
                        await _submitProduct(userId);
                        setState(() => isSubmitting = false);
                      });
                    }
                  } else {
                    _showErrorDialog();
                  }
                },
                child: const Text(
                  'SUBMIT',
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

// Section Title Widget
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown,
              fontSize: 16,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Divider(
            color: Colors.brown,
            thickness: 1.5,
          ),
        ),
      ],
    );
  }
}

// Custom Text Field Widget
class CustomTextField extends StatelessWidget {
  final String hintText;
  final int maxLines;
  final TextEditingController controller;
  const CustomTextField(
      {Key? key, required this.hintText, this.maxLines = 1, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

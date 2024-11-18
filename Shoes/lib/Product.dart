import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    'FOOTBALL'
  ];

  // Function to handle form submission
  Future<void> _submitProduct() async {
    String name = nameController.text;
    String category = selectedCategory ?? 'LIFESTYLE';
    String size = selectedSize ?? 'US 10';
    String price = priceController.text;
    String stock = stockController.text;
    String description = descriptionController.text;
    String imageUrl = 'images/defaultShoe.png'; // Static image URL

    // Add shipping options
    List<String> shippingOptions = [];
    if (isCashOnDelivery) shippingOptions.add("Cash on Delivery");
    if (isGcash) shippingOptions.add("G-Cash");

    // Saving data to Firestore
    await FirebaseFirestore.instance.collection('products').add({
      'name': name,
      'category': category,
      'size': size,
      'price': price,
      'stockQuantity': stock,
      'description': description,
      'imageUrl': imageUrl, // Static image URL
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
          content: const Text('Please complete all required fields before submitting.'),
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
  Future<void> _showConfirmationDialog() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Submission'),
          content: const Text('Are you sure you want to submit the product details?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: const Text('CONFIRM'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _submitProduct(); // Proceed with submission
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
            CustomTextField(hintText: 'Stock Quantity:', controller: stockController),
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
                onPressed: () {
                  if (_validateInputs()) {
                    _showConfirmationDialog(); // Show confirmation dialog if inputs are valid
                  } else {
                    _showErrorDialog(); // Show error dialog if inputs are incomplete
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
class CustomTextField extends StatefulWidget {
  final String hintText;
  final int maxLines;
  final TextEditingController controller;
  const CustomTextField(
      {Key? key, required this.hintText, this.maxLines = 1, required this.controller})
      : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late String _displayHint;

  @override
  void initState() {
    super.initState();
    _displayHint = widget.hintText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _displayHint = hasFocus ? '' : widget.hintText;
          });
        },
        child: TextField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            hintText: _displayHint,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

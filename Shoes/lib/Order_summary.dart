import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Thankyou.dart';

class OrderSummary extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;

  const OrderSummary({Key? key, required this.selectedItems}) : super(key: key);

  @override
  _OrderSummaryState createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  String? _selectedPaymentMethod;
  Map<String, dynamic> userInfo = {};
  double totalPrice = 0.0;
  List<bool> checkedItems = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _initializeCheckedItems();
    _calculateTotal();
  }

  Future<void> _fetchUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userInfo = userDoc.data()!;
        });
      }
    }
  }

  void _initializeCheckedItems() {
    checkedItems = List.generate(widget.selectedItems.length, (_) => true);
  }

  void _calculateTotal() {
    totalPrice = 0.0;
    for (int i = 0; i < widget.selectedItems.length; i++) {
      if (checkedItems[i]) {
        final item = widget.selectedItems[i];
        final price = (item['price'] as num).toDouble();
        final quantity = (item['quantity'] as num).toDouble();
        totalPrice += price * quantity;
      }
    }
    setState(() {});
  }

  Future<void> _removePurchasedItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartCollection = _firestore.collection('users').doc(user.uid).collection('ToBeOrdered');
    final ordersCollection = _firestore.collection('users').doc(user.uid).collection('Orders');

    for (int i = 0; i < widget.selectedItems.length; i++) {
      if (checkedItems[i]) {
        final item = widget.selectedItems[i];
        final itemId = item['docId'];

        if (itemId != null) {
          try {
            // Add the item to the Orders collection
            await ordersCollection.add({
              'title': item['title'],
              'price': item['price'],
              'quantity': item['quantity'],
              'size': item['size'],
              'imagePath': item['imagePath'],
              'orderDate': FieldValue.serverTimestamp(),
              'paymentMethod': _selectedPaymentMethod ?? 'Cash on Delivery',
            });

            // Remove the item from the ToBeOrdered collection
            await cartCollection.doc(itemId).delete();
          } catch (e) {
            print('Error processing item $itemId: $e');
          }
        }
      }
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 28),
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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

  bool _isAnyItemChecked() {
    return checkedItems.contains(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedItems.length,
                itemBuilder: (context, index) {
                  final item = widget.selectedItems[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: checkedItems[index],
                          onChanged: (value) {
                            setState(() {
                              checkedItems[index] = value!;
                            });
                            _calculateTotal();
                          },
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: item['imagePath'] != null &&
                              item['imagePath'].isNotEmpty
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
                            child: const Center(
                              child: Text('No Image'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
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
                                style: const TextStyle(fontSize: 14.0),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'PRICE: ₱${item['price'] ?? 0.0}',
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
                  );
                },
              ),
            ),
            const Divider(),
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            RadioListTile<String>(
              value: 'Cash on Delivery',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              title: const Text('CASH ON DELIVERY'),
            ),
            RadioListTile<String>(
              value: 'G-Cash',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              title: const Text('G-CASH'),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(top: 16.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL: ₱${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_isAnyItemChecked()) {
                        _showDialog(
                          'No Items Selected',
                          'Please select at least one item to proceed.',
                        );
                      } else if (_selectedPaymentMethod == null) {
                        _showDialog(
                          'Payment Method Required',
                          'Please select a payment method to proceed.',
                        );
                      } else {
                        await _removePurchasedItems();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ThankYou(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'BUY NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

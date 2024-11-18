import 'package:flutter/material.dart';
import 'bag_item.dart';

class BagProvider with ChangeNotifier {
  final List<BagItem> _items = []; // List to store bag items

  // Get all items in the bag
  List<BagItem> get items => _items;

  // Get only selected items
  List<BagItem> get selectedItems =>
      _items.where((item) => item.selected).toList();

  // Add an item to the bag
  void addItem(BagItem item) {
    // Check if the item already exists in the bag
    final existingIndex = _items.indexWhere(
          (existing) =>
      existing.title == item.title &&
          existing.selectedSize == item.selectedSize,
    );

    if (existingIndex != -1) {
      // If the item exists, increase its quantity
      _items[existingIndex].quantity =
          (_items[existingIndex].quantity ?? 1) + (item.quantity ?? 1);
    } else {
      // Otherwise, add it as a new item, ensuring a default quantity of 1
      _items.add(BagItem(
        imagePath: item.imagePath,
        title: item.title,
        price: item.price,
        selectedSize: item.selectedSize,
        quantity: item.quantity ?? 1, // Ensure quantity is at least 1
        selected: item.selected,
      ));
    }
    notifyListeners(); // Notify listeners to update the UI
  }

  // Remove an item from the bag
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  // Toggle selection of an item
  void toggleSelection(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].selected = !_items[index].selected;
      notifyListeners();
    }
  }

  // Remove selected items after purchase
  void removePurchasedItems() {
    _items.removeWhere((item) => item.selected);
    notifyListeners(); // Update UI after removing items
  }

  // Calculate the total price of selected items
  int calculateTotalPrice() {
    try {
      return _items.fold(0, (sum, item) {
        if (item.selected) {
          // Safely parse and calculate price
          final sanitizedPrice =
          item.price.replaceAll(',', '').replaceAll('₱', '');
          final price = int.tryParse(sanitizedPrice) ?? 0;
          return sum + (price * (item.quantity ?? 1));
        }
        return sum;
      });
    } catch (e) {
      debugPrint('Error calculating total price: $e');
      return 0; // Return 0 if any error occurs
    }
  }

  // Check if there are any selected items
  bool hasSelectedItems() {
    return _items.any((item) => item.selected);
  }

  // Clear all items in the bag
  void clearBag() {
    _items.clear();
    notifyListeners();
  }

  // Update the quantity of an item
  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _items.length && newQuantity > 0) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  // Check if an item is already in the bag
  bool isItemInBag(BagItem item) {
    return _items.any((existing) =>
    existing.title == item.title &&
        existing.selectedSize == item.selectedSize);
  }
}

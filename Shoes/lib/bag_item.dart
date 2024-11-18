class BagItem {
  final String imagePath;
  final String title;
  final String price;
  final int selectedSize;
  int quantity; // Mutable property
  bool selected;

  BagItem({
    required this.imagePath,
    required this.title,
    required this.price,
    required this.selectedSize,
    this.quantity = 1, // Default to 1
    this.selected = false,
  });
}

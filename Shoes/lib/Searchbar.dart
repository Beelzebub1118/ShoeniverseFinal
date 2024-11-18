import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'Dashboard.dart'; // Import Dashboard screen
import 'Cart.dart'; // Import Cart screen
import 'Profile.dart'; // Import Profile screen

class Searchbar extends StatelessWidget {
  const Searchbar({Key? key}) : super(key: key);

  // Navigation logic for smooth transitions
  void _onItemTapped(BuildContext context, int index) {
    if (index == 1) return; // Search is already selected, no need to navigate

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = const Dashboard();
        break;
      case 2:
        targetPage = const Cart();
        break;
      case 3:
        targetPage = Profile();
        break;
      default:
        return;
    }

    // Custom page transition with SlideTransition
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
      resizeToAvoidBottomInset: false,  // Prevent UI resizing when keyboard appears
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Body content that will slide
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Search...",
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // "SHOP BY SPORT" Title
                const Text(
                  "SHOP BY SPORT",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                // Sport Categories
                Expanded(
                  child: ListView(
                    children: [
                      _buildSportCategory(context, 'Searchbarimages/running.png', 'RUNNING'),
                      _buildSportCategory(context, 'Searchbarimages/football.png', 'FOOTBALL'),
                      _buildSportCategory(context, 'Searchbarimages/basketball.png', 'BASKETBALL'),
                      _buildSportCategory(context, 'Searchbarimages/dance.png', 'DANCE'),
                      // Add padding specifically after the DANCE category
                      const SizedBox(height: 20),  // Padding for DANCE category
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Fixed Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CurvedNavigationBar(
              height: 65.0,
              backgroundColor: Colors.transparent,
              buttonBackgroundColor: Colors.deepOrange,
              items: <Widget>[
                Icon(Icons.home_outlined, size: 35, color: Colors.grey),
                Icon(Icons.search_outlined, size: 35, color: Colors.white), // Highlighted Search icon
                Icon(Icons.shopping_cart_outlined, size: 35, color: Colors.grey),
                Icon(Icons.person_outline, size: 35, color: Colors.grey),
              ],
              index: 1, // Set active index to Search
              onTap: (index) => _onItemTapped(context, index),
            ),
          ),
        ],
      ),
    );
  }

  // Method to Build Sport Category Card with Improved Text Positioning
  Widget _buildSportCategory(BuildContext context, String image, String label) {
    return GestureDetector(
      onTap: () {
        // Navigate to the category items screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryItemsScreen(category: label),
          ),
        );
      },
      child: Container(
        margin: label == 'DANCE' // Apply bottom margin only for the "DANCE" category
            ? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0).copyWith(bottom: 50.0)
            : const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // No extra bottom margin for other categories
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
          ),
        ),
        height: 120,
        child: Stack(
          children: [
            Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryItemsScreen extends StatefulWidget {
  final String category;
  const CategoryItemsScreen({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryItemsScreenState createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  late List<Map<String, String>> _items; // All items for the category
  late List<Map<String, String>> _filteredItems; // Filtered items based on search

  @override
  void initState() {
    super.initState();
    _items = _getItemsForCategory(widget.category); // Get the initial list of items
    _filteredItems = List.from(_items); // Initially, all items are visible
  }

  // Dummy function to return items based on category
  List<Map<String, String>> _getItemsForCategory(String category) {
    switch (category) {
      case 'RUNNING':
        return [
          {'image': 'dashimages/run1.png', 'title': 'Running Shoes 1', 'price': '₱3,199'},
          {'image': 'dashimages/run2.png', 'title': 'Running Shoes 2', 'price': '₱3,399'},
          {'image': 'dashimages/run3.png', 'title': 'Running Shoes 3', 'price': '₱3,599'},
          {'image': 'dashimages/run4.png', 'title': 'Running Shoes 4', 'price': '₱3,799'},
          {'image': 'dashimages/run5.png', 'title': 'Running Shoes 5', 'price': '₱3,999'},
          {'image': 'dashimages/run6.png', 'title': 'Running Shoes 6', 'price': '₱4,199'},
        ];
      case 'FOOTBALL':
        return [
          {'image': 'dashimages/foot1.png', 'title': 'Football Shoes 1', 'price': '₱3,499'},
          {'image': 'dashimages/foot2.png', 'title': 'Football Shoes 2', 'price': '₱3,799'},
          {'image': 'dashimages/foot3.png', 'title': 'Football Shoes 3', 'price': '₱3,999'},
          {'image': 'dashimages/foot4.png', 'title': 'Football Shoes 4', 'price': '₱4,199'},
          {'image': 'dashimages/foot5.png', 'title': 'Football Shoes 5', 'price': '₱4,499'},
          {'image': 'dashimages/foot6.png', 'title': 'Football Shoes 6', 'price': '₱4,799'},
        ];
      case 'BASKETBALL':
        return [
          {'image': 'dashimages/bas1.png', 'title': 'Basketball Shoes 1', 'price': '₱4,199'},
          {'image': 'dashimages/bas2.png', 'title': 'Basketball Shoes 2', 'price': '₱4,399'},
          {'image': 'dashimages/bas3.png', 'title': 'Basketball Shoes 3', 'price': '₱4,599'},
          {'image': 'dashimages/bas4.png', 'title': 'Basketball Shoes 4', 'price': '₱4,799'},
          {'image': 'dashimages/bas5.png', 'title': 'Basketball Shoes 5', 'price': '₱4,999'},
          {'image': 'dashimages/bas6.png', 'title': 'Basketball Shoes 6', 'price': '₱5,199'},
        ];
      case 'DANCE':
        return [
          {'image': 'dashimages/dance1.png', 'title': 'Dance Shoes 1', 'price': '₱2,999'},
          {'image': 'dashimages/dance2.png', 'title': 'Dance Shoes 2', 'price': '₱3,199'},
          {'image': 'dashimages/dance3.png', 'title': 'Dance Shoes 3', 'price': '₱3,399'},
          {'image': 'dashimages/dance4.png', 'title': 'Dance Shoes 4', 'price': '₱3,599'},
          {'image': 'dashimages/dance5.png', 'title': 'Dance Shoes 5', 'price': '₱3,799'},
        ];
      default:
        return [];
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
            Navigator.pop(context);  // Return to the previous screen
          },
        ),
        title: Text(
          widget.category,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0, // Increased for better spacing
            mainAxisSpacing: 12.0,  // Increased for better spacing
            childAspectRatio: 0.65, // Adjusted to control the container height-to-width ratio
          ),

          itemCount: _filteredItems.length,
          itemBuilder: (context, index) {
            return _buildItemCard(_filteredItems[index]);
          },
        ),
      ),
    );
  }

  // Build the individual item card for products
  Widget _buildItemCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.asset(
              item['image']!,
              height: 140, // Adjusted height to maintain balance
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8), // Space between image and text
          // Product Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              item['title']!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6), // Adjusted spacing
          // Product Price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              item['price']!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 12), // Adjusted spacing to prevent overflow
        ],
      ),
    );
  }

}


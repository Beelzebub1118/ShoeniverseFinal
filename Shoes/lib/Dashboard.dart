import 'package:carousel_slider/carousel_slider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'details.dart'; // Import Details.dart
import 'Searchbar.dart'; // Import Searchbar.dart
import 'Cart.dart'; // Import Cart.dart
import 'Profile.dart'; // Import Profile.dart

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0; // Track the selected index for bottom navigation
  int _selectedCategoryIndex = 0; // Track selected category in carousel
  bool showCategoryItemsOnly = false; // Track if only category items should be shown

  // Define items for each category
  final Map<int, List<Map<String, String>>> categoryItems = {
    0: [
      {'image': 'dashimages/shoes1.png', 'title': 'Nike Dunk Low Retro', 'price': '₱4,469'},
      {'image': 'dashimages/shoes2.png', 'title': 'NikeCourt Legacy', 'price': '₱3,495'},
      {'image': 'dashimages/shoes3.png', 'title': 'Jordan Spizike Low', 'price': '₱6,229'},
      {'image': 'dashimages/shoes4.png', 'title': 'Nike V2K Run', 'price': '₱6,895'},
      {'image': 'dashimages/shoes5.png', 'title': 'Air Jordan 1 Low SE', 'price': '₱4,295'},
      {'image': 'dashimages/shoes6.png', 'title': 'Nike Air Max 90', 'price': '₱3,839'},
    ],
    1: [
      {'image': 'dashimages/dance1.png', 'title': 'Dance Shoes 1', 'price': '₱2,199'},
      {'image': 'dashimages/dance2.png', 'title': 'Dance Shoes 2', 'price': '₱2,499'},
      {'image': 'dashimages/dance3.png', 'title': 'Dance Shoes 3', 'price': '₱2,899'},
      {'image': 'dashimages/dance4.png', 'title': 'Dance Shoes 4', 'price': '₱3,099'},
      {'image': 'dashimages/dance5.png', 'title': 'Dance Shoes 5', 'price': '₱3,399'},
    ],
    2: [
      {'image': 'dashimages/run1.png', 'title': 'Running Shoes 1', 'price': '₱3,199'},
      {'image': 'dashimages/run2.png', 'title': 'Running Shoes 2', 'price': '₱3,499'},
      {'image': 'dashimages/run3.png', 'title': 'Running Shoes 3', 'price': '₱3,899'},
      {'image': 'dashimages/run4.png', 'title': 'Running Shoes 4', 'price': '₱4,099'},
      {'image': 'dashimages/run5.png', 'title': 'Running Shoes 5', 'price': '₱4,399'},
      {'image': 'dashimages/run6.png', 'title': 'Running Shoes 6', 'price': '₱4,399'},
    ],
    3: [
      {'image': 'dashimages/bas1.png', 'title': 'Basketball Shoes 1', 'price': '₱4,299'},
      {'image': 'dashimages/bas2.png', 'title': 'Basketball Shoes 2', 'price': '₱4,799'},
      {'image': 'dashimages/bas3.png', 'title': 'Basketball Shoes 3', 'price': '₱5,199'},
      {'image': 'dashimages/bas4.png', 'title': 'Basketball Shoes 4', 'price': '₱5,499'},
      {'image': 'dashimages/bas5.png', 'title': 'Basketball Shoes 5', 'price': '₱5,899'},
      {'image': 'dashimages/bas6.png', 'title': 'Basketball Shoes 6', 'price': '₱5,899'},
    ],
    4: [
      {'image': 'dashimages/foot1.png', 'title': 'Football Shoes 1', 'price': '₱3,899'},
      {'image': 'dashimages/foot2.png', 'title': 'Football Shoes 2', 'price': '₱4,099'},
      {'image': 'dashimages/foot3.png', 'title': 'Football Shoes 3', 'price': '₱4,299'},
      {'image': 'dashimages/foot4.png', 'title': 'Football Shoes 4', 'price': '₱4,499'},
      {'image': 'dashimages/foot5.png', 'title': 'Football Shoes 5', 'price': '₱4,799'},
      {'image': 'dashimages/foot6.png', 'title': 'Football Shoes 6', 'price': '₱4,799'},
    ],
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to specific screens based on the selected index with slide transition
    Widget page;
    switch (index) {
      case 1:
        page = const Searchbar();
        break;
      case 2:
        page = Cart();
        break;
      case 3:
        page = Profile();
        break;
      default:
        return; // Stay on Dashboard
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
        backgroundColor: const Color(0xFFececec),
        leading: showCategoryItemsOnly
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              showCategoryItemsOnly = false;
            });
          },
        )
            : null,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Action for notification bell
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFececec),
        child: showCategoryItemsOnly
            ? _buildCategoryItemsOnlyView()
            : _buildFullView(),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 65.0,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.deepOrange,
        items: <Widget>[
          Icon(
            Icons.home_outlined,
            size: 35,
            color: _selectedIndex == 0 ? Colors.white : Colors.grey,
          ),
          Icon(
            Icons.search_outlined,
            size: 35,
            color: _selectedIndex == 1 ? Colors.white : Colors.grey,
          ),
          Icon(
            Icons.shopping_cart_outlined,
            size: 35,
            color: _selectedIndex == 2 ? Colors.white : Colors.grey,
          ),
          Icon(
            Icons.person_2_outlined,
            size: 35,
            color: _selectedIndex == 3 ? Colors.white : Colors.grey,
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }


  Widget _buildFullView() {
    return CustomScrollView(

      slivers: [
        SliverToBoxAdapter(
          child: CarouselSlider(
            options: CarouselOptions(
              height: 150.0,
              autoPlay: true,
              aspectRatio: 16 / 9,
              viewportFraction: 0.75,
            ),
            items: [
              'dashimages/crs1.png',
              'dashimages/crs2.png',
              'dashimages/crs3.png',
              'dashimages/crs4.png',
            ].map((item) => _buildImageWithSpacingAndRoundedCorners(item)).toList(),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 1),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: SizedBox(
              height: 50,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 100.0,
                  autoPlay: false,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.5,
                ),
                items: [
                  'LIFESTYLE',
                  'DANCE',
                  'RUNNING',
                  'BASKETBALL',
                  'FOOTBALL',
                ].asMap().entries.map((entry) {
                  int idx = entry.key;
                  String item = entry.value;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = idx;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      width: 175.0,
                      decoration: BoxDecoration(
                        color: _selectedCategoryIndex == idx ? const Color(0xFFD26414) : Colors.white,
                        borderRadius: BorderRadius.circular(60.0),
                      ),
                      child: Center(
                        child: Text(
                          item,
                          style: TextStyle(
                            color: _selectedCategoryIndex == idx ? Colors.white : Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SliverAppBar(
          pinned: true,
          backgroundColor: const Color(0xFFececec),
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(bottom: 15.0, left: 16.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ['LIFESTYLE', 'DANCE', 'RUNNING', 'BASKETBALL', 'FOOTBALL'][_selectedCategoryIndex],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      showCategoryItemsOnly = true;
                    });
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 1.0),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            childAspectRatio: 0.5,
            mainAxisSpacing: 7.0,
            crossAxisSpacing: 7.0,
            children: categoryItems[_selectedCategoryIndex]!
                .map((item) => _buildGridItem(item['image']!, item['title']!, item['price']!))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItemsOnlyView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ['LIFESTYLE', 'DANCE', 'RUNNING', 'BASKETBALL', 'FOOTBALL'][_selectedCategoryIndex],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 0.5,
              mainAxisSpacing: 7.0,
              crossAxisSpacing: 7.0,
              physics: const NeverScrollableScrollPhysics(),
              children: categoryItems[_selectedCategoryIndex]!
                  .map((item) => _buildGridItem(item['image']!, item['title']!, item['price']!))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(String imagePath, String title, String price) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Details(
              imagePath: imagePath,
              title: title,
              price: price,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        height: 130.0, // Reduced height for the container
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 150, // Adjusted height for the image
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 10.0), // Added spacing between the image and the title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 2,
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 6.0), // Reduced spacing between the title and the price
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 10.0), // Adjusted padding for the price
              child: Text(
                price,
                style: const TextStyle(fontSize: 16.0, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithSpacingAndRoundedCorners(String assetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}

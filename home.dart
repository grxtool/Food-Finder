import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodfinderproject/pages/cart_page.dart';
import 'package:foodfinderproject/pages/feedback_page.dart';
import 'package:foodfinderproject/pages/food_detail.dart';
import 'package:foodfinderproject/pages/food_search.dart';
import 'package:foodfinderproject/pages/my_map.dart';
import 'package:foodfinderproject/pages/order_page.dart';
import 'package:url_launcher/url_launcher.dart';


// HomePage
class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  String getUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.email ?? '';
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  int feedbackCount = 0;
  Map<String, int> cartItems = {}; // To store food items and their quantities
  String selectedCategory = 'All'; // Variable to hold the selected category
  List<Map<String, String>> orders = [];

  // Food items categorized by type
  final Map<String, List<Map<String, String>>> foodCategories = {
    'All': [
      {'image': 'assets/piz1.jpg', 'name': 'Hawaiian Overload', 'price': '195', 'description': 'SWEET RED SAUCES,SWEET HAM,BELL PEPPER, PINEAAPLE,WHITE ONION,AND QUICKMELT CHEESE'},
      {'image': 'assets/piz2.jpg', 'name': 'Meat Overload', 'price': '250', 'description': 'PEPPERONi, SWEET HAM AND BEEF TOPPINGS, LOTS OF CHEESE AND SECRET SPICES'},
      {'image': 'assets/piz3.jpg', 'name': 'Beef and Mushroom', 'price': '195', 'description': 'SWEET RED SAUCE, BEEF TOPPINGS, WHITE ONIONS BELL PEPPER, MUSHROOM AND QUICKMELT CHEESE'},
      {'image': 'assets/piz4.jpg', 'name': 'Hawaiian', 'price': '175', 'description': 'SWEET RED SAUCE, HAM,PINEAPPLE, BELL PEPPER,WHITE ONION, AND QUICKMELT CHEESE'},
      {'image': 'assets/piz5.jpg', 'name': 'Ham and Cheese', 'price': '175', 'description': 'SWEET RED SAUCES, LOTS OF CHEESE, SWEET HAM, AND QUICKMELT CHEESE'},
      {'image': 'assets/piz6.jpg', 'name': 'All Cheese', 'price': '195', 'description': 'SWEET RED SAUCES, LOTS OF CHEESE, AND QUICKMELT CHEESE'},
      {'image': 'assets/piz7.jpg', 'name': 'Mad Cow', 'price': '215', 'description': 'SWEET RED SAUCE,BEEF TOPPINGS, BLACK PEPPER, RED AND GREEN BELL PEPPER,  WHITE ONION AND QUICKMELT CHEESE '},
      {'image': 'assets/piz8.jpg', 'name': 'Cheesy Hotdog', 'price': '175', 'description': 'SWEET RED SAUCES, LOTS OF CHEESE, AND QUICKMELT CHEESE'},
      {'image': 'assets/piz9.jpg', 'name': 'Pepperoni Pizza', 'price': '215', 'description': 'SWEET RED SAUCE, BEEF PEPPERONI, LOTS OF QUICKMELT CHEESE'},
      {'image': 'assets/piz10.jpg', 'name': 'Tuna Delight', 'price': '195', 'description': 'SWEET RED SAUCE TUNA BiTS, MUSHROOM, WHITE ONION, BELL PEPPER AND QUiCKMELT CHEESE'},
      {'image': 'assets/piz11.jpg', 'name': 'Garden Special', 'price': '185', 'description': 'SWEET RED SAUCE, TOMATOES, MUSHROOM, PiNEAPPLE, BELL PEPPER, WHITE ONiON, AND QUiCKMELT CHEESE'},
    ],
    'Hawaiian Overload': [
       {'image': 'assets/piz1.jpg', 'name': 'Hawaiian Overload', 'price': '195', 'description': 'SWEET RED SAUCES,SWEET HAM,BELL PEPPER, PINEAAPLE,WHITE ONION,AND QUICKMELT CHEESE'},

    ],
    'Meat Overload': [
     {'image': 'assets/piz2.jpg', 'name': 'Meat Overload', 'price': '250', 'description': 'PEPPERONi, SWEET HAM AND BEEF TOPPINGS, LOTS OF CHEESE AND SECRET SPICES'},
    ],
    'Beef and Mushroom': [
      {'image': 'assets/piz3.jpg', 'name': 'Beef and Mushroom', 'price': '195', 'description': 'SWEET RED SAUCE, BEEF TOPPINGS, WHITE ONIONS BELL PEPPER, MUSHROOM AND QUICKMELT CHEESE'},
    ],
    'Hawaiian': [
      {'image': 'assets/piz4.jpg', 'name': 'Hawaiian', 'price': '175', 'description': 'SWEET RED SAUCE, HAM,PINEAPPLE, BELL PEPPER,WHITE ONION, AND QUICKMELT CHEESE'},
    ],
    'Ham and Cheese': [
      {'image': 'assets/piz5.jpg', 'name': 'Ham and Cheese', 'price': '175', 'description': 'SWEET RED SAUCES, LOTS OF CHEESE, SWEET HAM, AND QUICKMELT CHEESE'},
    ],
    'All Cheese': [
      {'image': 'assets/piz6.jpg', 'name': 'All Cheese', 'price': '195', 'description': 'SWEET RED SAUCES, LOTS OF CHEESE, AND QUICKMELT CHEESE'},
    ],
    'Mad Cow': [
      {'image': 'assets/piz7.jpg', 'name': 'Mad Cow ', 'price': '215', 'description': 'SWEET RED SAUCE,BEEF TOPPINGS, BLACK PEPPER, RED AND GREEN BELL PEPPER,  WHITE ONION AND QUICKMELT CHEESE '},
    ],
    'Cheesy Hotdog': [
      {'image': 'assets/piz8.jpg', 'name': 'Cheesy Hotdog', 'price': '175', 'description': 'SWEET RED SAUCES, LOTS OF CHEESE, AND QUICKMELT CHEESE'},
    ],
    'Pepperoni Pizza': [
      {'image': 'assets/piz9.jpg', 'name': 'Pepperoni Pizza', 'price': '215', 'description': 'SWEET RED SAUCE, BEEF PEPPERONI, LOTS OF QUICKMELT CHEESE'},
    ],
    'Tuna Delight': [
      {'image': 'assets/piz10.jpg', 'name': 'Tuna Delight', 'price': '195', 'description': 'SWEET RED SAUCE TUNA BiTS, MUSHROOM, WHITE ONION, BELL PEPPER AND QUiCKMELT CHEESE'},
    ],
    'Garden Special': [
      {'image': 'assets/piz11.jpg', 'name': 'Garden Special', 'price': '185', 'description': 'SWEET RED SAUCE, TOMATOES, MUSHROOM, PiNEAPPLE, BELL PEPPER, WHITE ONiON, AND QUiCKMELT CHEESE'},
    ],
  };
     void _addToCart(Map<String, String> foodItem, int quantity) {
    setState(() {
      final foodName = foodItem['name']!;
      if (quantity > 0) {
        // Add to cart or increase quantity
        cartItems[foodName] = (cartItems[foodName] ?? 0) + quantity;
      } else {
        // Decrease or remove from cart
        if (cartItems.containsKey(foodName)) {
          cartItems[foodName] = cartItems[foodName]! + quantity;
          if (cartItems[foodName]! <= 0) {
            cartItems.remove(foodName);
          }
        }
      }
    });
  }

  int get cartItemCount {
    return cartItems.values.fold(0, (sum, quantity) => sum + quantity);
  }

    void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  switch (index) {
    case 0:
      // Reset to the HomePage (you can choose to refresh or reset the state if necessary)
      setState(() {
        selectedCategory = 'All';  // Optionally reset category
        cartItems = {}; // Optionally reset the cart items
      });
      break;
    case 1:
      showSearch(
        context: context,
        delegate: FoodSearchDelegate(
          addFeedback: _addFeedback,
          addToCart: _addToCart,
        ),
      );
      break;
    case 2:
      // Maps Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MapsPage(title: '',), // Navigate to the MapsPage
        ),
      );
      break;
    case 3:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CartPage(cartItems: cartItems, userEmail: '', userName: '', cartId: '',),
        ),
      );
      break;
  }
}


  void _addFeedback(String foodName, String feedback) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('feedbacks').add({
      'foodName': foodName,
      'feedback': feedback,
      'userEmail': user.email,
      'timestamp': DateTime.now(),
    });

    setState(() {
      feedbackCount++;
    });
  }

  void _showFeedbackPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackPage(onFeedbackViewed: _resetFeedbackCount),
      ),
    );
  }

  void _resetFeedbackCount() {
    setState(() {
      feedbackCount = 0;
    });
  }

  void _navigateToCartPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          cartId: getUserEmail(),
          userEmail: '',
          userName: '',
          cartItems: cartItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Fetch the food items for the selected category
    final foodItems = foodCategories[selectedCategory] ?? [];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Bringing Good Food to Your Screen',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.cyanAccent.shade400,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
                actions: [
          // Shopping Cart Icon with Badge
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart),
                if (cartItemCount > 0) // Show badge only when there are items in the cart
                  Positioned(
                    right: -5,
                    top: -5,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text(
                        cartItemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _navigateToCartPage,
          ),

          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.feedback),
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      feedbackCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              _showFeedbackPage(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.cyan,
              ),
              child: Column(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/apklogo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Text(
                    'Good Food, Good Mood',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(user?.email ?? 'No User'),
              onTap: () {
                Navigator.of(context).pop();
                if (user?.email != null) {
                  _launchGmail(user!.email!);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('My Orders'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyOrdersPage(userEmail: ''),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category filter
              Container(
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['All', 'Hawaiian Overload', 'Meat Overload', 'Beef and Mushroom', 'Hawaiian', 'Ham and Cheese', 'All Cheese', 'Mad Cow', 'Cheesy Hotdog', 'Pepperoni Pizza', 'Tuna Delight', 'Garden Special']
                      .map((category) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  selectedCategory == category
                                      ? Colors.cyan
                                      : Colors.grey[200],
                                ),
                                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
                              ),
                              child: Text(category),
                            ),
                          ))
                      .toList(),
                ),
              ),

              // Food items list with scrolling
                  Expanded(
  child: SingleChildScrollView(
    child: Column(
      children: foodItems.map((foodItem) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDetailPage(
                  foodItem: foodItem,
                  addFeedback: _addFeedback,
                  addToCart: _addToCart,
                  userEmail: '',
                  userName: '',
                  foodName: '',
                  description: '',
                  price: '',
                ),
              ),
            );
          },
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      foodItem['image']!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          foodItem['name']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₱${foodItem['price']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          foodItem['description']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ),
  ),
),

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Maps',
          ),
        ],
      ),
    );
  }

  void _launchGmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}  
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodfinderproject/pages/cart_page.dart';
import 'package:foodfinderproject/pages/order_form_page.dart';

class FoodDetailPage extends StatefulWidget {
  final Map<String, String> foodItem;
  final Function(String, String) addFeedback;

  const FoodDetailPage({
    super.key,
    required this.foodItem,
    required this.addFeedback,
    required String userEmail,
    required void Function(Map<String, String> foodItem, int quantity) addToCart,
    required String userName,
    required String foodName,
    required String description,
    required String price,
  });

  @override
  _FoodDetailPageState createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final TextEditingController feedbackController = TextEditingController();
  int selectedQuantity = 1;
  int cartItemCount = 0;
  String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  void initState() {
    super.initState();
    fetchCartItemCount();
  }

  // Fetch cart item count for the badge
  Future<void> fetchCartItemCount() async {
    if (currentUserEmail.isNotEmpty) {
      DocumentSnapshot userCartSnapshot = await FirebaseFirestore.instance
          .collection('carts')
          .doc(currentUserEmail)
          .get();

      if (userCartSnapshot.exists) {
        List<dynamic> currentItems = userCartSnapshot['items'];
        setState(() {
          cartItemCount = currentItems.length;
        });
      }
    }
  }

  // Add the food item to the cart (including image)
    // Add the food item to the cart (including image and price)
Future<void> addToCart(Map<String, int> cartItems) async {
  if (currentUserEmail.isEmpty) {
    print('Error: userEmail is empty');
    return;
  }

  CollectionReference carts = FirebaseFirestore.instance.collection('carts');

  // Add food name, quantity, image, and price to cart items
  List<Map<String, dynamic>> itemList = cartItems.entries
      .map((entry) => {
            'food': entry.key,
            'quantity': entry.value,
            'image': widget.foodItem['image'], // Include the image
            'price': widget.foodItem['price'], // Include the price
          })
      .toList();

  try {
    DocumentSnapshot userCartSnapshot = await carts.doc(currentUserEmail).get();
    if (userCartSnapshot.exists) {
      List<dynamic> currentItems = List<dynamic>.from(userCartSnapshot['items']);
      for (var item in itemList) {
        bool itemExists = false;
        for (var currentItem in currentItems) {
          if (currentItem['food'] == item['food']) {
            currentItem['quantity'] += item['quantity'];
            itemExists = true;
            break;
          }
        }
        if (!itemExists) {
          currentItems.add(item);
        }
      }
      await carts.doc(currentUserEmail).set({'items': currentItems}, SetOptions(merge: true));
    } else {
      await carts.doc(currentUserEmail).set({'items': itemList});
    }

    setState(() {
      cartItemCount += itemList.length; // Update cart badge
    });
    print("Item added to cart!");
  } catch (e) {
    print("Failed to add item to cart: $e");
  }
}


  void _navigateToCartPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          cartId: currentUserEmail,
          userEmail: currentUserEmail,
          userName: 'User', // Replace with actual user name if available
          cartItems: const {}, // You can pass the cart items if needed
        ),
      ),
    ).then((_) => fetchCartItemCount()); // Refresh cart item count after navigating
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodItem['name']!),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _navigateToCartPage,
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  widget.foodItem['image']!,
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.foodItem['name']!,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              '₱${widget.foodItem['price']}',
              style: const TextStyle(fontSize: 22, color: Colors.teal, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            // Feedback Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Feedback',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: feedbackController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your feedback...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (feedbackController.text.isNotEmpty) {
                          widget.addFeedback(widget.foodItem['name']!, feedbackController.text);
                          feedbackController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Feedback submitted!')),
                          );
                        }
                      },
                      child: const Text('Submit Feedback'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Quantity Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantity:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (selectedQuantity > 1) selectedQuantity--;
                        });
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$selectedQuantity', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedQuantity++;
                        });
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Add to Cart Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  addToCart({widget.foodItem['name']!: selectedQuantity});
                },
                child: const Text('Add to Cart'),
              ),
            ),
            const SizedBox(height: 20),
            // Order Now Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderFormPage(
                        foodItem: widget.foodItem,
                        quantity: selectedQuantity,
                        foodName: widget.foodItem['name']!,
                        foodImage: widget.foodItem['image']!,
                        foodPrice: double.tryParse(widget.foodItem['price']!), cartItems: {}, totalPayment: null,
                      ),
                    ),
                  );
                },
                child: const Text('Order Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}  
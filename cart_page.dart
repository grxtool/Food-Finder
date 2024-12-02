import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodfinderproject/pages/order_form_page.dart';

class CartPage extends StatefulWidget {
  final String cartId;

  const CartPage({
    super.key,
    required this.cartId,
    required String userEmail,
    required String userName,
    required Map cartItems,
  });

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<Map<String, Map<String, dynamic>>> cartItemsFuture;
  Set<String> selectedItems = {}; // Set to keep track of selected items
  double totalPayment = 0.0; // Total payment for the cart
  bool selectAll = false; // Boolean to track select all checkbox state
  String? clickedFoodItem; // Track the clicked food item to show edit/delete icons

  @override
  void initState() {
    super.initState();
    cartItemsFuture = getCartFromFirestore(widget.cartId);
  }

  Future<Map<String, Map<String, dynamic>>> getCartFromFirestore(String cartId) async {
    final cartDoc = FirebaseFirestore.instance.collection('carts').doc(cartId);
    final snapshot = await cartDoc.get();

    if (snapshot.exists) {
      final items = List<Map<String, dynamic>>.from(snapshot['items']);
      return {
        for (var item in items)
          item['food'] as String: {
            'quantity': item['quantity'],
            'image': item['image'],
            'price': _parsePrice(item['price']), // Ensure price is treated as a double
          }
      };
    } else {
      return {}; // Return an empty map if the cart is empty
    }
  }

  // Helper method to parse the price and ensure it's treated as a double
  double _parsePrice(dynamic price) {
    if (price is String) {
      return double.tryParse(price) ?? 0.0; // Try parsing the string as a double
    } else if (price is num) {
      return price.toDouble(); // Ensure price is a double if it's already a number
    }
    return 0.0; // Return 0 if the price is neither a string nor a number
  }

  Future<void> updateCartInFirestore(String cartId, Map<String, Map<String, dynamic>> updatedItems) async {
    final cartDoc = FirebaseFirestore.instance.collection('carts').doc(cartId);
    final snapshot = await cartDoc.get();

    if (snapshot.exists) {
      await cartDoc.update({
        'items': updatedItems.entries.map((e) => {
          'food': e.key,
          'quantity': e.value['quantity'],
          'image': e.value['image'],
          'price': e.value['price'],  // Ensure price is stored as a double
        }).toList(),
      });
    } else {
      await cartDoc.set({
        'items': updatedItems.entries.map((e) => {
          'food': e.key,
          'quantity': e.value['quantity'],
          'image': e.value['image'],
          'price': e.value['price'],  // Ensure price is set as a double when creating
        }).toList(),
        'userEmail': 'default@example.com',
        'userName': 'Default Name',
      });
    }
  }

  Future<void> removeItem(String foodItem) async {
    final cartItems = await cartItemsFuture;
    cartItems.remove(foodItem);

    // Update Firestore with the updated cart items
    await updateCartInFirestore(widget.cartId, cartItems);

    // Ensure the UI is updated immediately after deletion
    setState(() {
      cartItemsFuture = Future.value(cartItems);
    });
  }

  Future<void> removeSelectedItems() async {
    final cartItems = await cartItemsFuture;
    for (var foodItem in selectedItems) {
      cartItems.remove(foodItem);
    }

    // Update Firestore with the updated cart items
    await updateCartInFirestore(widget.cartId, cartItems);

    // Ensure the UI is updated immediately after deletion
    setState(() {
      cartItemsFuture = Future.value(cartItems);
      selectedItems.clear();
      selectAll = false;
    });
  }

  Future<void> editItemQuantity(String foodItem, int newQuantity) async {
    final cartItems = await cartItemsFuture;
    if (newQuantity > 0) {
      cartItems[foodItem]!['quantity'] = newQuantity;
    } else {
      cartItems.remove(foodItem);
    }

    await updateCartInFirestore(widget.cartId, cartItems);

    setState(() {
      cartItemsFuture = Future.value(cartItems);
    });
  }

  void toggleSelection(String foodItem) {
    setState(() {
      if (selectedItems.contains(foodItem)) {
        selectedItems.remove(foodItem);
      } else {
        selectedItems.add(foodItem);
      }
    });
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>( 
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Selected Items'),
          content: const Text('Are you sure you want to delete all selected items?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  double calculateTotalPayment(Map<String, Map<String, dynamic>> cartItems) {
    double total = 0.0;
    cartItems.forEach((key, value) {
      final quantity = value['quantity'];
      final price = value['price']; // Already a double
      total += quantity * price;
    });
    return total;
  }

    void checkout() async {
  final cartItems = await cartItemsFuture;

  // Filter only selected items
  final selectedCartItems = cartItems.entries
      .where((entry) => selectedItems.contains(entry.key))
      .map((entry) => {
            'name': entry.key,
            'quantity': entry.value['quantity'].toString(),
            'image': entry.value['image'] ?? '',
            'price': entry.value['price'].toString(),
          })
      .toList();

  if (selectedCartItems.isEmpty) {
    // Show a message if no items are selected
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Items Selected'),
        content: const Text('Please select at least one item to proceed with checkout.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  // Navigate to the OrderFormPage with the selected items
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OrderFormPage(
        foodItem: {
          'name': selectedCartItems[0]['name']!,
          'quantity': selectedCartItems[0]['quantity']!,
          'image': selectedCartItems[0]['image']!,
          'price': selectedCartItems[0]['price']!,
        }, // Explicitly cast Map<String, dynamic> to Map<String, String>
        quantity: int.parse(selectedCartItems[0]['quantity']!),
        foodName: selectedCartItems[0]['name']!,
        foodImage: selectedCartItems[0]['image']!,
        foodPrice: selectedCartItems[0]['price']!,
        cartItems: {
          for (var item in selectedCartItems)
            item['name']!: {
              'quantity': item['quantity']!,
              'price': item['price']!,
              'image': item['image']!,
            }
        },
        totalPayment: totalPayment, // Pass the calculated total payment
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: FutureBuilder<Map<String, Map<String, dynamic>>>(
        future: cartItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          } else {
            final cartItems = snapshot.data!;
            totalPayment = calculateTotalPayment(cartItems); 
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: selectAll,
                        onChanged: (value) {
                          setState(() {
                            selectAll = value!;
                            if (selectAll) {
                              selectedItems = cartItems.keys.toSet();
                            } else {
                              selectedItems.clear();
                            }
                          });
                        },
                      ),
                      const Text('Select All', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: selectedItems.isEmpty ? null : () async {
                          final confirm = await _showDeleteConfirmationDialog();
                          if (confirm == true) {
                            await removeSelectedItems();
                          }
                        },
                        child: const Text('Delete Selected'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final foodItem = cartItems.keys.elementAt(index);
                      final quantity = cartItems[foodItem]!['quantity'];
                      final image = cartItems[foodItem]!['image'];
                      final price = cartItems[foodItem]!['price']; // Get the price for each item

                      Widget imageWidget;
                      if (image != null && image.startsWith('http')) {
                        imageWidget = Image.network(image, width: 50, height: 50, fit: BoxFit.cover);
                      } else if (image != null && image.startsWith('assets/')) {
                        imageWidget = Image.asset(image, width: 50, height: 50, fit: BoxFit.cover);
                      } else {
                        imageWidget = Container(width: 50, height: 50);
                      }

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            // Toggle visibility of edit/delete icons
                            clickedFoodItem = clickedFoodItem == foodItem ? null : foodItem;
                          });
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          child: ListTile(
                            leading: imageWidget,
                            title: Text(foodItem, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Quantity: $quantity\nPrice: ₱${price.toString()}'), // Display the price
                            trailing: clickedFoodItem == foodItem
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          // Add edit functionality here
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              int newQuantity = quantity!;
                                              return AlertDialog(
                                                title: const Text('Edit Quantity'),
                                                content: TextField(
                                                  keyboardType: TextInputType.number,
                                                  onChanged: (value) {
                                                    newQuantity = int.tryParse(value) ?? newQuantity;
                                                  },
                                                  controller: TextEditingController(text: newQuantity.toString()),
                                                  decoration: const InputDecoration(labelText: 'Enter new quantity'),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      if (newQuantity != quantity) {
                                                        editItemQuantity(foodItem, newQuantity);
                                                      }
                                                    },
                                                    child: const Text('Save'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          // Delete the item
                                          removeItem(foodItem);
                                        },
                                      ),
                                    ],
                                  )
                                : Checkbox(
                                    value: selectedItems.contains(foodItem),
                                    onChanged: (_) => toggleSelection(foodItem),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: ₱${totalPayment.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: checkout,
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}   

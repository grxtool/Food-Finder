import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderFormPage extends StatefulWidget {
  final Map<String, String> foodItem;
  final int quantity;

  const OrderFormPage({super.key, required this.foodItem, required this.quantity, required String foodName, required String foodImage, required foodPrice, required Map cartItems, required totalPayment});

  @override
  _OrderFormPageState createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  String selectedPaymentMethod = 'Cash on Delivery';

  // Retrieve the current user's email from FirebaseAuth
  String? userEmail;

  @override
  void initState() {
    super.initState();
    getCurrentUserEmail();
  }

  Future<void> getCurrentUserEmail() async {
    final User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email; // Set the email from the logged-in user
    });
  }

  // Update placeOrderToFirestore function to accept totalPayment
  Future<void> placeOrderToFirestore(
    String fullName,
    String foodName,
    int quantity,
    String status,
    String userEmail,
    String address,
    String paymentMethod,
    String foodImage,
    String foodPrice,
    String contactNumber,
    double totalPayment, // Add totalPayment here
  ) async {
    CollectionReference orders = FirebaseFirestore.instance.collection('orders');
    try {
      await orders.add({
        'fullName': fullName,
        'foodName': foodName,
        'quantity': quantity,
        'status': status,
        'userEmail': userEmail,
        'address': address,
        'paymentMethod': paymentMethod,
        'foodImage': foodImage,
        'foodPrice': foodPrice,
        'contactNumber': contactNumber,
        'totalPayment': totalPayment, // Save totalPayment to Firestore
      });
    } catch (e) {
      print("Failed to place order to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double foodPrice = double.tryParse(widget.foodItem['price'] ?? '0') ?? 0;
    double totalPayment = foodPrice * widget.quantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Order for: ${widget.foodItem['name']} x${widget.quantity}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contactNumberController,
                keyboardType: TextInputType.number, // Ensure it's numeric keyboard
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                ],
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              DropdownButton<String>(
                value: selectedPaymentMethod,
                items: <String>['Cash on Delivery', 'GCash'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPaymentMethod = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Total Payment Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Payment:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₱${totalPayment.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (nameController.text.isEmpty || addressController.text.isEmpty || contactNumberController.text.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Incomplete Details'),
                          content: const Text('Please fill in all the details before submitting your order.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (userEmail == null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('User Not Signed In'),
                          content: const Text('Please sign in to place an order.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // Place order with the user's email and totalPayment
                    placeOrderToFirestore(
                      nameController.text,           // Full name from input
                      widget.foodItem['name']!,       // Food name
                      widget.quantity,                // Quantity
                      'Pending',                      // Status
                      userEmail!,                     // User email
                      addressController.text,         // Address
                      selectedPaymentMethod,          // Payment method
                      widget.foodItem['image']!,      // Food image
                      widget.foodItem['price']!,      // Food price
                      contactNumberController.text,   // Contact number
                      totalPayment,                   // Total payment
                    );

                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Order Confirmed'),
                          content: const Text('Your order has been confirmed!'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}  
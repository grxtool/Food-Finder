import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({Key? key, required String userEmail}) : super(key: key);

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  TextEditingController _feedbackController = TextEditingController();
  Map<String, bool> _isFeedbackVisible = {}; // Track feedback visibility for each order
  Map<String, String> _currentFeedback = {}; // Track feedback for each order

  Future<void> _markOrderAsReceived(BuildContext context, String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'Order Received',
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order received')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark order as received: $e')),
      );
    }
  }

  Future<void> _submitFeedback(BuildContext context, String orderId) async {
    String feedback = _currentFeedback[orderId]?.trim() ?? '';

    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your feedback')));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'feedback': feedback,
      });

      setState(() {
        _isFeedbackVisible[orderId] = false; // Hide feedback input after submission
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback submitted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit feedback: $e')));
    }
  }

  // Function to delete the order from Firestore
  Future<void> _deleteOrder(BuildContext context, String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete order: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? userEmail = user?.email;

    if (userEmail == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
        ),
        body: const Center(child: Text('Please log in to view your orders.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userEmail', isEqualTo: userEmail)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          double totalPayment = 0.0;
          for (var document in snapshot.data!.docs) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            double foodPrice = double.tryParse(data['foodPrice'].toString()) ?? 0.0;
            int quantity = int.tryParse(data['quantity'].toString()) ?? 0;
            totalPayment += foodPrice * quantity;
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    bool isOrderReceived = data['status'] == 'Order Received';
                    String orderId = document.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                data['foodImage'] != null && data['foodImage'].startsWith('http')
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          data['foodImage'],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          data['foodImage'],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['foodName'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Quantity: ${data['quantity']}',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      Text(
                                        'Price: ₱${data['foodPrice']}',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      Text(
                                        'Status: ${data['status']}',
                                        style: TextStyle(
                                          color: isOrderReceived
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Address: ${data['address']}',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      Text(
                                        'Payment Method: ${data['paymentMethod']}',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                // Delete Icon
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _deleteOrder(context, orderId);
                                  },
                                ),
                              ],
                            ),
                            // Add a container to hold feedback
                            if (_isFeedbackVisible[orderId] == true)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.teal.shade200),
                                      ),
                                      child: TextField(
                                        controller: _feedbackController,
                                        onChanged: (value) {
                                          _currentFeedback[orderId] = value;
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Write your feedback...',
                                          border: InputBorder.none,
                                        ),
                                        maxLines: 3,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                                        elevation: 5,
                                      ),
                                      child: const Text(
                                        'Submit Feedback',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () {
                                        _submitFeedback(context, orderId);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            // "Order Received" Button placed inside the card but at the bottom
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Order Received',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  _markOrderAsReceived(context, orderId);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Payment: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '₱${totalPayment.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

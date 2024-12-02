import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  final VoidCallback onFeedbackViewed;

  const FeedbackPage({super.key, required this.onFeedbackViewed});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Previous Users Feedbacks')),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('feedbacks').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No feedbacks yet.'));
          }

          final feedbackDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: feedbackDocs.length,
            itemBuilder: (context, index) {
              final feedback = feedbackDocs[index];
              final feedbackData = feedback.data() as Map<String, dynamic>;

              // Check if the current user owns this feedback
              final isCurrentUser = feedbackData['userId'] == currentUser?.uid;

              return ListTile(
                title: Text(feedbackData['foodName'] ?? 'Unnamed Food'),
                subtitle: Text(feedbackData['feedback'] ?? 'No feedback provided.'),
                trailing: isCurrentUser
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editFeedback(context, feedback),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteFeedback(context, feedback.id),
                          ),
                        ],
                      )
                    : Text(feedbackData['userEmail'] ?? 'Unknown User'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          onFeedbackViewed(); // Reset feedback count when page is opened
          Navigator.pop(context); // Close feedback page
        },
        label: const Text('Mark All as Read'),
        backgroundColor: Colors.cyanAccent.shade400,
      ),
    );
  }

  void _editFeedback(BuildContext context, DocumentSnapshot feedback) {
    final feedbackData = feedback.data() as Map<String, dynamic>;
    final feedbackController = TextEditingController(text: feedbackData['feedback'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Feedback'),
        content: TextField(
          controller: feedbackController,
          decoration: const InputDecoration(labelText: 'Feedback'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Update the feedback document with the new text
              await FirebaseFirestore.instance
                  .collection('feedbacks')
                  .doc(feedback.id)
                  .update({'feedback': feedbackController.text});
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFeedback(BuildContext context, String feedbackId) async {
    await FirebaseFirestore.instance.collection('feedbacks').doc(feedbackId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback deleted')),
    );
  }
}

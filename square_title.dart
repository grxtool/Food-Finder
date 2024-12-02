import 'package:flutter/material.dart';

class CircleTitle extends StatelessWidget {
  final String imagePath;

  const CircleTitle({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Change to circle shape
        color: Colors.white,
        border: Border.all(color: Colors.white),
      ),
      child: ClipOval(
        // Use ClipOval to create a circular mask for the image
        child: Image.asset(
          imagePath,
          height: 30, // Adjust height to fit the circle
          width: 30, // Adjust width to fit the circle
          fit: BoxFit.cover, // Ensure the image covers the entire circle
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red);
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MyLogo extends StatelessWidget {
  final double height;

  const MyLogo({super.key, this.height = 150.0});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/logo.png',
        height: height,
        width: height, // Ensure that width is equal to height for a perfect circle
        fit: BoxFit.cover, // This will ensure the image is scaled properly within the circle
      ),
    );
  }
}

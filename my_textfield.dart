import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hinText;
  final bool obsecureText;
  final VoidCallback? onSubmitted;
  final Icon? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onChanged; // Added onChanged parameter

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hinText,
    required this.obsecureText,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged, // This will allow us to pass the function
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obsecureText,
        onSubmitted: (value) {
          if (onSubmitted != null) {
            onSubmitted!();
          }
        },
        onChanged: onChanged, // This listens to the value change
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hinText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
